import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Lee instrucciones en voz alta y escucha el comando "siguiente"
/// para poder avanzar de paso con las manos ocupadas (justo el caso
/// típico de estar haciendo RCP o colocando a alguien de lado).
///
/// Es deliberadamente "best effort": si el dispositivo no tiene voz
/// en español, si el usuario niega el permiso del micrófono, o si el
/// reconocimiento de voz falla por cualquier motivo, todo esto se
/// traga en silencio y el botón manual de "Siguiente" sigue
/// funcionando exactamente igual. La voz es una ayuda, nunca un
/// requisito para poder usar la app.
class VoiceGuideService {
  VoiceGuideService._internal();

  static final VoiceGuideService instance = VoiceGuideService._internal();

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _ttsReady = false;
  bool _sttInitialized = false;
  bool _sttAvailable = false;

  static const List<String> _nextKeywords = [
    'siguiente',
    'continuar',
    'continúa',
    'adelante',
    'vale',
  ];

  Future<void> _ensureTtsReady() async {
    if (_ttsReady) return;
    try {
      await _tts.setLanguage('es-ES');
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.0);
      _ttsReady = true;
    } catch (_) {
      // Sin voz disponible: speak() simplemente no dirá nada.
    }
  }

  /// Lee [text] en voz alta y espera a que termine (o falle).
  Future<void> speak(String text) async {
    await _ensureTtsReady();
    if (!_ttsReady) return;
    try {
      await _tts.stop();
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak(text);
    } catch (_) {
      // Igual que arriba: un fallo aquí no debe romper nada más.
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  /// Escucha durante un rato corto esperando oír "siguiente" (o algún
  /// sinónimo). Devuelve `true` si lo ha detectado.
  ///
  /// Pide el permiso de micrófono la primera vez que se llama; si se
  /// deniega, devuelve `false` sin más (y no lo vuelve a pedir cada
  /// vez, para no ser pesados).
  Future<bool> listenForNext({Duration timeout = const Duration(seconds: 7)}) async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) return false;

    if (!_sttInitialized) {
      _sttInitialized = true;
      try {
        _sttAvailable = await _speech.initialize();
      } catch (_) {
        _sttAvailable = false;
      }
    }
    if (!_sttAvailable) return false;

    String lastWords = '';
    try {
      await _speech.listen(
        onResult: (result) => lastWords = result.recognizedWords.toLowerCase(),
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          localeId: 'es_ES',
          listenFor: timeout,
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      return false;
    }

    // `listen()` no espera a que termine de escuchar; hay que sondear
    // hasta que el propio plugin pare (por silencio o por límite).
    while (_speech.isListening) {
      await Future.delayed(const Duration(milliseconds: 150));
    }

    return _nextKeywords.any((k) => lastWords.contains(k));
  }

  /// Corta cualquier escucha en curso (por ejemplo, al salir de la
  /// pantalla o al pulsar el botón manualmente).
  void cancelListening() {
    try {
      _speech.stop();
    } catch (_) {}
  }
}
