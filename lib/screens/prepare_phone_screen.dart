import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/voice_guide_service.dart';

/// "Prepara tu móvil": ajustes que conviene dejar hechos ANTES de una
/// emergencia, porque la app no puede hacerlos por sí sola:
///  - Altavoz automático en las llamadas (ninguna app puede poner el
///    altavoz de una llamada normal).
///  - Permisos de llamada y micrófono, para que no se pregunten en
///    plena emergencia.
///  - Una voz en español de buena calidad para las instrucciones.
///
/// Se abre desde un enlace discreto en la primera pantalla; no forma
/// parte del flujo de una emergencia.
class PreparePhoneScreen extends StatefulWidget {
  const PreparePhoneScreen({super.key});

  @override
  State<PreparePhoneScreen> createState() => _PreparePhoneScreenState();
}

class _PreparePhoneScreenState extends State<PreparePhoneScreen> {
  static bool get _isIOS =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS);
  static bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  String? _permissionsResult;

  @override
  void dispose() {
    VoiceGuideService.instance.stopSpeaking();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    final permissions = [
      if (_isAndroid) Permission.phone,
      Permission.microphone,
      if (_isIOS) Permission.speech,
    ];
    try {
      final results = await permissions.request();
      final allGranted = results.values.every((s) => s.isGranted);
      setState(() {
        _permissionsResult = allGranted
            ? '✅ Permisos concedidos.'
            : '⚠️ Falta algún permiso. Puedes darlo en los ajustes del móvil, en el apartado de esta app.';
      });
    } catch (_) {
      setState(() => _permissionsResult = 'Este dispositivo no permite pedir permisos desde aquí.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final speakerSteps = <String>[
      if (_isIOS || !_isAndroid)
        'iPhone: Ajustes → Accesibilidad → Tocar → Enrutamiento de audio de llamadas → Altavoz.',
      if (_isAndroid || !_isIOS)
        'Android: depende del fabricante. Busca «altavoz» en los ajustes de la app Teléfono (en algunos móviles está en Accesibilidad). No todos los móviles lo tienen.',
    ];
    final voiceSteps = <String>[
      if (_isIOS || !_isAndroid)
        'iPhone: Ajustes → Accesibilidad → Contenido leído → Voces → Español (España), y descarga una voz «mejorada» o «premium».',
      if (_isAndroid || !_isIOS)
        'Android: Ajustes → busca «Salida de texto a voz» → elige el motor de Google → Instalar datos de voz → Español (España).',
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('Prepara tu móvil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Hazlo ahora con calma: en una emergencia no habrá tiempo.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            _Section(
              icon: Icons.volume_up,
              title: 'Altavoz automático en las llamadas',
              text:
                  'Al llamar al 112 tendrás que volver a esta app para ver las instrucciones. Con el altavoz automático podrás hablar sin sujetar el teléfono.',
              steps: speakerSteps,
            ),
            _Section(
              icon: Icons.verified_user,
              title: 'Permisos',
              text: _isAndroid
                  ? 'Permite ya que la app llame y use el micrófono (para decir «siguiente» o «repite»), así no te lo preguntará en plena emergencia.'
                  : 'Permite ya que la app use el micrófono (para decir «siguiente» o «repite»), así no te lo preguntará en plena emergencia.',
              action: OutlinedButton.icon(
                onPressed: _requestPermissions,
                icon: const Icon(Icons.check),
                label: const Text('Dar permisos ahora'),
              ),
              result: _permissionsResult,
            ),
            _Section(
              icon: Icons.record_voice_over,
              title: 'Voz de las instrucciones',
              text:
                  'La app lee las instrucciones con la mejor voz en español que tenga el móvil. Si suena robótica, instala una de mejor calidad:',
              steps: voiceSteps,
              action: OutlinedButton.icon(
                onPressed: () => VoiceGuideService.instance.speak(
                  'Hola. Así sonarán las instrucciones en una emergencia. Coloca a la víctima boca arriba sobre una superficie dura.',
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Probar la voz'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final List<String> steps;
  final Widget? action;
  final String? result;

  const _Section({
    required this.icon,
    required this.title,
    required this.text,
    this.steps = const [],
    this.action,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.amberAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4)),
          for (final step in steps) ...[
            const SizedBox(height: 8),
            Text('• $step', style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
          ],
          if (action != null) ...[
            const SizedBox(height: 12),
            action!,
          ],
          if (result != null) ...[
            const SizedBox(height: 8),
            Text(result!, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ],
      ),
    );
  }
}
