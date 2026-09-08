import 'package:flutter/material.dart';

/// Marco visual compartido por todas las ilustraciones de las guías
/// (RCP, posición lateral de seguridad, etc.). Da un tamaño y fondo
/// consistentes para que un [CustomPainter] solo tenga que preocuparse
/// de dibujar, no de layout.
class DiagramBox extends StatelessWidget {
  final CustomPainter painter;

  const DiagramBox({super.key, required this.painter});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(painter: painter, child: const SizedBox.expand()),
    );
  }
}

/// Igual que [DiagramBox] pero para una foto/ilustración real
/// ([assetPath]) en vez de un [CustomPainter]. Fondo blanco porque
/// las ilustraciones de trazo (línea negra) que usa la app no se ven
/// bien sobre un fondo oscuro.
///
/// Se puede tocar para verla a pantalla completa con zoom: en un
/// recuadro pequeño algunos detalles (como los números de la guía de
/// posición lateral de seguridad) quedan demasiado pequeños para
/// leerse de un vistazo.
class PhotoDiagramBox extends StatelessWidget {
  final String assetPath;
  final double height;

  const PhotoDiagramBox({super.key, required this.assetPath, this.height = 220});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullScreen(context, assetPath),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset(assetPath, fit: BoxFit.contain)),
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.zoom_in, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullScreen(BuildContext context, String assetPath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullScreenImage(assetPath: assetPath),
      ),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final String assetPath;

  const _FullScreenImage({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 6,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Image.asset(assetPath, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

/// Estilos de trazo comunes a todos los diagramas, para que todas las
/// ilustraciones de la app se vean como parte de un mismo sistema.
class DiagramStyle {
  DiagramStyle._();

  static Paint body({Color color = Colors.white70, double width = 3}) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  static Paint fill(Color color) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

  static const Color accent = Colors.amberAccent;
  static const Color ground = Colors.white24;
}
