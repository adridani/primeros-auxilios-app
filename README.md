# Auxilio · Primeros Auxilios

App de Flutter que guía paso a paso, con voz, en una emergencia: triaje
(¿responde?, ¿respira?), llamada al 112, RCP con metrónomo, posición
lateral de seguridad y guías para hemorragia, atragantamiento, desmayo,
quemadura, convulsión y fractura.

- Identificador: `com.adridani.primerosauxilios`
- Nombre bajo el icono: **Auxilio** · Nombre en la tienda: **Primeros Auxilios: Guía SOS**
- Diseños del icono: `design/icono/`
- Créditos de las imágenes: `assets/images/CREDITS.md`

## Antes de publicar

- Revisión del contenido por personal de emergencias.
- En `lib/services/emergency_call_service.dart`: poner el número 112 y
  `kSimulateEmergencyCall = false`.

## Desarrollo

```bash
flutter test
flutter run
```
