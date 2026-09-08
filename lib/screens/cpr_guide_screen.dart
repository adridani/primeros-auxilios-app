import 'package:flutter/material.dart';
import '../models/guide_step.dart';
import '../widgets/diagram_box.dart';
import '../widgets/illustrations/cpr_illustrations.dart';
import 'cpr_compression_screen.dart';
import 'guide_sequence_screen.dart';

/// Punto de entrada a la guía de RCP: primero los pasos de
/// preparación (tumbar, arrodillarse, colocar las manos), y al
/// terminar pasa a la pantalla interactiva de compresiones
/// ([CprCompressionScreen]), que es donde de verdad se cuenta el
/// ritmo y se repiten los ciclos.
class CprGuideScreen extends StatelessWidget {
  const CprGuideScreen({super.key});

  static final List<GuideStep> _setupSteps = [
    GuideStep(
      title: 'Túmbala boca arriba',
      instruction:
          'Coloca a la víctima boca arriba sobre una superficie plana y dura (el suelo, no una cama).',
      illustrationBuilder: (_) => DiagramBox(painter: LyingFlatPainter()),
    ),
    GuideStep(
      title: 'Arrodíllate a su lado',
      instruction:
          'Ponte de rodillas junto a su pecho, para poder empujar hacia abajo con los brazos rectos.',
      illustrationBuilder: (_) => DiagramBox(painter: KneelingBesidePainter()),
    ),
    GuideStep(
      title: 'Coloca las manos',
      instruction:
          'Pon el talón de una mano en el centro del pecho (mitad inferior del esternón). Coloca la otra mano encima y entrelaza los dedos.',
      illustrationBuilder: (_) =>
          const PhotoDiagramBox(assetPath: 'assets/images/cpr_hand_placement.jpg'),
      note: 'Los dedos no deben tocar las costillas, solo el esternón.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GuideSequenceScreen(
      appBarTitle: 'RCP',
      accentColor: Colors.red,
      steps: _setupSteps,
      finishLabel: 'Empezar compresiones',
      onFinished: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CprCompressionScreen()),
        );
      },
    );
  }
}
