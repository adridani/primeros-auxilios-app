import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/diagram_box.dart';
import '../widgets/illustrations/recovery_position_illustrations.dart';
import 'cpr_guide_screen.dart';
import '../services/voice_guide_service.dart';
import '../widgets/home_button.dart';
import 'waiting_for_help_screen.dart' show NoAnswerButton, NoAnswerMessage;

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

  /// El botón de "Empezar RCP" queda justo donde estaba "Ya está
  /// colocada" en la pantalla anterior: sin esto, un doble toque sobre
  /// ese botón empezaba la RCP sin querer.
  bool _alarmArmed = false;

  /// Se ha respondido NO (sigue respirando): se muestra qué seguir haciendo.
  bool _answeredNo = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _alarmArmed = true);
    });
    _stopwatch = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = _stopwatch.elapsed);
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    _stopwatch.stop();
    _scroll.dispose();
    VoiceGuideService.instance.stopSpeaking();
    super.dispose();
  }

  final ScrollController _scroll = ScrollController();

  static const String _noMessage =
      'Bien. Sigue vigilando y comprueba su respiración cada minuto. Si deja de respirar con normalidad, pulsa SÍ.';

  /// Igual que en [WaitingForHelpScreen]: marca el botón, sube hasta el
  /// mensaje y lo lee en voz alta.
  void _answerNo() {
    setState(() => _answeredNo = true);
    if (_scroll.hasClients) {
      _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    VoiceGuideService.instance.speak(_noMessage);
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
        actions: const [HomeButton()],
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
              // El dibujo y el texto se desplazan; el aviso de "ha dejado
              // de respirar" queda fijo abajo para que esté siempre a la
              // vista, también en móviles pequeños (antes se desbordaba).
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_answeredNo) const NoAnswerMessage(text: _noMessage, color: Colors.orange),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 56),
                      child: ElevatedButton(
                        onPressed: _alarmArmed ? _breathingStopped : null,
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
                    const SizedBox(height: 8),
                    NoAnswerButton(
                      label: 'NO, respira con normalidad',
                      selected: _answeredNo,
                      color: Colors.orange,
                      onPressed: _alarmArmed ? _answerNo : null,
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
