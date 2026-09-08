import 'package:flutter/material.dart';
import '../models/guide_step.dart';
import '../services/voice_guide_service.dart';

/// Muestra una lista de [GuideStep] de una en una, con botones grandes
/// de "Anterior"/"Siguiente" y un indicador de progreso ("Paso X de Y").
///
/// Cada paso se lee en voz alta al entrar y, al terminar, la app
/// escucha unos segundos por si el usuario dice "siguiente" (o algún
/// sinónimo) para avanzar sin tener que tocar la pantalla — pensado
/// para cuando tiene las manos ocupadas sujetando a la víctima. El
/// botón manual sigue funcionando exactamente igual en todo momento,
/// por si la voz falla o el usuario prefiere tocar.
///
/// Al llegar al último paso, el botón "Siguiente" se reemplaza por
/// [finishLabel] y, al pulsarlo (o al detectar la voz), se llama a
/// [onFinished] en vez de avanzar (por ejemplo, para pasar de los
/// pasos de preparación de la RCP a la pantalla interactiva de
/// compresiones).
class GuideSequenceScreen extends StatefulWidget {
  final String appBarTitle;
  final Color accentColor;
  final List<GuideStep> steps;
  final String finishLabel;
  final VoidCallback onFinished;

  const GuideSequenceScreen({
    super.key,
    required this.appBarTitle,
    required this.steps,
    required this.onFinished,
    this.accentColor = Colors.red,
    this.finishLabel = 'Siguiente',
  });

  @override
  State<GuideSequenceScreen> createState() => _GuideSequenceScreenState();
}

class _GuideSequenceScreenState extends State<GuideSequenceScreen> {
  int _index = 0;

  // Evita que un doble toque sobre "Siguiente" (o un toque justo
  // cuando la voz también detecta "siguiente") dispare el avance dos
  // veces seguidas, o incremente _index más allá del último paso
  // antes de que la pantalla termine de reconstruirse.
  bool _advancing = false;

  bool _speaking = false;
  bool _listening = false;

  int get _safeIndex => _index.clamp(0, widget.steps.length - 1);
  bool get _isLast => _safeIndex == widget.steps.length - 1;

  @override
  void initState() {
    super.initState();
    _narrateAndListen();
  }

  @override
  void dispose() {
    VoiceGuideService.instance.stopSpeaking();
    VoiceGuideService.instance.cancelListening();
    super.dispose();
  }

  Future<void> _narrateAndListen() async {
    final step = widget.steps[_safeIndex];
    setState(() => _speaking = true);
    final parts = [step.title, step.instruction, if (step.note != null) step.note!];
    await VoiceGuideService.instance.speak(parts.join('. '));
    if (!mounted) return;
    setState(() {
      _speaking = false;
      _listening = true;
    });
    final matched = await VoiceGuideService.instance.listenForNext();
    if (!mounted) return;
    setState(() => _listening = false);
    if (matched) _advance();
  }

  void _goBack() {
    VoiceGuideService.instance.stopSpeaking();
    VoiceGuideService.instance.cancelListening();
    if (_index == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _index -= 1;
      _speaking = false;
      _listening = false;
    });
    _narrateAndListen();
  }

  void _advance() {
    if (_advancing) return;
    VoiceGuideService.instance.stopSpeaking();
    VoiceGuideService.instance.cancelListening();
    setState(() {
      _advancing = true;
      _speaking = false;
      _listening = false;
    });
    if (_isLast) {
      widget.onFinished();
    } else {
      setState(() {
        _index += 1;
        _advancing = false;
      });
      _narrateAndListen();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se lee siempre a través de un índice acotado a [0, length-1]: si
    // varios toques rápidos sobre "Siguiente" llegan a ejecutarse antes
    // de que Flutter reconstruya el widget entre uno y otro, _index
    // podría quedar momentáneamente fuera de rango. Aquí NUNCA debe
    // crashear: es la pantalla que guía una reanimación real.
    final step = widget.steps[_safeIndex];
    final isLast = _isLast;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.appBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Paso ${_safeIndex + 1} de ${widget.steps.length}',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_safeIndex + 1) / widget.steps.length,
                  backgroundColor: Colors.white12,
                  color: widget.accentColor,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 20),
              Builder(builder: step.illustrationBuilder),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        step.instruction,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 17,
                          height: 1.4,
                        ),
                      ),
                      if (step.note != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          step.note!,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_speaking || _listening)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _listening ? Icons.mic : Icons.volume_up,
                        color: widget.accentColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _listening ? 'Escuchando… di "siguiente"' : 'Leyendo…',
                        style: TextStyle(
                          color: widget.accentColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 2),
              SizedBox(
                height: 64,
                child: ElevatedButton(
                  onPressed: _advancing ? null : _advance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isLast ? widget.finishLabel : 'Siguiente',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
