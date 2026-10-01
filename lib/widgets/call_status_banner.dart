import 'package:flutter/material.dart';
import '../services/call_status.dart';

/// Banner fijo que se muestra en la parte superior de la pantalla
/// mientras [callStatusNotifier] esté activo (true).
///
/// Se usa envolviendo el contenido de cada pantalla, o mejor aún,
/// una sola vez de forma global en main.dart mediante la propiedad
/// `builder` de MaterialApp, para no tener que añadirlo pantalla
/// por pantalla.
class CallStatusBanner extends StatelessWidget {
  final Widget child;

  const CallStatusBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: callStatusNotifier,
      builder: (context, isCallActive, _) {
        return Column(
          children: [
            if (isCallActive) const _CallActiveBar(),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

class _CallActiveBar extends StatelessWidget {
  const _CallActiveBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Material(
        color: Colors.green.shade700,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.call, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              // Reparto del ancho 3:2. Antes el botón cogía todo el que
              // necesitaba y, con la letra del sistema grande en un móvil
              // estrecho, el texto quedaba en una columna de una palabra
              // por línea y el banner se comía media pantalla.
              const Expanded(
                flex: 3,
                child: Text(
                  'Llamada de emergencia en curso',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: TextButton(
                  onPressed: () => callStatusNotifier.markCallEnded(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black26,
                  ),
                  child: const Text('Ha terminado', textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 