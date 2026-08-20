import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_media_entity.dart';

/// Todo lo que se puede hacer con fernies y con sus regiones.
///
/// Va aparte de `LocalMediaRepository` y no dentro: aquél ya mezcla contenido,
/// etiquetas, creadores y búsqueda en más de mil quinientas líneas, y el
/// reconocimiento es un dominio propio con su propia vida.
abstract class FernieRepository {
  /// Todos los fernies, cada uno con el recuento de regiones y de contenidos
  /// distintos sobre los que están marcadas.
  Future<DataState<List<FernieEntity>>> getFernies();

  Future<DataState<FernieEntity>> getFernie(int id);

  /// Fernies cuyo nombre se parece a [query]. Con el texto vacío no devuelve
  /// nada, igual que el resto de buscadores de la aplicación.
  Future<DataState<List<FernieEntity>>> searchFernies(String query);

  /// Alta. Devuelve el fernie ya con su identificador definitivo.
  Future<DataState<FernieEntity>> saveFernie(FernieEntity fernie);

  /// Cambia nombre, avatar y enlace. Las regiones no se tocan.
  Future<DataState<FernieEntity>> updateFernie(FernieEntity fernie);

  /// Borra el fernie y, con él, todas sus regiones.
  Future<DataState<bool>> deleteFernie(int id);

  /// Guarda varias regiones de golpe, cada una para el fernie que diga su
  /// `fernieId`. Es lo que hace aceptar una sesión de modo fernie: todo lo
  /// marcado entra en una sola transacción o no entra nada.
  Future<DataState<List<FernieRegionEntity>>> addRegions(
    List<FernieRegionEntity> regions,
  );

  /// Cambia el rectángulo (y el fernie, si se ha reasignado) de una región que
  /// ya existe.
  Future<DataState<FernieRegionEntity>> updateRegion(FernieRegionEntity region);

  Future<DataState<bool>> deleteRegion(int id);

  /// Borra las regiones de estos contenidos. Lo llama el borrado definitivo:
  /// mandar a la papelera no borra regiones, porque de la papelera se vuelve.
  Future<DataState<int>> deleteRegionsOfMedia(List<int> mediaIds);

  Future<DataState<List<FernieRegionEntity>>> getRegionsOfFernie(int fernieId);

  /// Las regiones marcadas sobre un contenido. Es lo que el modo fernie pinta
  /// al entrar.
  Future<DataState<List<FernieRegionEntity>>> getRegionsOfMedia(int mediaId);

  /// Los fernies que tienen alguna región en este contenido, que son los que
  /// enseña el panel de información.
  Future<DataState<List<FernieEntity>>> getFerniesOfMedia(int mediaId);

  /// Las regiones de un fernie con el contenido de cada una, para la rejilla de
  /// la pantalla de fernies.
  Future<DataState<List<FernieRegionMediaEntity>>> getMediaOfFernie(
    int fernieId,
  );
}
