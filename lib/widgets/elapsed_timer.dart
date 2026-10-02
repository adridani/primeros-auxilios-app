import 'dart:async';
import 'package:flutter/material.dart';

/// Contador de tiempo desde [start] ("Tiempo: 03:12"), que se
/// actualiza solo cada segundo. Si se indica [warnAfter], a partir de
/// ese tiempo se pone en rojo, más grande, y muestra [warnText] (por
/// ejemplo, convulsión de más de 5 minutos).
///
/// Cuenta desde una hora fija ([start]) en vez de desde que se crea el
/// widget: así, al pasar de un paso a otro de una guía, o a la
/// pantalla final, el tiempo sigue siendo el mismo y no vuelve a cero.
class ElapsedTimer extends StatefulWidget {
  final DateTime start;
  final String label;
  final Duration? warnAfter;
  final String? warnText;

  const ElapsedTimer({
    super.key,
    required this.start,
    this.label = 'Tiempo',
    this.warnAfter,
    this.warnText,
  });

  /// Reloj que usa el contador (y las pantallas que fijan su hora de
  /// inicio). Los tests lo sustituyen para simular que han pasado
  /// minutos sin tener que esperarlos; en la app es siempre la hora real.
  static DateTime Function() now = DateTime.now;

  @override
  State<ElapsedTimer> createState() => _ElapsedTimerState();
}

class _ElapsedTimerState extends State<ElapsedTimer> {
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = ElapsedTimer.now().difference(widget.start);
    final warning = widget.warnAfter != null && elapsed >= widget.warnAfter!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${widget.label}: ${_format(elapsed)}',
          style: TextStyle(
            color: warning ? Colors.redAccent : Colors.white54,
            fontSize: warning ? 18 : 14,
            fontWeight: warning ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (warning && widget.warnText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.warnText!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }
}
