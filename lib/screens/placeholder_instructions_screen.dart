import 'package:flutter/material.dart';

/// Pantalla temporal ("en construcción") que se usa como destino
/// provisional en cualquier punto del flujo cuyo contenido real
/// todavía no hemos escrito (por ejemplo, las instrucciones de RCP
/// o de posición lateral de seguridad).
///
/// Objetivo: poder probar que TODA la navegación del árbol de
/// decisión funciona de principio a fin, antes de invertir tiempo
/// en el contenido detallado de cada rama.
///
/// Cuando se escriba el contenido real de un destino, esta pantalla
/// se reemplaza por la definitiva y se elimina su uso en ese punto
/// concreto (pero puede seguir sirviendo para los destinos que aún
/// falten).
class PlaceholderInstructionsScreen extends StatelessWidget {
  final String title;

  const PlaceholderInstructionsScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.construction,
                color: Colors.amber,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Instrucciones detalladas pendientes de escribir.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}