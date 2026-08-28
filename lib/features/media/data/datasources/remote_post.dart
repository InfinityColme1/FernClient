import 'package:Fern/features/media/data/datasources/remote_media_item.dart';
import 'package:Fern/features/media/domain/entities/post_link.dart';

/// Una publicación de una fuente remota, con todo lo que puede traer.
///
/// No es lo mismo que un contenido: una publicación puede llevar varios
/// ficheros, y además enlaces a sitios donde hay más. Los ficheros se traen
/// solos; con los enlaces hay que decidir, porque no todos llevan a algo que se
/// pueda (o se deba) descargar.
///
/// Las fuentes que no tienen nada de esto (una publicación, un fichero) no
/// necesitan esto para nada y siguen hablando de contenidos sueltos.
class RemotePost {
  /// Identificador de la publicación, que es lo que marca por dónde se quedó
  /// la importación anterior.
  final String id;

  /// De qué listado sale, cuando la fuente tiene más de uno (un creador, por
  /// ejemplo). `null` si sólo hay uno.
  final String? collection;

  final String title;

  /// Lo que la publicación trae puesto, ya listo para descargar.
  final List<RemoteMediaItem> media;

  /// Lo que la publicación enlaza, ya clasificado.
  final List<PostLink> links;

  /// Direcciones que dicen de dónde sale, para el etiquetado por origen.
  final List<String> sourceUrls;

  const RemotePost({
    required this.id,
    required this.title,
    this.collection,
    this.media = const [],
    this.links = const [],
    this.sourceUrls = const [],
  });

  /// Los enlaces que la aplicación puede traerse por su cuenta.
  List<PostLink> get downloadableLinks => [
        for (final link in links)
          if (link.isDownloadable) link,
      ];

  /// Los que hacen falta que mire el usuario: una carpeta de un sitio de
  /// descargas, o un fichero suelto de uno que no deja bajarlo desde fuera.
  List<PostLink> get linksNeedingUser => [
        for (final link in links)
          if (link.needsUser) link,
      ];
}
