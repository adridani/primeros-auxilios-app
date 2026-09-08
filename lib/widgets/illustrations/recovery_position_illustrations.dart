import 'package:flutter/material.dart';
import '../diagram_box.dart';

/// Posición final de la PLS: de costado, con la pierna de arriba
/// doblada en ángulo recto y la cabeza inclinada hacia atrás para
/// mantener la vía aérea abierta. Se usa en la pantalla de
/// vigilancia, como recordatorio rápido de la postura ya colocada
/// (los pasos para llegar a ella se muestran con una foto real en
/// [RecoveryPositionScreen]).
class FinalRecoveryPositionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = DiagramStyle.body(width: 4);
    final groundY = size.height * 0.78;

    canvas.drawLine(
      Offset(size.width * 0.05, groundY),
      Offset(size.width * 0.95, groundY),
      DiagramStyle.body(color: DiagramStyle.ground, width: 3),
    );

    final head = Offset(size.width * 0.22, groundY - size.height * 0.18);
    canvas.drawCircle(head, size.width * 0.07, body);

    // Cabeza inclinada hacia atrás: pequeña marca de mentón elevado.
    canvas.drawLine(
      head.translate(size.width * 0.05, size.width * 0.02),
      head.translate(size.width * 0.09, -size.width * 0.01),
      DiagramStyle.body(color: DiagramStyle.accent, width: 3),
    );

    final shoulder = Offset(head.dx + size.width * 0.08, head.dy + size.height * 0.02);
    final hip = Offset(size.width * 0.55, shoulder.dy + size.height * 0.06);
    canvas.drawLine(shoulder, hip, body);

    // Brazo cercano apoyado, mano bajo/cerca de la cara.
    canvas.drawLine(shoulder, head.translate(size.width * 0.04, size.width * 0.05), body);

    // Pierna de abajo, semi-extendida.
    canvas.drawLine(hip, Offset(size.width * 0.82, groundY), body);

    // Pierna de arriba, doblada en ángulo recto (estabiliza el cuerpo).
    final topKnee = Offset(hip.dx + size.width * 0.10, hip.dy - size.height * 0.16);
    canvas.drawLine(hip, topKnee, DiagramStyle.body(color: DiagramStyle.accent, width: 4));
    canvas.drawLine(topKnee, Offset(topKnee.dx + size.width * 0.10, topKnee.dy + size.height * 0.10),
        DiagramStyle.body(color: DiagramStyle.accent, width: 4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
