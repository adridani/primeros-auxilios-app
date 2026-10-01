import 'package:flutter/material.dart';
import '../models/guide_step.dart';
import '../widgets/diagram_box.dart';
import 'guide_sequence_screen.dart';
import 'waiting_for_help_screen.dart';

/// Guía de convulsiones: proteger sin sujetar, nada en la boca, y
/// controlar cuánto dura (más de 5 minutos es una emergencia). Al
/// terminar la crisis se comprueba la respiración, que lleva a la
/// posición lateral de seguridad o a la RCP.
///
/// Es StatefulWidget solo para guardar cuándo se abrió la guía: la
/// pantalla final cuenta el tiempo desde ese momento, porque lo que
/// importa es cuánto lleva la convulsión, no cuánto se tardó en leer.
class SeizureGuideScreen extends StatefulWidget {
  const SeizureGuideScreen({super.key});

  @override
  State<SeizureGuideScreen> createState() => _SeizureGuideScreenState();
}

class _SeizureGuideScreenState extends State<SeizureGuideScreen> {
  static const Color _accent = Colors.amber;

  // Sin `late`: así se fija al crear la pantalla. Con `late` se
  // calcularía la primera vez que se lee (al terminar la guía) y el
  // contador de la crisis empezaría tarde.
  final DateTime _openedAt = DateTime.now();

  static final List<GuideStep> _steps = [
    GuideStep(
      title: 'Protégela de golpes',
      instruction:
          'No intentes sujetarla. Aparta muebles y objetos con los que se pueda golpear y pon algo blando bajo su cabeza.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.shield, color: _accent),
    ),
    GuideStep(
      title: 'Nada en la boca',
      instruction:
          'No le metas nada en la boca, ni tus dedos ni objetos, y no le des de beber. No se va a tragar la lengua.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.do_not_touch, color: _accent),
    ),
    GuideStep(
      title: 'Controla el tiempo',
      instruction:
          'La app cuenta el tiempo desde que abriste esta guía. Si la convulsión dura más de 5 minutos, o le da otra seguida, díselo a emergencias.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.timer, color: _accent),
    ),
    GuideStep(
      title: 'Cuando pare, mira si respira',
      instruction:
          'Al terminar suele quedarse adormilada y confusa. Comprueba si respira con normalidad: si respira, ponla de lado.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.air, color: _accent),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GuideSequenceScreen(
      appBarTitle: 'Convulsión',
      accentColor: _accent,
      steps: _steps,
      finishLabel: 'Hecho',
      onFinished: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WaitingForHelpScreen(
              accentColor: _accent,
              startedAt: _openedAt,
              warnAfter: const Duration(minutes: 5),
              warnText: 'Más de 5 minutos: avisa a emergencias.',
              tips: const [
                'No la sujetes: deja que la convulsión pase y protege su cabeza.',
                'Fíjate en el tiempo de arriba: si pasa de 5 minutos, avisa a emergencias.',
                'Cuando termine, quédate a su lado y háblale con calma; es normal que esté confusa.',
              ],
              alarmQuestion: '¿Ha terminado la convulsión?',
              alarmLabel: 'SÍ → Comprobar si respira',
              onAlarm: WaitingForHelpScreen.checkBreathing,
            ),
          ),
        );
      },
    );
  }
}
