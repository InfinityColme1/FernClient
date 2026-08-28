import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/utils/region_geometry.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_media_entity.dart';

/// Convierte las regiones de un fernie en las celdas de su rejilla.
///
/// La diferencia con pintarlas una a una está en el contenido que se mueve:
/// varios fotogramas seguidos de un vídeo **son la misma escena**, y enseñarlos
/// como cinco celdas casi idénticas en fila no dice nada de lo que pasa en
/// ellos. Se juntan en una sola celda que se mueve, y lo que está separado en el
/// tiempo sigue saliendo por separado.
///
/// Es sólo cosa de la interfaz: por debajo siguen siendo las regiones que son, y
/// por eso cada celda se lleva los identificadores de todas las suyas.
List<MediaCrop> groupRegionCells(List<FernieRegionMediaEntity> entries) {
  final cells = <MediaCrop>[];
  var run = <FernieRegionMediaEntity>[];

  void close() {
    if (run.isEmpty) return;
    cells.add(_toCell(run));
    run = [];
  }

  for (final entry in entries) {
    if (run.isEmpty || _continues(run.last, entry)) {
      run.add(entry);
      continue;
    }

    close();
    run.add(entry);
  }

  close();
  return cells;
}

/// Si [next] sigue a [previous] dentro del mismo tramo.
///
/// Tienen que ser del mismo fichero, del mismo vídeo (una imagen no tiene
/// fotogramas que seguir) y venir después, no antes: la lista llega en el orden
/// en el que se leyó, y agrupar hacia atrás mezclaría dos idas y venidas por el
/// mismo sitio.
bool _continues(
  FernieRegionMediaEntity previous,
  FernieRegionMediaEntity next,
) {
  if (previous.media.id != next.media.id) return false;
  if (!next.media.path.isVideoPath) return false;

  final from = previous.region.frameMs;
  final to = next.region.frameMs;
  if (from == null || to == null) return false;

  final gap = to - from;
  return gap > 0 && gap <= fernieRegionGroupGap.inMilliseconds;
}

MediaCrop _toCell(List<FernieRegionMediaEntity> run) {
  final first = run.first;

  return MediaCrop(
    id: first.region.id,
    media: first.media,
    crop: _cropOf(first),
    // Un tramo de uno se comporta como siempre: la celda es su recorte y no hay
    // nada que pasar.
    frames: run.length < 2
        ? const []
        : [for (final entry in _sample(run)) _cropOf(entry)],
    // Los identificadores van todos, también los de los fotogramas que no se
    // enseñan: lo que se marca y lo que se borra es el tramo entero.
    regionIds: run.length < 2
        ? const []
        : [for (final entry in run) entry.region.id],
  );
}

RegionCrop _cropOf(FernieRegionMediaEntity entry) => RegionCrop(
      x: entry.region.x,
      y: entry.region.y,
      w: entry.region.w,
      h: entry.region.h,
      frameMs: entry.region.frameMs,
    );

/// Los fotogramas que se van a pasar, repartidos por el tramo.
///
/// Sacar un fotograma de un vídeo abre un reproductor entero, así que un tramo
/// largo no se pasa completo. Se cogen repartidos y contando siempre el primero
/// y el último: lo que hace falta es que se vea el movimiento de punta a punta,
/// no tenerlos todos.
List<FernieRegionMediaEntity> _sample(List<FernieRegionMediaEntity> run) {
  const max = fernieRegionGroupMaxFrames;
  if (run.length <= max) return run;

  final last = run.length - 1;

  return [
    for (var index = 0; index < max; index++)
      run[(index * last / (max - 1)).round()],
  ];
}
