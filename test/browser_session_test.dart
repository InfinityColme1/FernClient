// A qué plataforma pertenece lo que se está viendo en el navegador de la
// aplicación.
//
// Es lo que decide de dónde se recoge la sesión, así que confundirse aquí
// significaría guardar como sesión de una plataforma una cookie de otra. La
// lectura de la cookie en sí no se prueba: eso es el navegador, y sin navegador
// no hay nada que leer.

import 'package:Fern/features/browser/data/services/browser_session_service.dart';
import 'package:Fern/features/browser/domain/entities/browser_session_source.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sessions = BrowserSessionService();

  group('de qué plataforma es la página que se está viendo', () {
    test('la reconoce por su dominio', () {
      expect(
        sessions.sourceOf(Uri.parse('https://www.pixiv.net/artworks/123'))?.source,
        ImportSource.pixiv,
      );
    });

    test('vale cualquier página que cuelgue de ella', () {
      expect(
        sessions.sourceOf(Uri.parse('https://accounts.www.pixiv.net/login'))
            ?.source,
        ImportSource.pixiv,
      );
    });

    test('un dominio que acaba igual no cuela', () {
      expect(sessions.sourceOf(Uri.parse('https://nowww.pixiv.net.evil.test/')),
          isNull);
    });

    test('un sitio del que no se importa no es ninguna', () {
      expect(sessions.sourceOf(Uri.parse('https://example.test/')), isNull);
      expect(sessions.sourceOf(null), isNull);
    });
  });

  group('lo recogido va al ajuste de su plataforma', () {
    test('la sesión de Pixiv acaba en las credenciales de Pixiv', () {
      final pixiv = browserSessionSources.firstWhere(
        (each) => each.source == ImportSource.pixiv,
      );

      final settings = pixiv.apply(
        const AppSettingsEntity(avatarsPath: '', recognitionPath: ''),
        '1234567_abcdefghij',
      );

      expect(settings.pixiv.sessionId, '1234567_abcdefghij');
      // Y con eso la fuente ya se puede usar, que es de lo que se trataba.
      expect(settings.pixiv.isComplete, isTrue);
    });
  });
}
