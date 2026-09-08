import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../diagram_box.dart';

/// Ilustraciones vectoriales usadas en la guía de RCP. Son diagramas
/// deliberadamente simples (figuras de líneas) en vez de fotos: no hay
/// fotos reales en el proyecto y así se mantiene consistencia visual
/// con el resto de la app (tema oscuro).
///
/// Todas dibujan sobre `size` (el tamaño real del [DiagramBox]), usando
/// fracciones de `size.width`/`size.height` para adaptarse a cualquier
/// tamaño de pantalla.

/// Víctima tumbada boca arriba sobre una superficie plana y dura.
class LyingFlatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = DiagramStyle.body();
    final groundY = size.height * 0.75;

    // Superficie dura.
    canvas.drawLine(
      Offset(size.width * 0.08, groundY),
      Offset(size.width * 0.92, groundY),
      DiagramStyle.body(color: DiagramStyle.ground, width: 3),
    );

    final headCenter = Offset(size.width * 0.22, groundY - size.height * 0.10);
    canvas.drawCircle(headCenter, size.width * 0.07, body);

    // Torso.
    final torsoStart = Offset(headCenter.dx + size.width * 0.07, headCenter.dy);
    final torsoEnd = Offset(size.width * 0.62, headCenter.dy);
    canvas.drawLine(torsoStart, torsoEnd, body);

    // Piernas (ligeramente separadas).
    canvas.drawLine(torsoEnd, Offset(size.width * 0.85, headCenter.dy - 10), body);
    canvas.drawLine(torsoEnd, Offset(size.width * 0.85, headCenter.dy + 10), body);

    // Brazos a los lados, relajados.
    canvas.drawLine(
      Offset(size.width * 0.32, headCenter.dy),
      Offset(size.width * 0.30, headCenter.dy + size.height * 0.14),
      body,
    );
    canvas.drawLine(
      Offset(size.width * 0.48, headCenter.dy),
      Offset(size.width * 0.50, headCenter.dy - size.height * 0.14),
      body,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Reanimador arrodillado junto al pecho de la víctima.
class KneelingBesidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Unidad basada en el lado más corto: evita que la figura se
    // deforme o se salga del recuadro cuando este es más ancho que
    // alto (o viceversa).
    final u = size.width < size.height ? size.width : size.height;
    final victimPaint = DiagramStyle.body(color: Colors.white38, width: 2.5);
    final rescuerPaint = DiagramStyle.body(color: DiagramStyle.accent, width: 3.5);
    final groundY = size.height * 0.85;

    canvas.drawLine(
      Offset(size.width * 0.05, groundY),
      Offset(size.width * 0.95, groundY),
      DiagramStyle.body(color: DiagramStyle.ground, width: 2),
    );

    // Víctima tumbada, de fondo, ocupando la mitad inferior.
    final vHead = Offset(size.width * 0.16, groundY - u * 0.06);
    canvas.drawCircle(vHead, u * 0.09, victimPaint);
    final vChest = Offset(vHead.dx + u * 0.22, vHead.dy);
    canvas.drawLine(Offset(vHead.dx + u * 0.09, vHead.dy), vChest, victimPaint);
    final vTorsoEnd = Offset(size.width * 0.55, vHead.dy);
    canvas.drawLine(vChest, vTorsoEnd, victimPaint);
    canvas.drawLine(vTorsoEnd, Offset(size.width * 0.68, vHead.dy - 10), victimPaint);
    canvas.drawLine(vTorsoEnd, Offset(size.width * 0.68, vHead.dy + 10), victimPaint);

    // Reanimador arrodillado justo encima del pecho, en primer plano.
    final rHip = Offset(vChest.dx, groundY - u * 0.28);
    final rHead = Offset(rHip.dx - u * 0.02, rHip.dy - u * 0.34);
    canvas.drawCircle(rHead, u * 0.10, rescuerPaint);

    final rShoulder = Offset(rHead.dx + u * 0.02, rHead.dy + u * 0.10);
    canvas.drawLine(rShoulder, rHip, rescuerPaint);

    // Pierna trasera: rodilla apoyada en el suelo.
    final rKnee = Offset(rHip.dx - u * 0.16, groundY);
    canvas.drawLine(rHip, rKnee, rescuerPaint);

    // Pierna delantera: pie apoyado en el suelo, más adelantada.
    final rFoot = Offset(rHip.dx + u * 0.22, groundY);
    final rFrontKnee = Offset(rHip.dx + u * 0.14, groundY - u * 0.14);
    canvas.drawLine(rHip, rFrontKnee, rescuerPaint);
    canvas.drawLine(rFrontKnee, rFoot, rescuerPaint);

    // Brazos rectos bajando hacia el pecho de la víctima.
    canvas.drawLine(rShoulder, vChest, rescuerPaint);
    canvas.drawCircle(vChest, 5, DiagramStyle.fill(DiagramStyle.accent));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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

/// Dos insuflaciones de rescate: nariz pinzada, sello de boca a boca
/// y una flecha indicando el aire entrando.
class RescueBreathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = DiagramStyle.body();
    final headCenter = Offset(size.width * 0.35, size.height * 0.5);
    final u = size.width < size.height ? size.width : size.height;
    final headRadius = u * 0.30;

    canvas.drawOval(
      Rect.fromCenter(center: headCenter, width: headRadius * 1.6, height: headRadius * 2),
      body,
    );

    // Dedos pinzando la nariz.
    final nose = Offset(headCenter.dx + headRadius * 0.55, headCenter.dy - headRadius * 0.1);
    canvas.drawOval(
      Rect.fromCenter(center: nose, width: 16, height: 22),
      DiagramStyle.body(color: DiagramStyle.accent, width: 3),
    );

    // Boca del reanimador sellando la boca de la víctima (óvalo superpuesto).
    final mouth = Offset(headCenter.dx + headRadius * 0.75, headCenter.dy + headRadius * 0.35);
    canvas.drawOval(
      Rect.fromCenter(center: mouth, width: 26, height: 18),
      body,
    );

    // Flecha de aire entrando.
    final arrowPaint = DiagramStyle.body(color: DiagramStyle.accent, width: 3);
    canvas.drawLine(
      Offset(size.width * 0.62, mouth.dy),
      Offset(size.width * 0.78, mouth.dy),
      arrowPaint,
    );

    // Pecho subiendo (flecha curva hacia arriba) para mostrar el efecto.
    final chest = Offset(size.width * 0.55, size.height * 0.82);
    canvas.drawLine(chest, chest.translate(0, -18), arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
