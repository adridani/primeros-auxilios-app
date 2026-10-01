import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../diagram_box.dart';

/// Ilustraciones vectoriales usadas en la guía de RCP. Es un diagrama
/// deliberadamente simple (figuras de líneas) porque necesita animarse
/// al ritmo de las compresiones, algo que una imagen fija no puede
/// hacer; los demás pasos usan imágenes libres (ver assets/images).
///
/// Dibuja sobre `size` (el tamaño real del [DiagramBox]), usando
/// fracciones de `size.width`/`size.height` para adaptarse a cualquier
/// tamaño de pantalla.

/// Movimiento de la compresión, animado: las manos bajan y suben
/// según [progress] (0 = arriba, 1 = abajo del todo), para que sirva
/// como metrónomo visual al ritmo real de la RCP en vez de un dibujo
/// estático. Quien la use no tiene que tocar nada: solo comprimir
/// cuando las manos del dibujo llegan abajo.
class CompressionMotionPainter extends CustomPainter {
  final double progress;

  CompressionMotionPainter({this.progress = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final body = DiagramStyle.body();
    final chestRect = Rect.fromCenter(
      center: Offset(size.width * 0.42, size.height * 0.6),
      width: size.width * 0.5,
      height: size.height * 0.4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(chestRect, const Radius.circular(24)),
      body,
    );

    final point = chestRect.center;

    // Posición "arriba" (brazos estirados) y "abajo" (comprimiendo);
    // las manos se interpolan entre las dos según el progreso actual.
    final upHands = point.translate(0, -size.height * 0.22);
    final downHands = point.translate(0, -size.height * 0.02);
    final hands = Offset.lerp(upHands, downHands, progress)!;

    // Marca tenue de referencia en la posición "arriba".
    canvas.drawLine(
      upHands.translate(0, -2),
      upHands.translate(0, 14),
      DiagramStyle.body(color: Colors.white24, width: 2),
    );

    // Manos: más grandes y en color de acento cuanto más abajo están,
    // para reforzar visualmente el momento exacto de comprimir.
    final handRadius = size.width * (0.035 + 0.02 * progress);
    canvas.drawCircle(
      hands,
      handRadius,
      DiagramStyle.fill(Color.lerp(Colors.white38, DiagramStyle.accent, progress)!),
    );

    // Flecha de referencia arriba-abajo indicando el recorrido.
    final arrowPaint = DiagramStyle.body(color: DiagramStyle.accent, width: 4);
    final arrowTop = Offset(size.width * 0.78, size.height * 0.28);
    final arrowBottom = Offset(size.width * 0.78, size.height * 0.72);
    canvas.drawLine(arrowTop, arrowBottom, arrowPaint);
    _drawArrowHead(canvas, arrowBottom, math.pi / 2, arrowPaint);
    _drawArrowHead(canvas, arrowTop, -math.pi / 2, arrowPaint);

    // Brazos rectos desde arriba de la pantalla hasta las manos.
    canvas.drawLine(Offset(point.dx, 6), hands, body);
  }

  void _drawArrowHead(Canvas canvas, Offset tip, double angle, Paint paint) {
    const double length = 10;
    final p1 = tip +
        Offset(math.cos(angle + 2.6) * length, math.sin(angle + 2.6) * length);
    final p2 = tip +
        Offset(math.cos(angle - 2.6) * length, math.sin(angle - 2.6) * length);
    canvas.drawLine(tip, p1, paint);
    canvas.drawLine(tip, p2, paint);
  }

  @override
  bool shouldRepaint(covariant CompressionMotionPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
