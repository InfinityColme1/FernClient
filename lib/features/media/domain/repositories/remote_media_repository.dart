import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';

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
  Stream<DataState<MediaSummaryEntity>> scanRemoteSource(
    ImportSource source, {
    bool untilLastImport,
  });
}
