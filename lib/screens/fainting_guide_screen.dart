import 'package:flutter/material.dart';
import '../models/guide_step.dart';
import '../widgets/diagram_box.dart';
import 'guide_sequence_screen.dart';
import 'waiting_for_help_screen.dart';

/// Guía de desmayo o mareo: el menú de emergencias solo se ve con la
/// víctima consciente, así que esto cubre a quien se nota a punto de
/// desmayarse o acaba de hacerlo y vuelve en sí. Si no despierta, el
/// aviso de abajo lleva a comprobar la respiración.
class FaintingGuideScreen extends StatelessWidget {
  const FaintingGuideScreen({super.key});

  static const Color _accent = Colors.orange;

  static final List<GuideStep> _steps = [
    GuideStep(
      title: 'Túmbala boca arriba',
      instruction:
          'Si se ha desmayado o se nota a punto de hacerlo, ayúdala a tumbarse en el suelo para que no se caiga ni se golpee.',
      illustrationBuilder: (_) =>
          const PhotoDiagramBox(assetPath: 'assets/images/cpr_lying_supine.jpg'),
    ),
    GuideStep(
      title: 'Levántale las piernas',
      instruction:
          'Eleva sus piernas unos 30 cm (sobre una silla, una mochila…) para que llegue más sangre a la cabeza.',
      illustrationBuilder: (_) =>
          const IconDiagramBox(icon: Icons.airline_seat_legroom_extra, color: _accent),
    ),
    GuideStep(
      title: 'Afloja la ropa y dale aire',
      instruction:
          'Afloja el cinturón, la corbata o el cuello de la camisa. Aparta a la gente y, si hace calor, llévala a la sombra.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.air, color: _accent),
    ),
    GuideStep(
      title: 'Que se recupere despacio',
      instruction:
          'Debería volver en sí en 1 o 2 minutos. Que se incorpore poco a poco y no le des de beber hasta que esté bien despierta.',
      illustrationBuilder: (_) => const IconDiagramBox(icon: Icons.self_improvement, color: _accent),
      note: 'Si es diabética y está consciente, puede tomar algo con azúcar.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GuideSequenceScreen(
      appBarTitle: 'Desmayo o mareo',
      accentColor: _accent,
      steps: _steps,
      finishLabel: 'Hecho',
      onFinished: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const WaitingForHelpScreen(
              accentColor: _accent,
              tips: [
                'Mantenla tumbada con las piernas en alto hasta que se encuentre bien.',
                'Avisa a emergencias si tarda más de 1-2 minutos en recuperarse, se vuelve a desmayar, o tiene dolor en el pecho, palpitaciones o dificultad para hablar.',
                'Si se ha golpeado al caer, revisa si tiene alguna herida.',
              ],
              alarmQuestion: '¿No despierta o ha dejado de responder?',
              alarmLabel: 'SÍ → Comprobar si respira',
              onAlarm: WaitingForHelpScreen.checkBreathing,
            ),
          ),
        );
      },
    );
  }
}
