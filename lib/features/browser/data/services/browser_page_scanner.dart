import 'dart:convert';

import 'package:Fern/features/browser/domain/entities/browser_media.dart';
import 'package:Fern/features/media/data/services/external_media_resolver.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Busca contenido en la página que el navegador está enseñando.
///
/// Se hace dentro de la página y no leyendo su texto por lo mismo que existe el
/// navegador: lo que hay en una página moderna no está en lo que el servidor
/// manda, sino en lo que el navegador acaba montando. Preguntándoselo a la
/// página se obtiene además dónde está cada cosa, que es lo que permite
/// señalarla cuando el usuario pasa por encima de su fila.
///
/// Lo que se recoge no se cree a ciegas: la última palabra sobre qué es
/// descargable la sigue teniendo el resolvedor, el mismo que usan las fuentes
/// remotas.
class BrowserPageScanner {
  final ExternalMediaResolver _resolver;

  const BrowserPageScanner({required ExternalMediaResolver resolver})
      : _resolver = resolver;

  /// Todo lo descargable que hay en la página, sin repetir y en el orden en el
  /// que la página lo pone.
  Future<List<BrowserMedia>> scan(InAppWebViewController controller) async {
    final result = await controller.evaluateJavascript(source: _scanScript);
    if (result == null) return const [];

    // Según la plataforma, lo que devuelve una página llega ya convertido o
    // como el texto que se devolvió.
    final Object? decoded;
    try {
      decoded = result is String ? jsonDecode(result) : result;
    } on FormatException {
      return const [];
    }
    if (decoded is! List) return const [];

    return [
      for (final entry in decoded)
        if (entry is Map)
          if (entry['url'] case final String url)
            if (_resolver.isPlayable(url))
              BrowserMedia(
                mark: entry['mark'] as String?,
                url: url,
                kind: entry['kind'] as String? ?? '',
                width: (entry['width'] as num?)?.round() ?? 0,
                height: (entry['height'] as num?)?.round() ?? 0,
              ),
    ];
  }

  /// Señala en la página el contenido de [mark], y quita lo que estuviera
  /// señalado antes. Sin [mark] sólo lo quita.
  ///
  /// Además lo trae a la vista: la lista puede estar hablando de algo que quedó
  /// mucho más abajo, y señalar lo que no se ve no dice nada.
  Future<void> highlight(
    InAppWebViewController controller, {
    String? mark,
    required String color,
  }) async {
    await controller.evaluateJavascript(
      source: _highlightScript(mark: mark, color: color),
    );
  }

  /// Deja la página a un tamaño en el que quepa más en la ventana.
  ///
  /// Se hace por el estilo de la propia página y no con el zoom del navegador
  /// porque eso último no lo hay en todas las plataformas.
  Future<void> setZoom(InAppWebViewController controller, double zoom) async {
    await controller.evaluateJavascript(
      source: 'document.documentElement.style.zoom = "$zoom";',
    );
  }
}

/// Recorre la página y devuelve lo que puede ser contenido.
///
/// Se mira lo que la página enseña (`img`, `source`, `video`) y los enlaces que
/// van directos a un fichero, y también lo que declara de sí misma con las
/// etiquetas para redes sociales, que en una página de vídeo es lo único que
/// apunta al vídeo de verdad.
///
/// A cada elemento se le deja puesta una marca (`data-fern-media`) para poder
/// volver a encontrarlo después sin depender de dónde estaba.
const _scanScript = r'''
(function () {
  var seen = {};
  var found = [];
  var next = 0;

  function add(element, url) {
    if (!url) return;

    var absolute;
    try { absolute = new URL(url, document.baseURI).href; } catch (e) { return; }
    if (seen[absolute]) return;
    seen[absolute] = true;

    var mark = null;
    var width = 0;
    var height = 0;

    if (element) {
      mark = String(next++);
      element.setAttribute('data-fern-media', mark);
      var box = element.getBoundingClientRect();
      width = Math.round(box.width);
      height = Math.round(box.height);
    }

    found.push({
      mark: mark,
      url: absolute,
      kind: element ? element.tagName.toLowerCase() : 'meta',
      width: width,
      height: height
    });
  }

  var declared = [
    'meta[property="og:video:secure_url"]',
    'meta[property="og:video"]',
    'meta[name="twitter:player:stream"]',
    'meta[property="og:image:secure_url"]',
    'meta[property="og:image"]'
  ].join(',');

  document.querySelectorAll(declared).forEach(function (tag) {
    add(null, tag.getAttribute('content'));
  });

  document.querySelectorAll('img, source, video, a').forEach(function (element) {
    add(element, element.currentSrc || element.getAttribute('src') ||
        element.getAttribute('href'));
  });

  return JSON.stringify(found);
})();
''';

/// Señala un elemento de la página, quitando antes lo que estuviera señalado.
///
/// El contorno que tuviera se guarda para poder devolvérselo: la página es del
/// usuario y esto no debería dejarla tocada.
String _highlightScript({required String? mark, required String color}) {
  final target = mark == null ? 'null' : '"$mark"';

  return '''
(function (mark) {
  document.querySelectorAll('[data-fern-outline]').forEach(function (element) {
    element.style.outline = element.getAttribute('data-fern-outline');
    element.style.boxShadow = element.getAttribute('data-fern-shadow') || '';
    element.style.outlineOffset = '';
    element.removeAttribute('data-fern-outline');
    element.removeAttribute('data-fern-shadow');
  });

  if (mark === null) return;

  var element = document.querySelector('[data-fern-media="' + mark + '"]');
  if (!element) return;

  element.setAttribute('data-fern-outline', element.style.outline || '');
  element.setAttribute('data-fern-shadow', element.style.boxShadow || '');
  element.style.outline = '6px solid $color';
  element.style.outlineOffset = '-3px';
  // Un halo oscuro por fuera del contorno: el color solo se pierde sobre una
  // página clara, y esto lo separa de lo que tenga detrás sea lo que sea.
  element.style.boxShadow = '0 0 0 3px rgba(0, 0, 0, 0.65)';
  element.scrollIntoView({ block: 'center' });
})($target);
''';
}
