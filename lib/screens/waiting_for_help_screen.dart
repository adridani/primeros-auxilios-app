import 'dart:async';
import 'package:flutter/material.dart';
import 'breathing_check_screen.dart';

/// Pantalla final común de las guías del menú de emergencias
/// (hemorragia, atragantamiento, quemadura...): recuerda lo que hay
/// que seguir haciendo hasta que llegue la ayuda y deja siempre a la
/// vista, abajo, un botón de alarma para cuando la situación empeora
/// (por ejemplo, "ha perdido el conocimiento").
///
/// Es la versión genérica de [RecoveryMonitoringScreen]: misma
/// estructura (tiempo arriba, consejos con scroll, aviso fijo abajo)
/// para que todas las guías terminen de la misma forma.
class WaitingForHelpScreen extends StatefulWidget {
  final Color accentColor;

  /// Lo que hay que seguir haciendo mientras se espera, en frases
  /// cortas (una por línea).
  final List<String> tips;

  /// Pregunta y botón del aviso de abajo.
  final String alarmQuestion;
  final String alarmLabel;

  /// Qué hacer al pulsar el botón de alarma. Recibe el [NavigatorState]
  /// (y no un context) porque normalmente esta pantalla se sustituye
  /// por otra y su context deja de ser válido.
  final void Function(NavigatorState navigator) onAlarm;

  /// Desde cuándo se cuenta el tiempo. Por defecto, desde que se abre
  /// esta pantalla; la guía de convulsiones pasa el momento en que se
  /// abrió la guía, porque lo que importa es cuánto dura la crisis.
  final DateTime? startedAt;

  /// Si se indica, a partir de este tiempo el contador se pone en rojo
  /// y muestra [warnText] (por ejemplo, convulsión de más de 5 min).
  final Duration? warnAfter;
  final String? warnText;

  const WaitingForHelpScreen({
    super.key,
    required this.accentColor,
    required this.tips,
    required this.alarmQuestion,
    required this.alarmLabel,
    required this.onAlarm,
    this.startedAt,
    this.warnAfter,
    this.warnText,
  });

  /// Acción de alarma más habitual: la víctima deja de responder, así
  /// que se comprueba si respira y, según la respuesta, se va a la
  /// posición lateral de seguridad o a la RCP (igual que en el triaje).
  static void checkBreathing(NavigatorState navigator) {
    navigator.push(
      MaterialPageRoute(
        builder: (_) => BreathingCheckScreen(
          onResult: (status) => navigator.pushReplacement(
            MaterialPageRoute(builder: (_) => destinationForBreathing(status)),
          ),
        ),
      ),
    );
  }

  @override
  State<WaitingForHelpScreen> createState() => _WaitingForHelpScreenState();
}

class _WaitingForHelpScreenState extends State<WaitingForHelpScreen> {
  late final DateTime _start;
  late final Timer _ticker;
  Duration _elapsed = Duration.zero;

  /// El botón de alarma queda justo donde estaba el botón "Hecho" de
  /// la guía: sin esto, un doble toque nervioso sobre "Hecho" pulsaba
  /// también la alarma (por ejemplo, "Empezar RCP") sin querer.
  bool _alarmArmed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _alarmArmed = true);
    });
    _start = widget.startedAt ?? DateTime.now();
    _elapsed = DateTime.now().difference(_start);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = DateTime.now().difference(_start));
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  String _formatElapsed(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final warning = widget.warnAfter != null && _elapsed >= widget.warnAfter!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Mientras llega la ayuda'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tiempo: ${_formatElapsed(_elapsed)}',
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
              const SizedBox(height: 16),
              // Los consejos se desplazan; el aviso de alarma queda fijo
              // abajo para que esté siempre a la vista.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final tip in widget.tips)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Icon(Icons.check_circle, color: widget.accentColor, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: const TextStyle(color: Colors.white70, fontSize: 17, height: 1.4),
                                ),
                              ),
                            ],
                          ),
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
                    Text(
                      widget.alarmQuestion,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _alarmArmed ? () => widget.onAlarm(Navigator.of(context)) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          widget.alarmLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
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
