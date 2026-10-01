import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';

/// Pantalla justo antes de llamar a emergencias. Explica lo que va a
/// pasar, porque ni Android ni iOS dejan que la app siga a la vista
/// durante la llamada:
///  - En iPhone el sistema pregunta "¿Llamar?" y hay que pulsarlo.
///  - En los dos, la pantalla de la llamada tapa la app y hay que volver
///    a ella a mano (la llamada no se corta).
///  - Ninguna app puede poner el altavoz de una llamada normal: hay que
///    ponerlo desde la pantalla de la llamada.
///
/// Sin esto, la persona veía aparecer la llamada y no sabía que las
/// instrucciones seguían esperándola en la app.
class CallPreparationScreen extends StatelessWidget {
  final VoidCallback onCall;

  /// Alguien ya está hablando con emergencias: se pasa directamente a
  /// las instrucciones sin hacer una segunda llamada.
  final VoidCallback onSkipCall;

  const CallPreparationScreen({super.key, required this.onCall, required this.onSkipCall});

  static bool get _isIOS =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS);

  static String get _howToReturn => _isIOS
      ? 'Toca el indicador verde de arriba a la izquierda, o desliza hacia arriba y abre esta app.'
      : 'Abre las apps recientes (botón cuadrado o deslizando hacia arriba) y elige esta app.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.phone_in_talk, color: Colors.redAccent, size: 56),
                      const SizedBox(height: 12),
                      const Text(
                        'Vamos a llamar al 112',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      if (_isIOS)
                        const _Tip(
                          icon: Icons.touch_app,
                          title: 'Pulsa «Llamar»',
                          text: 'El iPhone te preguntará si quieres llamar: confírmalo.',
                        ),
                      const _Tip(
                        icon: Icons.volume_up,
                        title: 'Pon el altavoz',
                        text: 'Así podrás hablar con emergencias y tener las manos libres.',
                      ),
                      _Tip(
                        icon: Icons.replay,
                        title: 'Vuelve a esta app',
                        text: 'Aquí siguen las instrucciones; la llamada no se corta. $_howToReturn',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 72),
                child: ElevatedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.call, color: Colors.white, size: 28),
                  label: const Text(
                    'Llamar al 112',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: ElevatedButton(
                  onPressed: onSkipCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Ya ha llamado otra persona',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
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

class _Tip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _Tip({required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.amberAccent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(text, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
