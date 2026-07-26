import 'package:flutter/foundation.dart';

/// Estado global y reactivo de "¿hay una llamada de emergencia en
/// curso?". Es deliberadamente simple: no intenta detectar el
/// estado real de la llamada telefónica (colgada, en curso,
/// rechazada...) porque eso no es algo que una app pueda saber de
/// forma fiable sin código nativo profundo (y en iOS, ni siquiera
/// así). En su lugar:
///
///   - Se activa (true) en el momento en que se INICIA el intento
///     de llamada.
///   - Se desactiva (false) cuando el propio usuario confirma que
///     la llamada ha terminado, pulsando el botón correspondiente
///     en el indicador.
///
/// Cualquier pantalla puede escuchar este notifier para mostrar
/// un indicador (por ejemplo, con un ValueListenableBuilder).
class CallStatusNotifier extends ValueNotifier<bool> {
  CallStatusNotifier() : super(false);

  void markCallStarted() {
    value = true;
  }

  void markCallEnded() {
    value = false;
  }
}

/// Instancia única compartida por toda la app.
final CallStatusNotifier callStatusNotifier = CallStatusNotifier();