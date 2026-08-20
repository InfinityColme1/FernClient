// Comprueba cómo se reparten las regiones de un fernie en celdas de la rejilla.
//
// Varios fotogramas seguidos de un video son la misma escena, y enseñarlos como
// cinco celdas casi identicas en fila no dice nada de lo que pasa en ellos. Se
// juntan en una sola celda que se mueve, y lo que esta separado en el tiempo
// sigue saliendo por separado.
//
// Lo que se comprueba aqui es el reparto, no el pase: agrupar es cosa de la
// interfaz, y lo importante es que por debajo no se pierda ninguna region.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_media_entity.dart';
import 'package:Fern/features/recognition/presentation/services/region_cells.dart';
import 'package:flutter_test/flutter_test.dart';

const _video = MediaSummaryEntity(id: 1, path: 'clip.mp4');
const _otherVideo = MediaSummaryEntity(id: 2, path: 'otro.mp4');
const _image = MediaSummaryEntity(id: 3, path: 'foto.jpg');
const _gif = MediaSummaryEntity(id: 4, path: 'baile.gif');

/// Una region de [media] en el instante [frameMs].
FernieRegionMediaEntity _at(
  int id,
  int? frameMs, {
  MediaSummaryEntity media = _video,
}) {
  return FernieRegionMediaEntity(
    region: FernieRegionEntity(
      id: id,
      mediaId: media.id,
      fernieId: 7,
      x: 0.1,
      y: 0.1,
      w: 0.2,
      h: 0.2,
      frameMs: frameMs,
    ),
    media: media,
  );
}

void main() {
  test('los fotogramas seguidos caben en una sola celda', () {
    final cells = groupRegionCells([
      _at(1, 0),
      _at(2, 33),
      _at(3, 66),
      _at(4, 99),
    ]);

    expect(cells, hasLength(1));
    expect(cells.single.id, 1, reason: 'se abre por el primero');
    expect(cells.single.frames, hasLength(4));
    expect(cells.single.ids, [1, 2, 3, 4]);
  });

  test('lo que esta separado sale por separado', () {
    // Cinco segundos entre uno y otro no son la misma escena por mucho que sean
    // del mismo video.
    final cells = groupRegionCells([
      _at(1, 0),
      _at(2, 33),
      _at(3, 5000),
    ]);

    expect(cells, hasLength(2));
    expect(cells.first.ids, [1, 2]);
    expect(cells.last.ids, [3]);
  });

  test('una region suelta no arrastra nada', () {
    final cells = groupRegionCells([_at(1, 500)]);

    expect(cells, hasLength(1));
    expect(cells.single.frames, isEmpty, reason: 'no hay nada que pasar');
    expect(cells.single.ids, [1]);
  });

  test('dos videos distintos no se mezclan', () {
    final cells = groupRegionCells([
      _at(1, 0),
      _at(2, 33, media: _otherVideo),
      _at(3, 66),
    ]);

    expect(cells, hasLength(3));
  });

  test('las imagenes nunca se agrupan', () {
    // Una imagen no tiene fotogramas que seguir, asi que dos regiones suyas son
    // dos celdas aunque vengan juntas.
    final cells = groupRegionCells([
      _at(1, null, media: _image),
      _at(2, null, media: _image),
    ]);

    expect(cells, hasLength(2));
    expect(cells.first.frames, isEmpty);
  });

  test('los GIF se quedan como estan', () {
    // Un GIF se anima solo en la celda: la miniatura es el fichero entero, no un
    // fotograma sacado con el reproductor. Agruparlo dejaria tres celdas
    // enseñando el mismo GIF y no un pase de sus fotogramas.
    final cells = groupRegionCells([
      _at(1, 0, media: _gif),
      _at(2, 40, media: _gif),
      _at(3, 80, media: _gif),
    ]);

    expect(cells, hasLength(3));
  });

  test('no se agrupa hacia atras', () {
    // La lista llega en el orden en el que se leyo: agrupar hacia atras
    // mezclaria dos idas y venidas por el mismo sitio del video.
    final cells = groupRegionCells([_at(1, 500), _at(2, 467)]);

    expect(cells, hasLength(2));
  });

  test('un tramo largo se pasa con unos cuantos, pero se lleva todos', () {
    final entries = [
      for (var index = 0; index < 200; index++) _at(index + 1, index * 33),
    ];

    final cell = groupRegionCells(entries).single;

    // Sacar un fotograma de un video abre un reproductor entero: doscientos
    // serian inaguantables.
    expect(cell.frames, hasLength(fernieRegionGroupMaxFrames));

    // Pero se marca y se borra el tramo entero, no lo que se ve moverse.
    expect(cell.ids, hasLength(200));

    // Repartidos de punta a punta.
    expect(cell.frames.first.frameMs, 0);
    expect(cell.frames.last.frameMs, 199 * 33);
  });
}
