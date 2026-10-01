import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'screens/call_preparation_screen.dart';
import 'screens/emergency_confirmation_screen.dart';
import 'screens/consciousness_check_screen.dart';
import 'screens/breathing_check_screen.dart';
import 'screens/emergency_menu_screen.dart';
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

/// Evita empujar la misma pantalla dos veces por un doble toque
/// accidental (fácil que pase con alguien nervioso pulsando varias
/// veces seguidas en una emergencia real).
DateTime? _lastPushAt;

/// Evita que un doble toque en la pantalla previa a la llamada lance
/// dos llamadas (o una llamada y además "ya ha llamado otra persona").
bool _leftCallPreparation = false;

void _pushOnce(Widget screen) {
  final now = DateTime.now();
  if (_lastPushAt != null && now.difference(_lastPushAt!) < const Duration(milliseconds: 600)) {
    return;
  }
  _lastPushAt = now;
  navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => screen));
}

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
      // Cierra la app (Android). En iOS, Apple no permite que una app
      // se cierre a sí misma por diseño (SystemNavigator.pop() no hace
      // nada ahí), así que en ese caso simplemente no pasa nada más.
      SystemNavigator.pop();
      return;
    }

    // Antes de llamar, una pantalla explica qué va a pasar (pulsar
    // "Llamar" en iPhone, poner el altavoz y volver a la app, que la
    // llamada no se corta): ni Android ni iOS dejan que la app siga a
    // la vista durante la llamada.
    _leftCallPreparation = false;
    _pushOnce(CallPreparationScreen(
      onCall: _callAndStartTriage,
      onSkipCall: _startTriageWithoutCall,
    ));
  }

  /// Sustituye la pantalla previa a la llamada por la primera pregunta
  /// del triaje, para que "atrás" no vuelva a ofrecer llamar.
  void _replaceWithTriage() {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (_) => ConsciousnessCheckScreen(onResult: _handleConsciousnessResult),
      ),
    );
  }

  void _startTriageWithoutCall() {
    if (_leftCallPreparation) return;
    _leftCallPreparation = true;
    _replaceWithTriage();
  }

  Future<void> _callAndStartTriage() async {
    if (_leftCallPreparation) return;
    _leftCallPreparation = true;

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
    _replaceWithTriage();
  }

  void _handleConsciousnessResult(bool isConscious) {
    if (isConscious) {
      // Consciente: vamos directo al menú de tipos de emergencia.
      _pushOnce(const EmergencyMenuScreen());
    } else {
      // Inconsciente: hace falta comprobar la respiración.
      _pushOnce(BreathingCheckScreen(onResult: _handleBreathingResult));
    }
  }

  void _handleBreathingResult(BreathingStatus status) {
    _pushOnce(destinationForBreathing(status));
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
      EmergencyCallResult.simulated =>
        '🧪 Modo de pruebas: llamada simulada, no se ha marcado ningún número real.',
    };

    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}