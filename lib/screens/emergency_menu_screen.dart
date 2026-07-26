import 'package:flutter/material.dart';
import '../models/emergency_type.dart';
import 'placeholder_instructions_screen.dart';

/// Se muestra cuando la víctima está CONSCIENTE: en ese caso no
/// tiene sentido preguntar por la respiración con el flujo de
/// triaje (la persona está hablando/respondiendo), así que vamos
/// directo a que quien ayuda elija qué tipo de emergencia está
/// viendo (hemorragia, atragantamiento, quemadura, etc.).
///
/// Recorre la lista [emergencyTypes] (definida en
/// models/emergency_type.dart) para generar los botones, así que
/// añadir un nuevo tipo de emergencia en el futuro no requiere
/// tocar este archivo.
class EmergencyMenuScreen extends StatelessWidget {
  const EmergencyMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('¿Qué está pasando?'),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: emergencyTypes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final type = emergencyTypes[index];
            return _EmergencyTypeButton(
              type: type,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlaceholderInstructionsScreen(
                      title: type.label,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmergencyTypeButton extends StatelessWidget {
  final    type;
  final VoidCallback onTap;

  const _EmergencyTypeButton({
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: type.color,
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Icon(type.icon, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Text(
              type.label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}