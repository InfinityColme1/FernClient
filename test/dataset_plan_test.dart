// Como se reparte un dataset YOLO a partir de las regiones marcadas.
//
// Es la prueba clave de la fase 3, y lo es por una sola razon: **el reparto va
// por contenido, no por region**. Un fichero puede llevar diez regiones; si unas
// cayeran en entrenamiento y otras en validacion, el modelo se estaria
// examinando de la misma imagen con la que ha estudiado y las metricas dirian lo
// que uno quiere oir. Es el error clasico de estos datasets, no da la cara —el
// entrenamiento funciona, las cifras salen preciosas— y solo se descubre cuando
// el modelo falla con contenido de verdad.
//
// Lo demas que se comprueba aqui:
//
// - La conversion de esquina a centro, que es donde se cuela el otro error
//   clasico: una region pegada al borde superior izquierdo tiene su centro en
//   0.05, no en cero.
// - Que el reparto es el mismo siempre para los mismos datos, o reentrenar sin
//   cambios daria metricas distintas y no habria forma de comparar nada.

import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/services/dataset_plan.dart';
import 'package:flutter_test/flutter_test.dart';

var _nextId = 0;

DatasetRegion _region({
  required int mediaId,
  int classIndex = 0,
  int? frameMs,
  double x = 0.2,
  double y = 0.2,
  double w = 0.3,
  double h = 0.3,
}) {
  return DatasetRegion(
    regionId: _nextId++,
    mediaId: mediaId,
    mediaPath: 'C:/biblioteca/$mediaId.jpg',
    frameMs: frameMs,
    x: x,
    y: y,
    w: w,
    h: h,
    classIndex: classIndex,
  );
}

/// Un reparto de una sola clase, con los porcentajes que se le den.
DatasetPlan _plan(
  List<DatasetRegion> regions, {
  DatasetSplit split = DatasetSplit.balanced,
  Map<int, DatasetSplit>? splits,
  int seed = 0,
}) {
  final classes = {for (final region in regions) region.classIndex};

  return planDataset(
    regions: regions,
    splitByClass: splits ?? {for (final index in classes) index: split},
    namesByClass: {for (final index in classes) index: 'clase$index'},
    seed: seed,
  );
}

/// Cuantas regiones de [classIndex] han caido en cada parte.
///
/// Es la cuenta que importa: los porcentajes son de las regiones del fernie, no
/// de cuantos ficheros suyos hay.
Map<DatasetSplitKind, int> _regionsBySplit(DatasetPlan plan, int classIndex) {
  final counts = {for (final kind in DatasetSplitKind.values) kind: 0};

  for (final image in plan.images) {
    for (final label in image.labels) {
      if (label.classIndex != classIndex) continue;
      counts[image.split] = counts[image.split]! + 1;
    }
  }

  return counts;
}

/// A que parte fue a parar cada contenido.
Map<int, DatasetSplitKind> _splitByMedia(DatasetPlan plan) {
  return {for (final image in plan.images) image.mediaId: image.split};
}

