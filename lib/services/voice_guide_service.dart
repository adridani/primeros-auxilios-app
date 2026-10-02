import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:volume_controller/volume_controller.dart';

/// Orden de voz reconocida mientras se escucha tras leer un paso.
enum VoiceCommand { next, repeat, none }

/// Lee instrucciones en voz alta y escucha el comando "siguiente"
/// (o "repite", para volver a oír el paso)
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
  bool _volumeRaised = false;
  bool _sttInitialized = false;
  bool _sttAvailable = false;

  // Sin tildes: lo reconocido se compara ya sin tildes (ver
  // [_normalize]), porque el reconocedor a veces las pone y a veces no.
  static const List<String> _nextKeywords = [
    'siguiente',
    'continuar',
    'continua',
    'adelante',
    'vale',
  ];

  static const List<String> _repeatKeywords = [
    'repite',
    'repetir',
    'repitelo',
    'repitemelo',
    'otra vez',
    'de nuevo',
    'no te he entendido',
    'no he entendido',
  ];

  /// Velocidad de la voz, un poco más rápida que la normal: cada
  /// plataforma interpreta el valor a su manera (antes se usaba 0.48
  /// en todas, que en el navegador es la MITAD de la velocidad normal).
  ///  - Web: 1.0 es la velocidad normal.
  ///  - Android: el plugin lo multiplica por 2, y 1.0 es lo normal.
  ///  - iOS: 0.5 es la velocidad normal del sistema.
  static double get _speechRate {
    if (kIsWeb) return 1.1;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 0.55,
      TargetPlatform.iOS || TargetPlatform.macOS => 0.53,
      _ => 0.55,
    };
  }

  Future<void> _ensureTtsReady() async {
    if (_ttsReady) return;
    try {
      await _tts.setLanguage('es-ES');
      await _chooseBestSpanishVoice();
      await _tts.setSpeechRate(_speechRate);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      _ttsReady = true;
    } catch (_) {
      // Sin voz disponible: speak() simplemente no dirá nada.
    }
  }

  /// Elige la mejor voz en español instalada, en vez de la que el
  /// sistema da por defecto (a veces una voz básica y robótica, o de
  /// otro país). Prioriza: castellano de España, calidad alta y que
  /// funcione sin internet (en una emergencia puede no haber
  /// cobertura). Si no hay lista de voces, se queda la del sistema.
  Future<void> _chooseBestSpanishVoice() async {
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) return;
      Map<String, String>? best;
      var bestScore = -1;
      for (final raw in voices) {
        if (raw is! Map) continue;
        final voice = raw.map((k, v) => MapEntry('$k', '$v'));
        final locale = (voice['locale'] ?? '').toLowerCase().replaceAll('_', '-');
        if (!locale.startsWith('es')) continue;
        // Android lista también voces que no están descargadas (con
        // "notInstalled" en sus características): si se elige una de
        // esas, el motor se queda esperando y no dice nada.
        if ((voice['features'] ?? '').contains('notInstalled')) continue;
        final name = (voice['name'] ?? '').toLowerCase();
        final quality = (voice['quality'] ?? '').toLowerCase();
        var score = 0;
        if (locale == 'es-es') score += 10;
        if (quality.contains('very high') || quality.contains('premium')) score += 5;
        if (quality == 'high' || quality.contains('enhanced')) score += 3;
        if (name.contains('natural') || name.contains('neural')) score += 3;
        if (name.contains('google')) score += 2;
        if (voice['network_required'] == '1' || name.contains('online')) score -= 4;
        if (score > bestScore) {
          bestScore = score;
          best = voice;
        }
      }
      if (best != null) {
        await _tts.setVoice({'name': best['name'] ?? '', 'locale': best['locale'] ?? ''});
      }
    } catch (_) {
      // Sin lista de voces (o fallo al elegir): se usa la del sistema.
    }
  }

  static String _normalize(String text) => text
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');

  /// Sube el volumen del sistema al máximo (y quita el silencio) la
  /// primera vez que la app va a hablar, para que las instrucciones
  /// se oigan aunque el móvil estuviera bajo o en silencio.
  ///
  /// Solo se hace una vez: si después el usuario baja el volumen a
  /// propósito, no se lo volvemos a subir en cada instrucción. En web
  /// (y donde el plugin no esté disponible) falla en silencio.
  Future<void> _raiseVolumeOnce() async {
    if (_volumeRaised) return;
    _volumeRaised = true;
    try {
      await VolumeController.instance.setMute(false);
    } catch (_) {}
    try {
      await VolumeController.instance.setVolume(1.0);
    } catch (_) {}
  }

  /// Lee [text] en voz alta y espera a que termine (o falle).
  Future<void> speak(String text) async {
    await _ensureTtsReady();
    if (!_ttsReady) return;
    await _raiseVolumeOnce();
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

  /// Escucha durante un rato corto esperando oír "siguiente" o
  /// "repite" (o algún sinónimo) y devuelve qué orden ha detectado.
  ///
  /// Pide el permiso de micrófono la primera vez que se llama; si se
  /// deniega, devuelve [VoiceCommand.none] sin más (y no lo vuelve a
  /// pedir cada vez, para no ser pesados).
  Future<VoiceCommand> listenForCommand({Duration timeout = const Duration(seconds: 7)}) async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) return VoiceCommand.none;

    if (!_sttInitialized) {
      _sttInitialized = true;
      try {
        _sttAvailable = await _speech.initialize();
      } catch (_) {
        _sttAvailable = false;
      }
    }
    if (!_sttAvailable) return VoiceCommand.none;

    String lastWords = '';
    try {
      await _speech.listen(
        onResult: (result) => lastWords = _normalize(result.recognizedWords),
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          localeId: 'es_ES',
          listenFor: timeout,
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      return VoiceCommand.none;
    }

    // `listen()` no espera a que termine de escuchar; hay que sondear
    // hasta que el propio plugin pare (por silencio o por límite).
    while (_speech.isListening) {
      await Future.delayed(const Duration(milliseconds: 150));
    }

    return commandFromWords(lastWords);
  }

  /// Traduce lo reconocido a una orden. "Repite" gana si aparecen las
  /// dos (por ejemplo "no, repite"): volver a oír el paso es inofensivo,
  /// saltárselo sin haberlo entendido no.
  static VoiceCommand commandFromWords(String words) {
    final text = _normalize(words);
    if (_repeatKeywords.any(text.contains)) return VoiceCommand.repeat;
    if (_nextKeywords.any(text.contains)) return VoiceCommand.next;
    return VoiceCommand.none;
  }

  /// Corta cualquier escucha en curso (por ejemplo, al salir de la
  /// pantalla o al pulsar el botón manualmente).
  void cancelListening() {
    try {
      _speech.stop();
    } catch (_) {}
  }
}
