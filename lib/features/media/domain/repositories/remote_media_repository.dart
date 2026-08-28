import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/remote_creator.dart';

/// El contenido que el usuario tiene guardado en otras plataformas.
///
/// Hace con las fuentes remotas lo mismo que el escaneo de una carpeta hace con
/// el equipo: va trayendo lo que encuentra y no está todavía, de uno en uno,
/// para que la rejilla lo pinte según llega. La diferencia es que aquí "traer"
/// incluye descargarse el fichero.
abstract class RemoteMediaRepository {
  /// Descarga y da de alta lo que el usuario tenga guardado en [source] y no
  /// esté ya en la aplicación.
  ///
  /// [source] tiene que ser una fuente remota. Si no está configurada en los
  /// ajustes, o si la plataforma no acepta las credenciales, el flujo devuelve
  /// el fallo y se acaba.
  ///
  /// Con [untilLastImport] se para al llegar a donde se quedó la importación
  /// anterior, en lugar de recorrer la cuenta entera: es lo que trae "sólo lo
  /// guardado desde la última vez". La primera vez, sin nada con lo que
  /// comparar, se recorre todo.
  ///
  /// [creators] recorta el escaneo a unos creadores concretos de la fuente, con
  /// las claves que da [remoteCreators]. Vacío es todo, que es lo de siempre.
  Stream<DataState<MediaSummaryEntity>> scanRemoteSource(
    ImportSource source, {
    bool untilLastImport,
    Set<String> creators,
  });

  /// Los creadores que el usuario sigue o tiene marcados en [source].
  ///
  /// Salen **sin contar** sus publicaciones nuevas: contarlas es una petición
  /// por creador, y con cincuenta marcados eso serían cincuenta esperas antes de
  /// poder enseñar nada. Para eso está [countNewPosts], que se llama después y
  /// va rellenando la lista.
  ///
  /// Una fuente que no sepa dar esta lista devuelve la lista vacía. Hoy sólo la
  /// da Pawchive: las demás necesitan que se compruebe su camino de red con una
  /// sesión de verdad abierta, que es lo mismo que le pasa a Reddit.
  Future<DataState<List<RemoteCreator>>> remoteCreators(ImportSource source);

  /// Cuántas publicaciones nuevas tiene [creator] desde el último escaneo.
  ///
  /// `null` cuando no se puede saber: o la fuente no lo da, o esa cuenta no se
  /// ha mirado nunca y entonces no hay «nuevas», hay todas.
  Future<int?> countNewPosts(ImportSource source, RemoteCreator creator);
}
