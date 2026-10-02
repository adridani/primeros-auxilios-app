import 'package:flutter/material.dart';
import '../services/voice_guide_service.dart';
import '../widgets/elapsed_timer.dart';
import '../widgets/home_button.dart';
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

  /// Botón para responder que NO a [alarmQuestion], y lo que se le
  /// dice a quien ayuda en ese caso (qué seguir haciendo). Sin esto la
  /// pregunta solo admitía "sí" y no quedaba claro qué hacer si no.
  final String noLabel;
  final String noMessage;

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

  /// Texto delante del contador ("Tiempo: 02:10").
  final String timerLabel;

  const WaitingForHelpScreen({
    super.key,
    required this.accentColor,
    required this.tips,
    required this.alarmQuestion,
    required this.alarmLabel,
    required this.noLabel,
    required this.noMessage,
    required this.onAlarm,
    this.startedAt,
    this.warnAfter,
    this.warnText,
    this.timerLabel = 'Tiempo',
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

/// Mensaje destacado tras responder NO a la pregunta de alarma. Lo usa
/// también [RecoveryMonitoringScreen].
class NoAnswerMessage extends StatelessWidget {
  final String text;
  final Color color;

  const NoAnswerMessage({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4)),
    );
  }
}

/// Botón para responder NO a la pregunta de alarma. Una vez pulsado se
/// queda marcado (✓ y borde de color) para que se note que la
/// respuesta se ha registrado: antes la única reacción era un mensaje
/// arriba que podía quedar fuera de la vista. Lo usa también
/// [RecoveryMonitoringScreen].
class NoAnswerButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback? onPressed;

  const NoAnswerButton({
    super.key,
    required this.label,
    required this.selected,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: selected ? Icon(Icons.check_circle, color: color) : const SizedBox.shrink(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: selected ? BorderSide(color: color, width: 2) : BorderSide.none,
          ),
        ),
        label: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

class _WaitingForHelpScreenState extends State<WaitingForHelpScreen> {
  late final DateTime _start;
  final ScrollController _scroll = ScrollController();

  /// El botón de alarma queda justo donde estaba el botón "Hecho" de
  /// la guía: sin esto, un doble toque nervioso sobre "Hecho" pulsaba
  /// también la alarma (por ejemplo, "Empezar RCP") sin querer.
  bool _alarmArmed = false;

  /// Se ha respondido NO: se muestra [WaitingForHelpScreen.noMessage].
  bool _answeredNo = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _alarmArmed = true);
    });
    _start = widget.startedAt ?? ElapsedTimer.now();
  }

  @override
  void dispose() {
    _scroll.dispose();
    VoiceGuideService.instance.stopSpeaking();
    super.dispose();
  }

  /// Respuesta NO: marca el botón, sube la lista hasta el mensaje (que
  /// aparece arriba del todo) y lo lee en voz alta, por si quien ayuda
  /// tiene las manos ocupadas y no mira la pantalla.
  void _answerNo() {
    setState(() => _answeredNo = true);
    if (_scroll.hasClients) {
      _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    VoiceGuideService.instance.speak(widget.noMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Mientras llega la ayuda'),
        automaticallyImplyLeading: false,
        actions: const [HomeButton()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElapsedTimer(
                start: _start,
                label: widget.timerLabel,
                warnAfter: widget.warnAfter,
                warnText: widget.warnText,
              ),
              const SizedBox(height: 16),
              // Los consejos se desplazan; el aviso de alarma queda fijo
              // abajo para que esté siempre a la vista.
              Expanded(
                child: SingleChildScrollView(
                  controller: _scroll,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // La respuesta al NO va aquí arriba y no en el
                      // recuadro de abajo: ese recuadro está siempre
                      // fijo y, con la letra grande, ya no cabría.
                      if (_answeredNo)
                        NoAnswerMessage(text: widget.noMessage, color: widget.accentColor),
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
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 56),
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
                    const SizedBox(height: 8),
                    NoAnswerButton(
                      label: widget.noLabel,
                      selected: _answeredNo,
                      color: widget.accentColor,
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
