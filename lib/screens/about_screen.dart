import 'package:flutter/material.dart';

/// "Aviso y créditos": el aviso legal completo, el estado de revisión
/// del contenido y la atribución de las imágenes (varias son
/// CC BY-SA y la licencia exige citarlas dentro de la app).
///
/// Se abre desde un enlace discreto en la primera pantalla; no forma
/// parte del flujo de una emergencia.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _credits = <_Credit>[
    _Credit(
      'Colocación de las manos e inclinación de la cabeza (RCP)',
      'Another-anon-artist-234, Wikimedia Commons',
      'Dominio público (CC0 1.0)',
    ),
    _Credit('Víctima boca arriba', 'Asanagi, Wikimedia Commons', 'Dominio público (CC0 1.0)'),
    _Credit(
      'Arrodillarse junto a la víctima',
      'Illinois Waterway Visitor Center, US Army Corps of Engineers, Wikimedia Commons',
      'Dominio público',
    ),
    _Credit('Insuflaciones', 'Rama, Wikimedia Commons', 'CC BY-SA 3.0 FR'),
    _Credit('Golpes en la espalda (atragantamiento)', 'Trakotako, Wikimedia Commons', 'CC BY-SA 4.0'),
    _Credit('Compresiones abdominales', 'Rama, Wikimedia Commons', 'CC BY-SA 3.0 FR'),
    _Credit(
      'Posición del puño',
      'US Army Medical Department Center and School, Wikimedia Commons',
      'Dominio público',
    ),
    _Credit('Cabestrillo', 'U.S. Navy, Wikimedia Commons', 'Dominio público'),
    _Credit(
      'Posición lateral de seguridad',
      'Hibernate (concepto original de Leone), Wikimedia Commons',
      'CC BY-SA 3.0',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const body = TextStyle(color: Colors.white70, fontSize: 15, height: 1.4);
    const heading = TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('Aviso y créditos')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Aviso importante', style: heading),
            const SizedBox(height: 8),
            const Text(
              'Auxilio es una guía orientativa para ayudarte a actuar mientras llega la ayuda. '
              'No sustituye a los servicios de emergencia ni a la formación en primeros auxilios, '
              'y no es un producto sanitario: no diagnostica ni trata a nadie.\n\n'
              'Ante una emergencia, llama siempre al 112 y sigue las indicaciones de quien te atienda; '
              'si te dicen algo distinto de lo que pone aquí, haz caso al 112.\n\n'
              'Las instrucciones siguen las recomendaciones del Consejo Europeo de Resucitación (2021) '
              'para personas sin formación sanitaria.',
              style: body,
            ),
            const SizedBox(height: 24),
            const Text('Privacidad', style: heading),
            const SizedBox(height: 8),
            const Text(
              'La app no tiene cuentas, no envía tus datos a ningún servidor y no guarda nada sobre ti. '
              'El micrófono solo se usa, mientras ves una guía, para entender «siguiente» o «repite». '
              'Ese reconocimiento de voz lo hace el propio sistema del móvil (Google o Apple), '
              'que puede procesar el audio en sus servidores según su política de privacidad.',
              style: body,
            ),
            const SizedBox(height: 24),
            const Text('Imágenes', style: heading),
            const SizedBox(height: 8),
            for (final c in _credits) ...[
              Text(c.what, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              Text('${c.author}. ${c.license}.', style: body),
              const SizedBox(height: 10),
            ],
            const Text(
              'Las imágenes con licencia CC BY-SA se han redimensionado y se distribuyen con la misma licencia. '
              'Enlaces a los originales en el repositorio del proyecto (assets/images/CREDITS.md).',
              style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => showLicensePage(context: context, applicationName: 'Auxilio'),
              icon: const Icon(Icons.description_outlined),
              label: const Text('Licencias del software'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Credit {
  final String what;
  final String author;
  final String license;
  const _Credit(this.what, this.author, this.license);
}
