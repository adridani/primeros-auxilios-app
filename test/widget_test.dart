import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:primeros_auxilios_app/main.dart';

void main() {
  testWidgets('La app arranca mostrando la pantalla de confirmación de emergencia',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PrimerosAuxiliosApp());

    // Comprueba que aparece el texto de la pantalla de confirmación.
    expect(find.text('¿Es esta una emergencia real?'), findsOneWidget);
  });
}