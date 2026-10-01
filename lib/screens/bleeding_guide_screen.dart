import 'package:flutter/material.dart';
import '../models/guide_step.dart';
import '../widgets/diagram_box.dart';
import 'guide_sequence_screen.dart';
import 'waiting_for_help_screen.dart';

/// Guía de hemorragia grave (víctima consciente). Lo esencial es la
/// presión directa y continua sobre la herida; el torniquete solo
/// para sangrado a chorro de un brazo o pierna que no para con
/// presión. Basada en las recomendaciones de primeros auxilios del
/// ERC (2021).
class BleedingGuideScreen extends StatelessWidget {
  const BleedingGuideScreen({super.key});

  static const Color _accent = Colors.redAccent;

  static final List<GuideStep> _steps = [
    GuideStep(
      title: 'Protégete',
      instruction:
          'Si tienes guantes, póntelos. Si no, usa una bolsa de plástico o una prenda entre tu mano y la sangre.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.front_hand, color: _accent),
    ),
    GuideStep(
      title: 'Aprieta fuerte la herida',
      instruction:
          'Pon una gasa, un trapo o una prenda limpia sobre la herida y aprieta fuerte con la palma de la mano, sin soltar.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.compress, color: _accent),
      note: 'Si hay un objeto clavado, no lo saques: aprieta alrededor.',
    ),
    GuideStep(
      title: 'No levantes el trapo',
      instruction:
          'Si se empapa, pon otro encima y sigue apretando. No lo levantes para mirar: mantén la presión sin parar.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.layers, color: _accent),
    ),
    GuideStep(
      title: 'Si sangra a chorro y no para',
      instruction:
          'Solo en brazo o pierna: si tienes un torniquete, ponlo unos 5-7 cm por encima de la herida (nunca sobre una articulación) y apriétalo hasta que deje de sangrar. Apunta la hora.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.timer, color: _accent),
      note:
          'Si no tienes torniquete, sigue apretando la herida con todas tus fuerzas: los improvisados (cinturón, cuerda) no suelen funcionar.',
    ),
    GuideStep(
      title: 'Túmbala y abrígala',
      instruction:
          'Que se tumbe en el suelo y tápala con una manta o un abrigo para que no pierda calor. No le des de comer ni de beber.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.airline_seat_flat, color: _accent),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GuideSequenceScreen(
      appBarTitle: 'Hemorragia grave',
      accentColor: _accent,
      steps: _steps,
      finishLabel: 'Hecho',
      onFinished: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const WaitingForHelpScreen(
              accentColor: _accent,
              tips: [
                'Sigue apretando la herida sin soltar hasta que llegue la ayuda.',
                'Si el trapo se empapa, pon otro encima; no quites el primero.',
                'Si se pone pálida, fría, sudorosa o confusa puede estar entrando en shock: mantenla tumbada y abrigada.',
                'Si pusiste un torniquete, no lo aflojes y di a qué hora lo pusiste.',
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
