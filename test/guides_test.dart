import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:primeros_auxilios_app/main.dart';
import 'package:primeros_auxilios_app/screens/bleeding_guide_screen.dart';
import 'package:primeros_auxilios_app/screens/burn_guide_screen.dart';
import 'package:primeros_auxilios_app/screens/choking_guide_screen.dart';
import 'package:primeros_auxilios_app/screens/cpr_compression_screen.dart';
import 'package:primeros_auxilios_app/screens/cpr_guide_screen.dart';
import 'package:primeros_auxilios_app/screens/fainting_guide_screen.dart';
import 'package:primeros_auxilios_app/screens/fracture_guide_screen.dart';
import 'package:primeros_auxilios_app/screens/recovery_monitoring_screen.dart';
import 'package:primeros_auxilios_app/screens/recovery_position_screen.dart';
import 'package:primeros_auxilios_app/screens/seizure_guide_screen.dart';
import 'package:primeros_auxilios_app/services/voice_guide_service.dart';
import 'package:primeros_auxilios_app/widgets/elapsed_timer.dart';

/// Recorre cada guía paso a paso como lo haría una persona (pulsando
/// "Siguiente" hasta el final) en un móvil pequeño y con la letra del
/// sistema grande, para detectar a la vez:
///  - pasos que no avanzan o una pantalla final que no aparece;
///  - textos o imágenes que se desbordan (Flutter lo marca como error
///    y el test falla);
///  - que el botón de alarma lleve a donde debe.
void main() {
  setUp(() {
    // En los tests no hay micrófono: se responde "permiso denegado"
    // para que la guía no se quede esperando a la voz.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (call) async => call.method == 'requestPermissions' ? {7: 0} : 0,
    );
  });

  /// Móvil pequeño (360x600) con la letra un 30 % más grande.
  void useSmallPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(360, 600);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  /// Pulsa "Siguiente" en cada paso y "Hecho" en el último. Devuelve
  /// cuando ya se ve la pantalla "Mientras llega la ayuda".
  Future<void> walkGuide(WidgetTester tester, Widget guide, int steps) async {
    useSmallPhone(tester);
    await tester.pumpWidget(MaterialApp(home: guide));
    await tester.pumpAndSettle();
    for (var i = 1; i <= steps; i++) {
      expect(find.text('Paso $i de $steps'), findsOneWidget);
      await tester.tap(find.text(i == steps ? 'Hecho' : 'Siguiente'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Mientras llega la ayuda'), findsOneWidget);
  }

  /// Pulsa el botón de alarma de la pantalla final. Primero comprueba
  /// que un toque inmediato (doble toque nervioso sobre "Hecho") NO
  /// hace nada, y luego que pasado un segundo sí funciona.
  Future<void> pressAlarm(WidgetTester tester, String label) async {
    await tester.tap(find.text(label), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Mientras llega la ayuda'), findsOneWidget,
        reason: 'la alarma no debe responder justo al abrirse la pantalla');

    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text(label));
    // pump con tiempo en vez de pumpAndSettle: algunas pantallas de
    // destino tienen contadores que no paran nunca.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  /// Desmonta todo para que no queden temporizadores vivos al acabar.
  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  }

  test('Órdenes de voz: "siguiente" avanza y "repite" vuelve a leer el paso', () {
    expect(VoiceGuideService.commandFromWords('Siguiente'), VoiceCommand.next);
    expect(VoiceGuideService.commandFromWords('vale'), VoiceCommand.next);
    expect(VoiceGuideService.commandFromWords('repite por favor'), VoiceCommand.repeat);
    expect(VoiceGuideService.commandFromWords('Repítelo'), VoiceCommand.repeat);
    expect(VoiceGuideService.commandFromWords('otra vez'), VoiceCommand.repeat);
    expect(VoiceGuideService.commandFromWords('no te he entendido'), VoiceCommand.repeat);
    // Si dice las dos, gana repetir: volver a oírlo es inofensivo.
    expect(VoiceGuideService.commandFromWords('vale, repite'), VoiceCommand.repeat);
    expect(VoiceGuideService.commandFromWords('¿qué hago?'), VoiceCommand.none);
  });

  testWidgets('Pantalla final: responder NO muestra qué seguir haciendo y no cambia de pantalla',
      (tester) async {
    await walkGuide(tester, const BleedingGuideScreen(), 5);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('NO, sigue respondiendo'));
    await tester.pump();
    expect(find.textContaining('Sigue apretando la herida sin soltar y vigílala'), findsOneWidget);
    expect(find.text('Mientras llega la ayuda'), findsOneWidget);
    // El botón NO queda marcado para que se note que se ha pulsado.
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    await finish(tester);
  });

  testWidgets('Convulsión: el tiempo se ve en todos los pasos y avisa en rojo a los 5 minutos',
      (tester) async {
    // Reloj simulado: permite "adelantar" 5 minutos sin esperarlos.
    var fakeNow = DateTime(2026, 1, 1, 12);
    ElapsedTimer.now = () => fakeNow;
    addTearDown(() => ElapsedTimer.now = DateTime.now);

    useSmallPhone(tester);
    await tester.pumpWidget(const MaterialApp(home: SeizureGuideScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Tiempo de convulsión: 00:00'), findsOneWidget);
    expect(find.text('Más de 5 minutos: avisa a emergencias.'), findsNothing);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    fakeNow = fakeNow.add(const Duration(minutes: 2, seconds: 5));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Paso 2 de 4'), findsOneWidget);
    expect(find.text('Tiempo de convulsión: 02:05'), findsOneWidget);

    fakeNow = fakeNow.add(const Duration(minutes: 3));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Tiempo de convulsión: 05:05'), findsOneWidget);
    expect(find.text('Más de 5 minutos: avisa a emergencias.'), findsOneWidget);

    // En la pantalla final sigue el mismo tiempo, no vuelve a cero.
    for (final label in ['Siguiente', 'Siguiente', 'Hecho']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    expect(find.text('Mientras llega la ayuda'), findsOneWidget);
    expect(find.text('Tiempo de convulsión: 05:05'), findsOneWidget);
    expect(find.text('Más de 5 minutos: avisa a emergencias.'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('"Ya ha llamado otra persona" pasa al triaje sin llamar', (tester) async {
    useSmallPhone(tester);
    await tester.pumpWidget(const PrimerosAuxiliosApp());
    await tester.ensureVisible(find.text('SÍ, es una emergencia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SÍ, es una emergencia'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ya ha llamado otra persona'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ya ha llamado otra persona'));
    await tester.pumpAndSettle();
    expect(find.text('¿Está consciente?'), findsOneWidget);
    expect(find.text('Llamada de emergencia en curso'), findsNothing);
    // "Atrás" no vuelve a la pantalla de llamar, sino al inicio.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Vamos a llamar al 112'), findsNothing);
    expect(find.text('¿Es esta una emergencia real?'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('"Prepara tu móvil" se abre desde el inicio y cabe en un móvil pequeño', (tester) async {
    useSmallPhone(tester);
    await tester.pumpWidget(const PrimerosAuxiliosApp());
    await tester.ensureVisible(find.text('Prepara tu móvil para una emergencia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prepara tu móvil para una emergencia'));
    await tester.pumpAndSettle();
    expect(find.text('Altavoz automático en las llamadas'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Probar la voz'), 200);
    expect(find.text('Probar la voz'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('Casita: desde una guía vuelve al menú de emergencias', (tester) async {
    useSmallPhone(tester);
    await tester.pumpWidget(const MaterialApp(home: BurnGuideScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();
    expect(find.text('¿Qué está pasando?'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('Casita en la RCP: pide confirmación antes de salir', (tester) async {
    useSmallPhone(tester);
    await tester.pumpWidget(const MaterialApp(home: CprCompressionScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byIcon(Icons.home));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('¿Volver al menú?'), findsOneWidget);

    // "Seguir aquí" no sale de la RCP.
    await tester.tap(find.text('Seguir aquí'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('RCP en curso'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Volver al menú'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('¿Qué está pasando?'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('Vigilando a la víctima: responder NO (respira bien) muestra qué seguir haciendo',
      (tester) async {
    useSmallPhone(tester);
    await tester.pumpWidget(const MaterialApp(home: RecoveryMonitoringScreen()));
    await tester.pump(const Duration(seconds: 1));
    await tester.ensureVisible(find.text('NO, respira con normalidad'));
    await tester.tap(find.text('NO, respira con normalidad'));
    await tester.pump();
    expect(find.textContaining('Sigue vigilando'), findsOneWidget);
    expect(find.text('Vigilando a la víctima'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('Hemorragia: 5 pasos y "ha dejado de responder" lleva a comprobar la respiración',
      (tester) async {
    await walkGuide(tester, const BleedingGuideScreen(), 5);
    await pressAlarm(tester, 'SÍ → Comprobar si respira');
    expect(find.text('¿Respira?'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('Atragantamiento: 5 pasos y "ha perdido el conocimiento" lleva a la RCP',
      (tester) async {
    await walkGuide(tester, const ChokingGuideScreen(), 5);
    await pressAlarm(tester, 'SÍ → Empezar RCP');
    expect(find.text('Túmbala boca arriba'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('Desmayo: 4 pasos y "no despierta" lleva a comprobar la respiración',
      (tester) async {
    await walkGuide(tester, const FaintingGuideScreen(), 4);
    await pressAlarm(tester, 'SÍ → Comprobar si respira');
    expect(find.text('¿Respira?'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('Quemadura: 4 pasos y "ha dejado de responder" lleva a comprobar la respiración',
      (tester) async {
    await walkGuide(tester, const BurnGuideScreen(), 4);
    await pressAlarm(tester, 'SÍ → Comprobar si respira');
    expect(find.text('¿Respira?'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('Convulsión: 4 pasos, y al terminar, si respira, lleva a la posición lateral',
      (tester) async {
    await walkGuide(tester, const SeizureGuideScreen(), 4);
    await pressAlarm(tester, 'SÍ → Comprobar si respira');
    expect(find.text('¿Respira?'), findsOneWidget);
    await tester.tap(find.text('SÍ respira'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byType(RecoveryPositionScreen), findsOneWidget);
    await finish(tester);
  });

  testWidgets('Fractura: 4 pasos y "sangra mucho" lleva a la guía de hemorragia',
      (tester) async {
    await walkGuide(tester, const FractureGuideScreen(), 4);
    await pressAlarm(tester, 'SÍ → Guía de hemorragia');
    expect(find.text('Protégete'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('RCP y posición lateral: los pasos caben en un móvil pequeño', (tester) async {
    useSmallPhone(tester);
    await tester.pumpWidget(const MaterialApp(home: CprGuideScreen()));
    await tester.pumpAndSettle();
    for (var i = 1; i <= 3; i++) {
      expect(find.text('Paso $i de 3'), findsOneWidget);
      if (i < 3) {
        await tester.tap(find.text('Siguiente'));
        await tester.pumpAndSettle();
      }
    }

    await tester.pumpWidget(const MaterialApp(home: RecoveryPositionScreen()));
    await tester.pumpAndSettle();
    for (var i = 1; i <= 5; i++) {
      expect(find.text('Paso $i de 5'), findsOneWidget);
      if (i < 5) {
        await tester.tap(find.text('Siguiente'));
        await tester.pumpAndSettle();
      }
    }
    await finish(tester);
  });

  testWidgets('Triaje: emergencia → consciente → el menú abre cada una de las 7 guías',
      (tester) async {
    useSmallPhone(tester);
    await tester.pumpWidget(const PrimerosAuxiliosApp());
    // Con la letra grande algunos botones quedan por debajo: se
    // desplaza la pantalla hasta ellos, como haría una persona.
    await tester.ensureVisible(find.text('SÍ, es una emergencia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SÍ, es una emergencia'));
    await tester.pumpAndSettle();
    // Antes de llamar se explica qué va a pasar.
    expect(find.text('Vamos a llamar al 112'), findsOneWidget);
    expect(find.text('Pon el altavoz'), findsOneWidget);
    await tester.ensureVisible(find.text('Llamar al 112'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Llamar al 112'));
    // La llamada simulada tarda 600 ms.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('¿Está consciente?'), findsOneWidget);
    expect(find.text('Llamada de emergencia en curso'), findsOneWidget);
    // main.dart ignora una segunda navegación si llega antes de 600 ms
    // (reales, no del reloj simulado del test) desde la anterior, para
    // evitar dobles toques: se espera de verdad como haría una persona.
    await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 700)));
    await tester.ensureVisible(find.text('SÍ, responde'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SÍ, responde'));
    await tester.pumpAndSettle();
    expect(find.text('¿Qué está pasando?'), findsOneWidget);
    // Espera a que se vaya el aviso de "llamada simulada", que tapa
    // la parte de abajo de la pantalla durante unos segundos.
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    const expectedTitles = {
      'No respira / RCP': 'RCP',
      'Hemorragia grave': 'Hemorragia grave',
      'Atragantamiento': 'Atragantamiento',
      'Desmayo o mareo': 'Desmayo o mareo',
      'Quemadura': 'Quemadura',
      'Convulsión': 'Convulsión',
      'Fractura o esguince': 'Fractura o esguince',
    };
    for (final entry in expectedTitles.entries) {
      await tester.scrollUntilVisible(find.text(entry.key), 100);
      await tester.tap(find.text(entry.key));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, entry.value), findsOneWidget, reason: entry.key);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('¿Qué está pasando?'), findsOneWidget);
    }
    await finish(tester);
  });
}
