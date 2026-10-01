import 'package:flutter/material.dart';

/// Primera pantalla que ve el usuario al abrir la app.
///
/// Objetivo: confirmar en un segundo si realmente hay una emergencia,
/// antes de mostrar cualquier otro contenido. Diseñada para alguien
/// que puede estar en pánico, así que:
///   - Sin botón de "atrás" ni forma de cerrar por accidente.
///   - Solo dos acciones posibles en toda la pantalla.
///   - Textos cortos, botones enormes, alto contraste.
///
/// No navega por sí misma: delega la decisión a través de [onResult],
/// para que quien la use decida a dónde ir después (por ejemplo,
/// a la pantalla de primeros auxilios, o simplemente cerrar la app).
class EmergencyConfirmationScreen extends StatelessWidget {
  final void Function(bool isEmergency) onResult;

  const EmergencyConfirmationScreen({
    super.key,
    required this.onResult,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Bloquea el botón físico/gesto de "atrás" del sistema.
      // Quien esté en pánico no debería poder salir sin querer.
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
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
                      Icons.warning_rounded,
                      color: Colors.redAccent,
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¿Es esta una emergencia real?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Vas a recibir instrucciones para actuar de inmediato.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 48),
    
                    // Botón "SÍ": dominante, es el camino esperado.
                    _EmergencyButton(
                      label: 'SÍ, es una emergencia',
                      color: Colors.red,
                      height: 120,
                      fontSize: 24,
                      onTap: () => onResult(true),
                    ),
                    const SizedBox(height: 20),
    
                    // Botón "No": secundario, neutro, más pequeño.
                    _EmergencyButton(
                      label: 'No, salir',
                      color: Colors.grey.shade800,
                      height: 64,
                      fontSize: 16,
                      onTap: () => onResult(false),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón grande y táctil reutilizado por esta pantalla.
/// Lo dejo privado a este archivo por ahora; si más pantallas
/// necesitan algo parecido, lo movemos a widgets/big_action_button.dart.
class _EmergencyButton extends StatelessWidget {
  final String label;
  final Color color;
  final double height;
  final double fontSize;
  final VoidCallback onTap;

  const _EmergencyButton({
    required this.label,
    required this.color,
    required this.height,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
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
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}