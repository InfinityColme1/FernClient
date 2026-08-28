import 'dart:convert';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/services/pending_link_reviews.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/post_link.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda las preguntas aparcadas para que sobrevivan a cerrar la aplicación.
///
/// **Por qué hace falta.** Una pregunta aparcada es lo contrario de una tarea en
/// marcha: se deja ahí justamente porque no corre prisa, y lo normal es
/// contestarla otro día. Si se perdiera al cerrar, aparcarla sería tirarla — y
/// con ella los enlaces de esa publicación, que ya no se pueden recuperar
/// porque la importación de la que salieron no se va a repetir.
///
/// Lo que se guarda es lo justo para volver a preguntar: de qué publicación era,
/// qué enlaces traía y de dónde salió. La tarea se vuelve a crear al arrancar,
/// con un identificador nuevo — el de antes no significaba nada fuera de aquella
/// sesión.
class LinkReviewsStorage {
  final SharedPreferences _preferences;

  const LinkReviewsStorage({required SharedPreferences preferences})
      : _preferences = preferences;

  /// Lo que quedó sin contestar la última vez.
  ///
  /// Una entrada que no se pueda leer se salta: entre perder una pregunta y no
  /// arrancar, lo primero.
  List<LinkReview> read() {
    final saved = _preferences.getStringList(pendingLinkReviewsPreferenceKey);
    if (saved == null) return const [];

    final reviews = <LinkReview>[];

    for (final entry in saved) {
      try {
        final one = _reviewOf(jsonDecode(entry) as Map<String, dynamic>);
        if (one != null) reviews.add(one);
      } on Object catch (error) {
        debugPrint('No se pudo leer una pregunta aparcada: $error');
      }
    }

    return reviews;
  }

  Future<void> write(List<LinkReview> reviews) async {
    if (reviews.isEmpty) {
      await _preferences.remove(pendingLinkReviewsPreferenceKey);
      return;
    }

    await _preferences.setStringList(
      pendingLinkReviewsPreferenceKey,
      [for (final review in reviews) jsonEncode(_jsonOf(review))],
    );
  }

  Map<String, dynamic> _jsonOf(LinkReview review) => {
        'title': review.postTitle,
        'source': review.source.id,
        'prefix': review.namePrefix,
        'sourceUrls': review.sourceUrls,
        'links': [
          for (final link in review.links)
            {
              'url': link.url,
              'kind': link.kind.name,
              if (link.directUrl != null) 'direct': link.directUrl,
            },
        ],
      };

  LinkReview? _reviewOf(Map<String, dynamic> json) {
    final links = json['links'];
    if (links is! List || links.isEmpty) return null;

    return LinkReview(
      // Se rellena al volver a crear la tarea: el de la sesión anterior no
      // significa nada en ésta.
      jobId: '',
      postTitle: json['title'] as String? ?? '',
      source: ImportSource.fromId(json['source'] as String?),
      namePrefix: json['prefix'] as String? ?? 'link',
      sourceUrls: [
        for (final url in json['sourceUrls'] as List? ?? const [])
          if (url is String) url,
      ],
      links: [
        for (final link in links)
          if (link is Map<String, dynamic> && link['url'] is String)
            PostLink(
              url: link['url'] as String,
              kind: PostLinkKind.values.firstWhere(
                (kind) => kind.name == link['kind'],
                orElse: () => PostLinkKind.other,
              ),
              directUrl: link['direct'] as String?,
            ),
      ],
    );
  }
}
