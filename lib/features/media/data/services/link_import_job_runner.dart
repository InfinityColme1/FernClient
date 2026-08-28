import 'package:Fern/core/services/jobs/job_runner.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:flutter/foundation.dart';

/// Se trae un enlace suelto y lo da de alta. Devuelve lo que ha entrado, o
/// `null` si no ha entrado nada.
///
/// Va por parámetro porque descargar y dar de alta son cosa de la capa de
/// datos, y esto es lo que decide **cuáles** y en qué orden.
typedef LinkFetcher = Future<MediaSummaryEntity?> Function({
  required String url,
  required String name,
  required ImportSource source,
  required String description,
  required List<String> sourceUrls,
  required bool asArchive,
});

/// Trae los enlaces que el usuario ha elegido en una tarea de revisión.
///
/// Es un trabajo aparte del de la importación a propósito: la respuesta llega a
/// destiempo —el usuario abre la tarea cuando le viene bien, a veces mucho
/// después— y para entonces la importación de la que salieron ya ha terminado.
/// Encolarlo aparte es lo que permite que contestar no dependa de que aquélla
/// siga viva.
class LinkImportJobRunner {
  final LinkFetcher _fetch;

  const LinkImportJobRunner({required LinkFetcher fetch}) : _fetch = fetch;

  /// Las direcciones que hay que traerse.
  static const urlsKey = 'urls';

  /// Cuáles de ellas son un comprimido, por su posición.
  static const archivesKey = 'archives';

  /// De qué fuente son, con qué se nombran y de qué publicación salieron.
  static const sourceKey = 'source';
  static const prefixKey = 'prefix';
  static const descriptionKey = 'description';
  static const sourceUrlsKey = 'sourceUrls';

  Future<void> call(JobContext context) => run(context);

  Future<void> run(JobContext context) async {
    final urls = _stringsOf(context, urlsKey);
    if (urls.isEmpty) return;

    final archives = {
      for (final index in context.payload<List<dynamic>>(archivesKey) ?? const [])
        if (index is int) index,
    };

    final source = ImportSource.fromId(context.payload<String>(sourceKey));
    final prefix = context.payload<String>(prefixKey) ?? 'link';
    final description = context.payload<String>(descriptionKey) ?? '';
    final sourceUrls = _stringsOf(context, sourceUrlsKey);

    context.report(0, total: urls.length);

    for (var index = 0; index < urls.length; index++) {
      context.token.throwIfCancelled();

      try {
        await _fetch(
          url: urls[index],
          name: '${prefix}_$index',
          source: source,
          description: description,
          sourceUrls: sourceUrls,
          asArchive: archives.contains(index),
        );
      } on Object catch (error) {
        // Un enlace que no se deja traer no se lleva por delante a los demás:
        // son de sitios distintos y cada uno falla por lo suyo.
        debugPrint('No se pudo traer ${urls[index]}: $error');
      }

      context.report(index + 1, total: urls.length);
    }
  }

  List<String> _stringsOf(JobContext context, String key) {
    final raw = context.payload<List<dynamic>>(key);
    if (raw == null) return const [];

    return [
      for (final one in raw)
        if (one is String) one,
    ];
  }
}
