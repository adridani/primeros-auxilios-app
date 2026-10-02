import 'package:flutter/material.dart';
import '../models/guide_step.dart';
import '../widgets/diagram_box.dart';
import 'cpr_guide_screen.dart';
import 'guide_sequence_screen.dart';
import 'waiting_for_help_screen.dart';

/// Guía de atragantamiento para adultos y niños mayores de 1 año
/// (víctima consciente): toser si puede, y si no, alternar 5 golpes
/// en la espalda y 5 compresiones abdominales. Si pierde el
/// conocimiento, RCP directamente. Basada en el ERC (2021).
class ChokingGuideScreen extends StatelessWidget {
  const ChokingGuideScreen({super.key});

  static const Color _accent = Colors.deepOrange;

  static final List<GuideStep> _steps = [
    GuideStep(
      title: 'Anímale a toser',
      instruction:
          'Si puede toser, hablar o respirar, anímale a toser fuerte. Todavía no le des golpes.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.record_voice_over, color: _accent),
      note: 'Esta guía es para adultos y niños mayores de 1 año.',
    ),
    GuideStep(
      title: '5 golpes en la espalda',
      instruction:
          'Si no puede toser ni respirar: ponte a su lado, inclínale hacia delante sujetándole el pecho con una mano y dale hasta 5 golpes fuertes entre los omóplatos con el talón de la otra mano.',
      illustrationBuilder: (_) =>
          const PhotoDiagramBox(assetPath: 'assets/images/choking_back_blows.jpg'),
    ),
    GuideStep(
      title: 'Coloca el puño',
      instruction:
          'Si sigue atragantado: ponte detrás, rodéale la cintura con los brazos y pon el puño cerrado entre el ombligo y el final del esternón. Agárralo con la otra mano.',
      illustrationBuilder: (_) =>
          const PhotoDiagramBox(assetPath: 'assets/images/choking_fist_position.jpg'),
    ),
    GuideStep(
      title: '5 compresiones abdominales',
      instruction: 'Tira con fuerza hacia dentro y hacia arriba, hasta 5 veces.',
      illustrationBuilder: (_) =>
          const PhotoDiagramBox(assetPath: 'assets/images/choking_abdominal_thrusts.jpg'),
      note: 'En embarazadas o personas muy obesas, aprieta en el centro del pecho en vez del abdomen.',
    ),
    GuideStep(
      title: 'Repite hasta que lo expulse',
      instruction:
          'Alterna 5 golpes en la espalda y 5 compresiones abdominales hasta que expulse el objeto o pierda el conocimiento.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.repeat, color: _accent),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GuideSequenceScreen(
      appBarTitle: 'Atragantamiento',
      accentColor: _accent,
      steps: _steps,
      finishLabel: 'Hecho',
      onFinished: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WaitingForHelpScreen(
              accentColor: _accent,
              tips: const [
                'Si no lo ha expulsado, sigue alternando 5 golpes en la espalda y 5 compresiones abdominales.',
                'Si lo expulsa, que le vea un médico igualmente: las compresiones abdominales pueden causar lesiones internas.',
              ],
              alarmQuestion: '¿Ha perdido el conocimiento?',
              alarmLabel: 'SÍ → Empezar RCP',
              noLabel: 'NO, sigue consciente',
              noMessage:
                  'Si aún no ha expulsado el objeto, sigue alternando 5 golpes en la espalda y 5 compresiones abdominales. Si lo expulsa, que la vea un médico.',
              // Atragantado e inconsciente: RCP directamente, sin
              // comprobar la respiración (indicación del ERC).
              onAlarm: (navigator) => navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const CprGuideScreen()),
              ),
            ),
          ),
        );
      },
    );
  }
}
