import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/diagram_box.dart';
import '../widgets/illustrations/recovery_position_illustrations.dart';
import 'cpr_guide_screen.dart';

/// Pantalla final tras colocar a la víctima en posición lateral de
/// seguridad: hay que vigilar su respiración de forma continua hasta
/// que llegue ayuda. Si en algún momento deja de respirar con
/// normalidad, hay que empezar la RCP de inmediato.
class RecoveryMonitoringScreen extends StatefulWidget {
  const RecoveryMonitoringScreen({super.key});

  @override
  State<RecoveryMonitoringScreen> createState() => _RecoveryMonitoringScreenState();
}

class _RecoveryMonitoringScreenState extends State<RecoveryMonitoringScreen> {
  late final Stopwatch _stopwatch;
  late final Timer _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = _stopwatch.elapsed);
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  String _formatElapsed(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _breathingStopped() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CprGuideScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Vigilando a la víctima'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tiempo en posición: ${_formatElapsed(_elapsed)}',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 16),
              DiagramBox(painter: FinalRecoveryPositionPainter()),
              const SizedBox(height: 20),
              const Text(
                'Mantenla en esta posición y vigila que respire con normalidad hasta que llegue la ayuda.',
                style: TextStyle(color: Colors.white70, fontSize: 17, height: 1.4),
              ),
              const SizedBox(height: 8),
              const Text(
                'Comprueba su respiración cada minuto, acercando tu oído a su boca y observando el pecho.',
                style: TextStyle(color: Colors.white38, fontSize: 14, fontStyle: FontStyle.italic),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '¿Ha dejado de respirar con normalidad?',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _breathingStopped,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'SÍ, ha dejado de respirar → Empezar RCP',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
