import 'package:flutter/material.dart';

/// Representa un tipo de emergencia seleccionable en el menú principal.
///
/// [id] se usa internamente (por ejemplo, para luego enrutar a la
/// pantalla de instrucciones correcta o guardar estadísticas),
/// nunca se muestra al usuario directamente.
class EmergencyType {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const EmergencyType({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

/// Lista de tipos de emergencia soportados, ordenada por urgencia
/// real (no alfabética): lo más crítico y con menor margen de
/// tiempo va primero, porque en el menú probablemente se muestre
/// de arriba a abajo y alguien en pánico tiende a elegir de los
/// primeros que ve.
///
/// Para añadir un nuevo tipo de emergencia hay que agregar una
/// entrada aquí y su guía en `_guideFor` (emergency_menu_screen.dart).
const List<EmergencyType> emergencyTypes = [
  EmergencyType(
    id: 'cpr',
    label: 'No respira / RCP',
    icon: Icons.monitor_heart,
    color: Colors.red,
  ),
  EmergencyType(
    id: 'severe_bleeding',
    label: 'Hemorragia grave',
    icon: Icons.bloodtype,
    color: Colors.redAccent,
  ),
  EmergencyType(
    id: 'choking',
    label: 'Atragantamiento',
    icon: Icons.no_food,
    color: Colors.deepOrange,
  ),
  EmergencyType(
    // Este menú solo se ve con la víctima consciente: cubre a quien se
    // marea o se ha desmayado y vuelve en sí. Si está inconsciente, el
    // triaje ya lleva a comprobar la respiración.
    id: 'fainting',
    label: 'Desmayo o mareo',
    icon: Icons.self_improvement,
    color: Colors.orange,
  ),
  EmergencyType(
    id: 'burn',
    label: 'Quemadura',
    icon: Icons.local_fire_department,
    color: Colors.deepOrangeAccent,
  ),
  EmergencyType(
    id: 'seizure',
    label: 'Convulsión',
    icon: Icons.bolt,
    color: Colors.amber,
  ),
  EmergencyType(
    id: 'fracture',
    label: 'Fractura o esguince',
    icon: Icons.accessibility_new,
    color: Colors.blueGrey,
  ),
];