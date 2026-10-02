import 'package:flutter/material.dart';
import '../models/emergency_type.dart';
import 'bleeding_guide_screen.dart';
import 'burn_guide_screen.dart';
import 'choking_guide_screen.dart';
import 'cpr_guide_screen.dart';
import 'fainting_guide_screen.dart';
import 'fracture_guide_screen.dart';
import 'seizure_guide_screen.dart';

/// Pantalla de instrucciones de cada tipo de emergencia, según su
/// [EmergencyType.id]. Al añadir un tipo nuevo en emergency_type.dart
/// hay que añadir aquí su guía: el compilador NO avisa si falta (el id
/// es un texto), solo fallaría al pulsar el botón.
Widget _guideFor(EmergencyType type) {
  return switch (type.id) {
    'cpr' => const CprGuideScreen(),
    'severe_bleeding' => const BleedingGuideScreen(),
    'choking' => const ChokingGuideScreen(),
    'fainting' => const FaintingGuideScreen(),
    'burn' => const BurnGuideScreen(),
    'seizure' => const SeizureGuideScreen(),
    'fracture' => const FractureGuideScreen(),
    _ => throw ArgumentError('Tipo de emergencia sin guía: ${type.id}'),
  };
}

/// Se muestra cuando la víctima está CONSCIENTE: en ese caso no
/// tiene sentido preguntar por la respiración con el flujo de
/// triaje (la persona está hablando/respondiendo), así que vamos
/// directo a que quien ayuda elija qué tipo de emergencia está
/// viendo (hemorragia, atragantamiento, quemadura, etc.).
///
/// Recorre la lista [emergencyTypes] (definida en
/// models/emergency_type.dart) para generar los botones; cada botón
/// abre la guía que indica [_guideFor].
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
                  MaterialPageRoute(builder: (_) => _guideFor(type)),
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
  final EmergencyType type;
  final VoidCallback onTap;

  const _EmergencyTypeButton({
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Altura mínima (no fija) para que el botón crezca si el texto
    // ocupa dos líneas.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 72),
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
            // Expanded: con la letra del sistema grande, las etiquetas
            // largas ("Fractura o esguince") pasan a dos líneas en vez
            // de salirse del botón.
            Expanded(
              child: Text(
                type.label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}