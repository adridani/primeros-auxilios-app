import 'package:flutter/widgets.dart';

/// Un paso individual dentro de una guía de primeros auxilios lineal
/// (ver [GuideSequenceScreen]).
///
/// Cada paso tiene una instrucción corta (la que se lee de un vistazo)
/// y una ilustración que la refuerza visualmente, porque en una
/// emergencia real no hay tiempo ni calma para leer párrafos largos.
class GuideStep {
  final String title;
  final String instruction;
  final WidgetBuilder illustrationBuilder;

  /// Texto secundario opcional: aclaraciones o advertencias que no son
  /// esenciales para actuar pero conviene mostrar (en gris, más pequeño).
  final String? note;

  const GuideStep({
    required this.title,
    required this.instruction,
    required this.illustrationBuilder,
    this.note,
  });
}
