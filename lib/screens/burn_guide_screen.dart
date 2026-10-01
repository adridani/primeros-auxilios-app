import 'package:flutter/material.dart';
import '../models/guide_step.dart';
import '../widgets/diagram_box.dart';
import 'guide_sequence_screen.dart';
import 'waiting_for_help_screen.dart';

/// Guía de quemaduras: alejar del origen, enfriar con agua al menos
/// 20 minutos (sin hielo), quitar anillos/ropa y cubrir sin cremas.
/// Basada en el ERC (2021).
class BurnGuideScreen extends StatelessWidget {
  const BurnGuideScreen({super.key});

  static const Color _accent = Colors.deepOrangeAccent;

  static final List<GuideStep> _steps = [
    GuideStep(
      title: 'Aléjala del peligro',
      instruction:
          'Apaga las llamas: que se tire al suelo y ruede, o cúbrela con una manta. Si es por electricidad, corta la corriente antes de tocarla.',
      illustrationBuilder: (_) =>
          const IconDiagramBox(icon: Icons.local_fire_department, color: _accent),
    ),
    GuideStep(
      title: 'Enfría con agua 20 minutos',
      instruction:
          'Pon la quemadura bajo el grifo, con agua fresca o templada, durante al menos 20 minutos. Cuanto antes empieces, mejor.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.water_drop, color: Colors.lightBlueAccent),
      note: 'Nunca hielo ni agua helada.',
    ),
    GuideStep(
      title: 'Quita anillos y ropa',
      instruction:
          'Mientras enfrías, quita anillos, relojes y ropa de la zona antes de que se hinche. Si la ropa está pegada a la piel, no la arranques.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.watch_off, color: _accent),
    ),
    GuideStep(
      title: 'Cúbrela sin apretar',
      instruction:
          'Tápala con film transparente o un paño limpio que no suelte pelusa. No pongas cremas, pasta de dientes, aceite ni mantequilla.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.healing, color: _accent),
      note: 'No revientes las ampollas.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GuideSequenceScreen(
      appBarTitle: 'Quemadura',
      accentColor: _accent,
      steps: _steps,
      finishLabel: 'Hecho',
      onFinished: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const WaitingForHelpScreen(
              accentColor: _accent,
              tips: [
                'Si aún no han pasado 20 minutos, sigue enfriando con agua.',
                'Abriga el resto del cuerpo: al enfriar una quemadura grande puede coger frío.',
                'Si es por un producto químico, lava con mucha agua corriente durante más tiempo y quita la ropa manchada.',
                'Necesita atención médica si la quemadura es grande o afecta a cara, manos, pies, genitales o articulaciones.',
              ],
              alarmQuestion: '¿Ha dejado de responder?',
              alarmLabel: 'SÍ → Comprobar si respira',
              onAlarm: WaitingForHelpScreen.checkBreathing,
            ),
          ),
        );
      },
    );
  }
}
