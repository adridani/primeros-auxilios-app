import 'package:flutter/material.dart';
import '../models/guide_step.dart';
import '../widgets/diagram_box.dart';
import 'bleeding_guide_screen.dart';
import 'guide_sequence_screen.dart';
import 'waiting_for_help_screen.dart';

/// Guía de fractura o esguince: no mover ni enderezar, inmovilizar en
/// la posición encontrada, cubrir heridas y aplicar frío. Si sangra
/// mucho, el aviso de abajo lleva a la guía de hemorragia.
class FractureGuideScreen extends StatelessWidget {
  const FractureGuideScreen({super.key});

  static const Color _accent = Colors.blueGrey;

  static final List<GuideStep> _steps = [
    GuideStep(
      title: 'Que no la mueva',
      instruction:
          'Que no mueva la zona lesionada. No intentes enderezar el hueso ni recolocar la articulación.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.pan_tool, color: Colors.blueGrey),
      note:
          'Si puede haberse lesionado el cuello o la espalda (caída desde altura, accidente de tráfico), no la muevas en absoluto salvo peligro inmediato.',
    ),
    GuideStep(
      title: 'Inmoviliza como esté',
      instruction:
          'Sujeta la zona en la posición en que la encuentres, con cojines, ropa doblada o tus manos. Un brazo se puede sujetar contra el pecho con un pañuelo o cabestrillo.',
      illustrationBuilder: (_) =>
          const PhotoDiagramBox(assetPath: 'assets/images/fracture_arm_sling.jpg'),
    ),
    GuideStep(
      title: 'Si hay herida, cúbrela',
      instruction:
          'Si el hueso asoma o hay herida, tápala con un paño limpio. Si sangra, aprieta alrededor del hueso, nunca encima.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.healing, color: Colors.blueGrey),
    ),
    GuideStep(
      title: 'Pon frío',
      instruction:
          'Pon hielo o una bolsa congelada envuelta en un paño sobre la zona unos 20 minutos, para el dolor y la hinchazón.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.ac_unit, color: Colors.lightBlueAccent),
      note: 'Nunca el hielo directamente sobre la piel.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GuideSequenceScreen(
      appBarTitle: 'Fractura o esguince',
      accentColor: _accent,
      steps: _steps,
      finishLabel: 'Hecho',
      onFinished: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WaitingForHelpScreen(
              accentColor: _accent,
              tips: const [
                'Mantén la zona inmovilizada y que no intente andar ni usarla.',
                'Quita anillos o relojes de esa mano o pie antes de que se hinche.',
                'No le des de comer ni de beber, por si necesita una operación.',
              ],
              alarmQuestion: '¿Sangra mucho?',
              alarmLabel: 'SÍ → Guía de hemorragia',
              noLabel: 'NO',
              noMessage: 'Bien. Mantén la zona inmovilizada y vigila si empieza a sangrar. Si sangra mucho, pulsa SÍ.',
              onAlarm: (navigator) => navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const BleedingGuideScreen()),
              ),
            ),
          ),
        );
      },
    );
  }
}
