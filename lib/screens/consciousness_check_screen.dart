import 'package:flutter/material.dart';

/// Segunda pregunta del flujo, justo después de confirmar que hay
/// una emergencia (y de haber iniciado la llamada de auxilio).
///
/// A diferencia de la pantalla de confirmación de emergencia (la
/// puerta de entrada, donde SÍ bloqueamos el atrás para evitar
/// salidas accidentales de la app), aquí permitimos volver: esta
/// pantalla vive dentro del flujo, así que "atrás" simplemente
/// regresa a la confirmación de emergencia.
class ConsciousnessCheckScreen extends StatelessWidget {
  final void Function(bool isConscious) onResult;

  const ConsciousnessCheckScreen({
    super.key,
    required this.onResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        // Centrado y con scroll: en móviles pequeños o con la letra
        // del sistema grande, los botones no cabían y se desbordaban.
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.person_search,
                    color: Colors.orangeAccent,
                    size: 72,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¿Está consciente?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Háblale fuerte y agítale suavemente por los hombros.\n¿Responde de alguna forma?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _TriageButton(
                    label: 'SÍ, responde',
                    color: Colors.green,
                    onTap: () => onResult(true),
                  ),
                  const SizedBox(height: 20),
                  _TriageButton(
                    label: 'NO responde',
                    color: Colors.red,
                    onTap: () => onResult(false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón de triaje reutilizado por las pantallas de este tipo
/// (consciencia, respiración...). Si acaba usándose en 3+ archivos,
/// lo movemos a widgets/triage_button.dart para no repetirlo.
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
      height: 100,
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}