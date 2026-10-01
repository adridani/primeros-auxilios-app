import 'package:flutter/material.dart';
import '../screens/emergency_menu_screen.dart';

/// Botón con una casita para volver al menú de emergencias
/// ("¿Qué está pasando?") desde cualquier guía.
///
/// Se queda debajo solo la primera pantalla de la app, y el menú se
/// pone encima: así no se vuelve a preguntar "¿Es una emergencia
/// real?" (que lanzaría otra llamada) y el banner de la llamada en
/// curso sigue visible.
class HomeButton extends StatelessWidget {
  /// Si no es null, antes de salir se pide confirmación con este texto.
  /// Se usa durante la RCP: un toque sin querer pararía el metrónomo.
  final String? confirmMessage;

  const HomeButton({super.key, this.confirmMessage});

  Future<void> _goHome(BuildContext context) async {
    final navigator = Navigator.of(context);
    if (confirmMessage != null) {
      final leave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('¿Volver al menú?'),
          content: Text(confirmMessage!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Seguir aquí'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Volver al menú'),
            ),
          ],
        ),
      );
      if (leave != true) return;
    }
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const EmergencyMenuScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.home),
      tooltip: 'Volver al menú',
      onPressed: () => _goHome(context),
    );
  }
}
