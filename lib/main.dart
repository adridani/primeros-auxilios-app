import 'package:flutter/material.dart';
import 'screens/emergency_confirmation_screen.dart';
import 'screens/consciousness_check_screen.dart';
import 'screens/breathing_check_screen.dart';
import 'screens/emergency_menu_screen.dart';
import 'screens/placeholder_instructions_screen.dart';
import 'services/emergency_call_service.dart';
import 'services/call_status.dart';
import 'widgets/call_status_banner.dart';

void main() {
  runApp(const PrimerosAuxiliosApp());
}

/// Clave global que permite navegar y mostrar SnackBars desde
/// cualquier parte de la app (incluso fuera de un widget con
/// context directo, como los callbacks de más abajo).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class PrimerosAuxiliosApp extends StatelessWidget {
  const PrimerosAuxiliosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Primeros Auxilios',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      // El banner de "llamada en curso" envuelve TODA la app aquí,
      // así que aparece por encima de cualquier pantalla sin tener
      // que añadirlo una por una.
      builder: (context, child) {
        return CallStatusBanner(child: child!);
      },
      home: EmergencyConfirmationScreen(
        onResult: _handleEmergencyConfirmationResult,
      ),
    );
  }

  Future<void> _handleEmergencyConfirmationResult(bool isEmergency) async {
    if (!isEmergency) {
      debugPrint('El usuario indicó que no hay emergencia.');
      // Más adelante: aquí cerraremos la app o volveremos
      // a una pantalla de inicio/prevención.
      return;
    }

    // 1. Iniciar la llamada de auxilio cuanto antes, y marcar el
    // estado global como "llamada en curso" para que el banner
    // aparezca en cuanto el usuario vuelva a ver la app.
    callStatusNotifier.markCallStarted();
    final callResult = await EmergencyCallService.callEmergencyNumber();
    _showResultSnackBar(callResult);

    // Si la llamada ni siquiera se pudo iniciar (permiso denegado
    // o fallo), no tiene sentido mostrar el banner de "en curso".
    if (callResult == EmergencyCallResult.permissionDenied ||
        callResult == EmergencyCallResult.failed) {
      callStatusNotifier.markCallEnded();
    }

    // 2. Continuar el triaje mientras la llamada está en marcha:
    // preguntar si la víctima está consciente.
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ConsciousnessCheckScreen(
          onResult: _handleConsciousnessResult,
        ),
      ),
    );
  }

  void _handleConsciousnessResult(bool isConscious) {
    if (isConscious) {
      // Consciente: vamos directo al menú de tipos de emergencia.
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => const EmergencyMenuScreen(),
        ),
      );
    } else {
      // Inconsciente: hace falta comprobar la respiración.
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => BreathingCheckScreen(
            onResult: _handleBreathingResult,
          ),
        ),
      );
    }
  }

  void _handleBreathingResult(BreathingStatus status) {
    // Por seguridad, ante la duda ("no lo sé") se trata igual que
    // "no respira": los protocolos oficiales indican actuar como
    // si no hubiera respiración normal para no perder tiempo crítico.
    final String destinationTitle = switch (status) {
      BreathingStatus.breathing => 'Posición lateral de seguridad',
      BreathingStatus.notBreathing => 'RCP (Reanimación cardiopulmonar)',
      BreathingStatus.unsure => 'RCP (Reanimación cardiopulmonar)',
    };

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => PlaceholderInstructionsScreen(
          title: destinationTitle,
        ),
      ),
    );
  }

  void _showResultSnackBar(EmergencyCallResult result) {
    final String message = switch (result) {
      EmergencyCallResult.calledDirectly =>
        '✅ Llamando automáticamente al número de emergencia...',
      EmergencyCallResult.dialerOpened =>
        '📞 Marcador abierto con el número de emergencia listo.',
      EmergencyCallResult.permissionDenied =>
        '⚠️ Permiso de llamada denegado. Ábrelo manualmente.',
      EmergencyCallResult.failed =>
        '❌ No se pudo iniciar la llamada. Inténtalo manualmente.',
    };

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}