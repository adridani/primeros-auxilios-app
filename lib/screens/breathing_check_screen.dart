import 'package:flutter/material.dart';

/// Resultado de comprobar la respiración. Se usa un enum en vez de
/// un bool porque, a diferencia de la consciencia, aquí sí existe
/// una respuesta intermedia legítima ("no lo sé") que además tiene
/// su propia consecuencia clínica (tratarlo como si no respirara,
/// por seguridad).
enum BreathingStatus { breathing, notBreathing, unsure }

/// Tercera pregunta del flujo, solo se muestra cuando la víctima
/// está INCONSCIENTE (si está consciente, no tiene sentido
/// preguntar esto: pasamos directo al menú de tipos de emergencia).
///
/// A diferencia de las pantallas de entrada (confirmación de
/// emergencia), aquí SÍ se permite volver atrás: esta pantalla vive
/// dentro del flujo, así que "atrás" simplemente regresa a
/// "¿Está consciente?" en vez de arriesgarse a salir de la app.
class BreathingCheckScreen extends StatelessWidget {
  final void Function(BreathingStatus status) onResult;

  const BreathingCheckScreen({
    super.key,
    required this.onResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        // Flecha de volver explícita (además del gesto/botón físico,
        // que también funciona porque no bloqueamos el pop aquí).
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.air,
                color: Colors.orangeAccent,
                size: 72,
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Respira?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Acerca tu oído a su boca y observa el pecho durante 10 segundos.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              _TriageButton(
                label: 'SÍ respira',
                color: Colors.green,
                onTap: () => onResult(BreathingStatus.breathing),
              ),
              const SizedBox(height: 16),
              _TriageButton(
                label: 'NO respira',
                color: Colors.red,
                onTap: () => onResult(BreathingStatus.notBreathing),
              ),
              const SizedBox(height: 16),
              _TriageButton(
                label: 'No lo sé',
                color: Colors.grey.shade700,
                onTap: () => onResult(BreathingStatus.unsure),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mismo botón de triaje que en consciousness_check_screen.dart.
/// Duplicado intencionalmente por ahora (dos usos); si aparece un
/// tercer uso, lo extraemos a widgets/triage_button.dart.
class _TriageButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TriageButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}