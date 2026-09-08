import 'package:flutter/material.dart';
import '../models/guide_step.dart';
import '../widgets/diagram_box.dart';
import 'guide_sequence_screen.dart';
import 'recovery_monitoring_screen.dart';

/// Muestra la imagen de referencia con los 5 pasos de la PLS (todos
/// juntos, numerados) y resalta con una flecha a qué número
/// corresponde el paso actual, para no tener que recortar la imagen
/// en 5 pedazos.
Widget _recoveryReferenceImage(int stepNumber) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const PhotoDiagramBox(
        assetPath: 'assets/images/recovery_position_steps.png',
        height: 260,
      ),
      const SizedBox(height: 6),
      Text(
        '👉 Toca la imagen para ampliarla y busca el paso número $stepNumber.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 2),
      const Text(
        'Imagen: Hibernate / Wikimedia Commons (CC BY-SA 3.0)',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white24, fontSize: 10),
      ),
    ],
  );
}

/// Guía de la posición lateral de seguridad (PLS): se usa cuando la
/// víctima está inconsciente pero SÍ respira con normalidad. Al
/// terminar la secuencia pasa a [RecoveryMonitoringScreen], donde se
/// vigila la respiración de forma continua.
class RecoveryPositionScreen extends StatelessWidget {
  const RecoveryPositionScreen({super.key});

  static final List<GuideStep> _steps = [
    GuideStep(
      title: 'Estira el brazo cercano',
      instruction:
          'Arrodíllate a su lado. Estira el brazo más cercano a ti en ángulo recto con el cuerpo, con la palma hacia arriba.',
      illustrationBuilder: (_) => _recoveryReferenceImage(1),
    ),
    GuideStep(
      title: 'Mano en la mejilla',
      instruction:
          'Coge el brazo más alejado y crúzalo sobre el pecho. Apoya el dorso de su mano contra la mejilla más cercana a ti y sujétala ahí.',
      illustrationBuilder: (_) => _recoveryReferenceImage(2),
    ),
    GuideStep(
      title: 'Dobla la rodilla lejana',
      instruction:
          'Con tu otra mano, agarra la pierna más alejada por encima de la rodilla y dóblala, dejando el pie apoyado en el suelo.',
      illustrationBuilder: (_) => _recoveryReferenceImage(3),
    ),
    GuideStep(
      title: 'Gírala hacia ti',
      instruction:
          'Tira de la rodilla doblada para hacer rodar a la víctima de costado, hacia ti, sujetando la mano contra la mejilla.',
      illustrationBuilder: (_) => _recoveryReferenceImage(4),
    ),
    GuideStep(
      title: 'Ajusta la postura final',
      instruction:
          'Dobla la pierna de arriba en ángulo recto para que quede estable. Inclina su cabeza hacia atrás para mantener la vía aérea abierta.',
      illustrationBuilder: (_) => _recoveryReferenceImage(5),
      note: 'Comprueba que sigue respirando con normalidad.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GuideSequenceScreen(
      appBarTitle: 'Posición lateral de seguridad',
      accentColor: Colors.orange,
      steps: _steps,
      finishLabel: 'Ya está colocada',
      onFinished: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RecoveryMonitoringScreen()),
        );
      },
    );
  }
}