void main() {
  setUp(() => _nextId = 0);

  group('ninguna imagen en dos sitios', () {
    test('las regiones de un mismo fichero van juntas', () {
      // Cada fichero, con varios fotogramas y varias regiones en cada uno: es lo
      // que hace que la comprobacion tenga algo que comprobar. Con un solo
      // fotograma por fichero, sus regiones caen en la misma imagen por
      // construccion y esto no podria fallar aunque el reparto estuviera roto.
      final plan = _plan([
        for (var media = 1; media <= 4; media++)
          for (var frame = 0; frame < 3; frame++)
            for (var region = 0; region < 2; region++)
              _region(mediaId: media, frameMs: frame * 40),
      ]);

      final byMedia = <int, Set<DatasetSplitKind>>{};
      for (final image in plan.images) {
        (byMedia[image.mediaId] ??= {}).add(image.split);
      }

      for (final entry in byMedia.entries) {
        expect(
          entry.value,
          hasLength(1),
          reason: 'el contenido ${entry.key} esta en ${entry.value}',
        );
      }
    });

    test('los fotogramas de un mismo video tampoco se separan', () {
      // Un video marcado fotograma a fotograma son muchas imagenes casi
      // identicas: repartirlas entre train y val es copiarse en el examen de la
      // forma mas descarada posible.
      final plan = _plan([
        for (var frame = 0; frame < 20; frame++)
          _region(mediaId: 7, frameMs: frame * 33),
      ]);

      final splits = {for (final image in plan.images) image.split};

      expect(plan.images, hasLength(20), reason: 'una imagen por fotograma');
      expect(splits, hasLength(1), reason: 'y todas en la misma parte');
    });

    test('un fichero con dos clases sigue yendo entero a un sitio', () {
      final plan = _plan([
        _region(mediaId: 1, classIndex: 0),
        _region(mediaId: 1, classIndex: 1),
        for (var i = 0; i < 5; i++) _region(mediaId: 2 + i, classIndex: 0),
        for (var i = 0; i < 5; i++) _region(mediaId: 10 + i, classIndex: 1),
      ]);

      final ofMediaOne =
          [for (final image in plan.images) if (image.mediaId == 1) image];

      expect(ofMediaOne, hasLength(1));
      expect(ofMediaOne.single.labels, hasLength(2), reason: 'las dos clases');
    });
  });

  group('las etiquetas', () {
    test('la esquina se convierte en centro', () {
      // El error clasico: dar por buena la esquina y escribir 0.0 0.0.
      final plan = _plan([
        _region(mediaId: 1, x: 0, y: 0, w: 0.1, h: 0.1),
      ]);

      final label = plan.images.single.labels.single;

      expect(label.centerX, closeTo(0.05, 0.0001));
      expect(label.centerY, closeTo(0.05, 0.0001));
      expect(label.width, closeTo(0.1, 0.0001));
      expect(label.height, closeTo(0.1, 0.0001));
    });

    test('la linea lleva clase, centro y tamano', () {
      final plan = _plan([
        _region(mediaId: 1, classIndex: 3, x: 0.1, y: 0.2, w: 0.4, h: 0.2),
      ]);

      expect(
        plan.images.single.labels.single.toLine(),
        '3 0.300000 0.300000 0.400000 0.200000',
      );
    });

    test('un fichero con varias regiones lleva una linea por cada una', () {
      final plan = _plan([
        _region(mediaId: 1, classIndex: 0),
        _region(mediaId: 1, classIndex: 1),
        _region(mediaId: 1, classIndex: 0),
      ]);

      expect(plan.images.single.labelFile.split('\n'), hasLength(3));
    });

    test('una region sin tamano no entra', () {
      // Rompe la etiqueta y no ensena nada.
      final plan = _plan([
        _region(mediaId: 1, w: 0, h: 0.3),
        _region(mediaId: 1, w: 0.3, h: 0.3),
      ]);

      expect(plan.images.single.labels, hasLength(1));
    });
  });

  group('los porcentajes', () {
    test('con diez contenidos sale 7/2/1', () {
      final plan = _plan([for (var id = 1; id <= 10; id++) _region(mediaId: id)]);

      expect(plan.countIn(DatasetSplitKind.train), 7);
      expect(plan.countIn(DatasetSplitKind.validation), 2);
      expect(plan.countIn(DatasetSplitKind.test), 1);
    });

    test('con pocos contenidos la validacion no se queda vacia', () {
      // Truncando a secas, 3 x 20% = 0.6 se iria a cero y el entrenamiento se
      // quedaria sin con que comprobarse.
      final plan = _plan([for (var id = 1; id <= 3; id++) _region(mediaId: id)]);

      expect(plan.countIn(DatasetSplitKind.validation), greaterThan(0));
      expect(plan.images, hasLength(3), reason: 'y no se pierde ninguno');
    });

    test('cada clase reparte lo suyo con sus porcentajes', () {
      final plan = _plan(
        [
          for (var id = 1; id <= 10; id++) _region(mediaId: id, classIndex: 0),
          for (var id = 11; id <= 20; id++) _region(mediaId: id, classIndex: 1),
        ],
        splits: {
          0: const DatasetSplit(train: 100, validation: 0, test: 0),
          1: const DatasetSplit(train: 0, validation: 100, test: 0),
        },
      );

      final byMedia = _splitByMedia(plan);

      for (var id = 1; id <= 10; id++) {
        expect(byMedia[id], DatasetSplitKind.train, reason: 'contenido $id');
      }
      for (var id = 11; id <= 20; id++) {
        expect(byMedia[id], DatasetSplitKind.validation, reason: 'contenido $id');
      }
    });

    test('se miden en regiones del fernie, no en ficheros suyos', () {
      // Seis ficheros de tamanos muy dispares, cien regiones en total. Contando
      // ficheros, 70/20/10 de seis serian 4/1/1 y las regiones caerian donde
      // fuera: el fichero de cincuenta se llevaria la mitad del dataset a donde
      // le tocara por sorteo.
      final sizes = {1: 50, 2: 20, 3: 10, 4: 10, 5: 5, 6: 5};

      final plan = _plan([
        for (final entry in sizes.entries)
          for (var i = 0; i < entry.value; i++) _region(mediaId: entry.key),
      ]);

      final regions = _regionsBySplit(plan, 0);

      expect(regions[DatasetSplitKind.train], 70);
      expect(regions[DatasetSplitKind.validation], 20);
      expect(regions[DatasetSplitKind.test], 10);
    });

    test('con ficheros del mismo tamano sale clavado', () {
      final plan = _plan([
        for (var id = 1; id <= 20; id++)
          for (var i = 0; i < 5; i++) _region(mediaId: id),
      ]);

      final regions = _regionsBySplit(plan, 0);

      expect(regions[DatasetSplitKind.train], 70);
      expect(regions[DatasetSplitKind.validation], 20);
      expect(regions[DatasetSplitKind.test], 10);
    });

    test('cada fernie lleva sus porcentajes sobre sus propias regiones', () {
      // Anadir un fernie a un modelo aplica sus porcentajes sobre lo suyo y ya
      // esta: no cambia como se reparte lo del otro.
      final plan = _plan(
        [
          for (var id = 1; id <= 10; id++)
            for (var i = 0; i < 10; i++) _region(mediaId: id, classIndex: 0),
          for (var id = 11; id <= 20; id++)
            for (var i = 0; i < 10; i++) _region(mediaId: id, classIndex: 1),
        ],
        splits: {
          0: const DatasetSplit(train: 70, validation: 20, test: 10),
          1: const DatasetSplit(train: 50, validation: 50, test: 0),
        },
      );

      expect(_regionsBySplit(plan, 0)[DatasetSplitKind.train], 70);
      expect(_regionsBySplit(plan, 1)[DatasetSplitKind.train], 50);
      expect(_regionsBySplit(plan, 1)[DatasetSplitKind.validation], 50);
      expect(_regionsBySplit(plan, 1)[DatasetSplitKind.test], 0);
    });

    test('un fichero compartido cae en un sitio y los dos lo cuentan alli', () {
      final plan = _plan([
        // El fichero 1 lleva regiones de los dos fernies.
        for (var i = 0; i < 5; i++) _region(mediaId: 1, classIndex: 0),
        for (var i = 0; i < 5; i++) _region(mediaId: 1, classIndex: 1),
        for (var id = 2; id <= 10; id++) _region(mediaId: id, classIndex: 0),
        for (var id = 11; id <= 20; id++) _region(mediaId: id, classIndex: 1),
      ]);

      final shared =
          [for (final image in plan.images) if (image.mediaId == 1) image];

      expect(shared, hasLength(1), reason: 'una sola imagen');

      // Y los dos fernies siguen teniendo con que validar: el segundo se corrige
      // con lo que le queda por repartir.
      for (final classIndex in [0, 1]) {
        expect(
          _regionsBySplit(plan, classIndex)[DatasetSplitKind.validation],
          greaterThan(0),
          reason: 'clase $classIndex',
        );
      }
    });

    test('un fichero gordo no se parte aunque descuadre', () {
      // Un video con doscientos fotogramas marcados y dos fotos sueltas: no hay
      // forma de que salga 70/20/10 sin partir el video, y partirlo es
      // justamente lo que no se puede hacer.
      final plan = _plan([
        for (var frame = 0; frame < 200; frame++)
          _region(mediaId: 1, frameMs: frame * 33),
        _region(mediaId: 2),
        _region(mediaId: 3),
      ]);

      final ofVideo =
          {for (final image in plan.images) if (image.mediaId == 1) image.split};

      expect(ofVideo, hasLength(1));
    });
  });

  group('el mismo reparto siempre', () {
    test('dos planes de los mismos datos coinciden', () {
      List<DatasetRegion> data() {
        _nextId = 0;
        return [for (var id = 1; id <= 30; id++) _region(mediaId: id)];
      }

      final first = _splitByMedia(_plan(data(), seed: 7));
      final again = _splitByMedia(_plan(data(), seed: 7));

      // Reentrenar sin haber cambiado nada tiene que dar las mismas metricas, o
      // no hay forma de saber si un cambio ha mejorado algo.
      expect(again, first);
    });

    test('no se reparte por orden de llegada', () {
      // Sin barajar, el reparto seria «lo primero que se importo para entrenar y
      // lo ultimo para probar», y lo ultimo que se importa suele parecerse entre
      // si.
      final plan = _plan([for (var id = 1; id <= 30; id++) _region(mediaId: id)]);

      final test = [
        for (final image in plan.images)
          if (image.split == DatasetSplitKind.test) image.mediaId,
      ];

      expect(test, isNot([28, 29, 30]));
    });
  });

  group('los recuentos que miran las comprobaciones', () {
    test('cuentan regiones y contenidos por clase', () {
      final plan = _plan([
        for (var i = 0; i < 12; i++) _region(mediaId: 1, classIndex: 0),
        for (var id = 2; id <= 4; id++) _region(mediaId: id, classIndex: 1),
      ]);

      expect(plan.regionsByClass[0], 12);
      expect(plan.regionsByClass[1], 3);

      // Doce regiones de un solo fichero ensenan el fondo, no el objeto, y de
      // eso avisa la pantalla del modelo.
      expect(plan.mediaByClass[0], 1);
      expect(plan.mediaByClass[1], 3);
    });
  });

  group('lo que se va a escribir', () {
    test('los nombres de fichero no se repiten dentro de una parte', () {
      final plan = _plan([for (var id = 1; id <= 20; id++) _region(mediaId: id)]);

      for (final kind in DatasetSplitKind.values) {
        final stems = [for (final image in plan.of(kind)) image.stem];
        expect(stems.toSet(), hasLength(stems.length), reason: '$kind');
      }
    });

    test('lo que sale de un video se marca para sacarle el fotograma', () {
      final plan = _plan([
        _region(mediaId: 1),
        _region(mediaId: 2, frameMs: 1200),
      ]);

      final still =
          plan.images.firstWhere((image) => image.mediaId == 1);
      final moving =
          plan.images.firstWhere((image) => image.mediaId == 2);

      expect(still.needsFrameExtraction, isFalse);
      expect(moving.needsFrameExtraction, isTrue);
      expect(moving.frameMs, 1200);
    });
  });
}
