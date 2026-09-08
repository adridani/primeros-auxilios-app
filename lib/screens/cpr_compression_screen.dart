import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../widgets/diagram_box.dart';
import '../widgets/illustrations/cpr_illustrations.dart';
import 'recovery_position_screen.dart';

enum _CprPhase { compressions, breaths }

/// Pantalla interactiva del ciclo de RCP: 30 compresiones + 2
/// insuflaciones, repetido, con un metrónomo visual que marca el
/// ritmo (110/min) y cuenta las compresiones automáticamente.
///
/// Deliberadamente NO requiere tocar nada durante las compresiones:
/// pedirle a quien está haciendo RCP que además toque un botón en
/// cada compresión le distrae justo cuando más concentrado tiene que
/// estar en la técnica. Solo tiene que mirar el ritmo y comprimir.
///
/// Es una pantalla interactiva (no una simple lista de pasos) porque
/// la RCP real es un ciclo que se repite hasta que pase algo (la
/// víctima reacciona, llega ayuda, llega un DESA...), no una
/// secuencia lineal con final fijo.
class CprCompressionScreen extends StatefulWidget {
  const CprCompressionScreen({super.key});

  @override
  State<CprCompressionScreen> createState() => _CprCompressionScreenState();
}

class _CprCompressionScreenState extends State<CprCompressionScreen>
    with SingleTickerProviderStateMixin {
  static const int _compressionsPerCycle = 30;
  static const _beatPeriod = Duration(milliseconds: 545); // ciclo completo ≈ 110/min

  _CprPhase _phase = _CprPhase.compressions;
  int _compressionCount = 0;
  int _cycleCount = 0;
  late final AnimationController _pulseController;
  Timer? _compressionTimer;
  late final Stopwatch _stopwatch;
  late final Timer _elapsedTicker;
  Duration _elapsed = Duration.zero;

  // Se crea un [AudioPlayer] nuevo en cada compresión (en vez de
  // reutilizar uno) con `mode: PlayerMode.lowLatency` (SoundPool en
  // Android, volumen de MEDIA): es la forma más simple de reproducir
  // un sonido corto y repetido, con menos piezas que puedan fallar
  // que precargar una única fuente y reutilizarla con resume().
  //
  // Si el sonido falla, el motivo exacto se guarda en [_audioError]
  // y se muestra en pantalla (en vez de solo en el log), para poder
  // diagnosticarlo sin acceso a la consola de depuración.
  String? _audioError;

  @override
  void initState() {
    super.initState();
    // Medio período por dirección (bajar / subir) para que un ciclo
    // completo del pulso dure exactamente un latido (545 ms ≈ 110/min).
    _pulseController = AnimationController(
      vsync: this,
      duration: _beatPeriod ~/ 2,
    )..repeat(reverse: true);
    _startCompressionTimer();
    _stopwatch = Stopwatch()..start();
    _elapsedTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed = _stopwatch.elapsed);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _compressionTimer?.cancel();
    _elapsedTicker.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  /// Cuenta las compresiones sola, al ritmo del metrónomo visual: el
  /// reanimador no tiene que tocar la pantalla en ningún momento.
  /// Además suena un pitido en cada compresión, para poder llevar el
  /// ritmo sin tener que mirar la pantalla todo el rato.
  void _startCompressionTimer() {
    _compressionTimer?.cancel();
    _compressionTimer = Timer.periodic(_beatPeriod, (_) {
      _playBeep();
      setState(() {
        _compressionCount += 1;
        if (_compressionCount >= _compressionsPerCycle) {
          _compressionTimer?.cancel();
          _phase = _CprPhase.breaths;
        }
      });
    });
  }

  /// El sonido es una ayuda, no algo crítico: si falla (sin volumen,
  /// plugin no cargado todavía, dispositivo raro...) nunca debe
  /// interrumpir el conteo ni el resto de la guía.
  Future<void> _playBeep() async {
    try {
      final player = AudioPlayer();
      await player.play(
        AssetSource('audio/compression_beep.wav'),
        mode: PlayerMode.lowLatency,
      );
      if (_audioError != null && mounted) {
        setState(() => _audioError = null);
      }
    } catch (e) {
      debugPrint('No se pudo reproducir el sonido de la RCP: $e');
      if (mounted) {
        setState(() => _audioError = e.toString());
      }
    }
  }

  void _onBreathsDone() {
    setState(() {
      _cycleCount += 1;
      _compressionCount = 0;
      _phase = _CprPhase.compressions;
    });
    _startCompressionTimer();
  }

  void _onVictimRecovered() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RecoveryPositionScreen()),
    );
  }

  String _formatElapsed(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('RCP en curso'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ciclo ${_cycleCount + 1} · Tiempo: ${_formatElapsed(_elapsed)}',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const Text(
                    'Si hay un DESA cerca, que lo traigan',
                    style: TextStyle(color: Colors.amberAccent, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _phase == _CprPhase.compressions
                    ? _CompressionsPhase(
                        count: _compressionCount,
                        target: _compressionsPerCycle,
                        pulseController: _pulseController,
                        audioError: _audioError,
                      )
                    : _BreathsPhase(onDone: _onBreathsDone),
              ),
              const SizedBox(height: 16),
              _RecoveryCheckBar(onRecovered: _onVictimRecovered),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompressionsPhase extends StatelessWidget {
  final int count;
  final int target;
  final AnimationController pulseController;
  final String? audioError;

  const _CompressionsPhase({
    required this.count,
    required this.target,
    required this.pulseController,
    this.audioError,
  });

  @override
  Widget build(BuildContext context) {
    // Envuelto en scroll (en vez de Spacer()) para que, si en algún
    // teléfono el contenido no cabe entero en la pantalla, se pueda
    // desplazar en lugar de desbordar y lanzar un error de layout.
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (audioError != null)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent),
              ),
              child: Text(
                '🔇 Sonido: $audioError',
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          AnimatedBuilder(
            animation: pulseController,
            builder: (context, _) {
              return DiagramBox(painter: CompressionMotionPainter(progress: pulseController.value));
            },
          ),
          const SizedBox(height: 12),
          const Text(
            'Comprime fuerte y rápido: unos 5-6 cm de profundidad. Deja que el pecho suba del todo entre compresión y compresión.',
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 8),
          const Text(
            'No toques nada: sigue el ritmo del círculo y del sonido. La cuenta avanza sola.',
            style: TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 28),
          Center(
            child: AnimatedBuilder(
              animation: pulseController,
              builder: (context, child) {
                final scale = 1.0 + (pulseController.value * 0.08);
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$count/$target',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _BreathsPhase extends StatelessWidget {
  final VoidCallback onDone;

  const _BreathsPhase({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '2 insuflaciones de rescate',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PhotoDiagramBox(assetPath: 'assets/images/cpr_head_tilt.jpg'),
                const SizedBox(height: 8),
                const Text(
                  '1. Inclina la cabeza hacia atrás y eleva el mentón para abrir la vía aérea.',
                  style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 16),
                DiagramBox(painter: RescueBreathPainter()),
                const SizedBox(height: 8),
                const Text(
                  '2. Pinza la nariz, sella tu boca sobre la suya y sopla hasta que el pecho suba. Repite una vez más.',
                  style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Si no quieres o no puedes dar respiraciones, sigue solo con compresiones sin parar: es mejor que nada.',
                  style: TextStyle(color: Colors.white38, fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 60,
          child: ElevatedButton(
            onPressed: onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'Listo, sigo con compresiones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// Barra persistente para romper el ciclo en cuanto la víctima dé
/// señales de reaccionar: sin esto, la única salida del ciclo sería
/// cerrar la app.
class _RecoveryCheckBar extends StatelessWidget {
  final VoidCallback onRecovered;

  const _RecoveryCheckBar({required this.onRecovered});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '¿Reacciona o respira con normalidad?',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: onRecovered,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }
}
