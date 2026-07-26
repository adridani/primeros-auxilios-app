import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Número al que se llama al confirmar una emergencia.
///
/// ⚠️ TODO: CAMBIAR ESTE NÚMERO POR "112" ANTES DE PUBLICAR LA APP.
/// Se usa un número de pruebas para no llamar al servicio real
/// de emergencias mientras se desarrolla y se prueba la app.
const String kEmergencyPhoneNumber = '600000000';

/// Resultado de intentar realizar la llamada de emergencia,
/// para que la pantalla pueda mostrar algo si algo falla
/// (por ejemplo, si el usuario niega el permiso en Android).
enum EmergencyCallResult {
  calledDirectly, // Android: se llamó automáticamente.
  dialerOpened, // iOS / fallback: se abrió el marcador con el número puesto.
  permissionDenied, // Android: el usuario no dio permiso de llamada.
  failed, // Cualquier otro error inesperado.
}

class EmergencyCallService {
  /// Intenta realizar la llamada de emergencia de la forma más rápida
  /// posible según la plataforma:
  ///   - Android: llama directamente, sin toques adicionales,
  ///     si el permiso CALL_PHONE está concedido.
  ///   - iOS (y cualquier otra plataforma no-Android): abre la app
  ///     de teléfono con el número ya escrito; el usuario final
  ///     debe dar el último toque para llamar (restricción de Apple,
  ///     no evitable por ninguna app).
  static Future<EmergencyCallResult> callEmergencyNumber() async {
    // En web no hay llamadas telefónicas reales; lo dejamos
    // controlado para no romper las pruebas en Chrome.
    if (kIsWeb) {
      return EmergencyCallResult.dialerOpened;
    }

    if (Platform.isAndroid) {
      return _callOnAndroid();
    } else {
      return _openDialerFallback();
    }
  }

  static Future<EmergencyCallResult> _callOnAndroid() async {
    final PermissionStatus status = await Permission.phone.request();

    if (!status.isGranted) {
      return EmergencyCallResult.permissionDenied;
    }

    try {
      final bool? success =
          await FlutterPhoneDirectCaller.callNumber(kEmergencyPhoneNumber);
      if (success == true) {
        return EmergencyCallResult.calledDirectly;
      }
      // Si el plugin falla por algún motivo, no dejamos a la persona
      // sin nada: caemos al marcador normal como último recurso.
      return _openDialerFallback();
    } catch (_) {
      return _openDialerFallback();
    }
  }

  static Future<EmergencyCallResult> _openDialerFallback() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: kEmergencyPhoneNumber);
    try {
      final bool launched = await launchUrl(phoneUri);
      return launched
          ? EmergencyCallResult.dialerOpened
          : EmergencyCallResult.failed;
    } catch (_) {
      return EmergencyCallResult.failed;
    }
  }
}