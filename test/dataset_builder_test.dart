// Que deja escrito en disco el constructor del dataset.
//
// El reparto —lo dificil— se comprueba aparte, en dataset_plan_test.dart, que es
// una funcion pura. Aqui lo que se mira es lo otro: que las carpetas son las que
// YOLO espera, que cada imagen tiene su .txt al lado, y que el data.yaml apunta
// a donde tiene que apuntar.
//
// El sacador de fotogramas se dobla: abrir un reproductor por cada uno haria de
// esto una prueba de media hora, y lo que se comprueba no es mpv.

import 'dart:io';

import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/features/recognition/data/services/dataset_builder.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/services/dataset_plan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory directory;
  late Directory library;
  late String root;

  /// Los fotogramas que se han pedido, para poder comprobar que se piden.
  late List<String> extracted;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fern_dataset_test');
    library = await Directory(p.join(directory.path, 'biblioteca')).create();
    root = p.join(directory.path, 'datasets', '7-personajes');
    extracted = [];
  });

  tearDown(() {
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  /// Un fichero de contenido con algo dentro, para poder copiarlo.
  String addMedia(String name) {
    final file = File(p.join(library.path, name))
      ..writeAsStringSync('pixeles de $name');

    return file.path;
  }

  /// El de mentira: escribe un fichero y devuelve dónde, como haría el de
  /// verdad con el fotograma sacado del vídeo.
  DatasetBuilder builderWithFakeFrames() {
    return DatasetBuilder(extractFrame: (path, at) async {
      extracted.add('$path@${at.inMilliseconds}');

      final frame = File(
        p.join(directory.path, 'frame-${extracted.length}.jpg'),
      )..writeAsStringSync('fotograma de $path en $at');

      return frame.path;
    });
  }

  DatasetRegion region({
    required int mediaId,
    required String path,
    int classIndex = 0,
    int? frameMs,
  }) {
    return DatasetRegion(
      regionId: mediaId * 100 + (frameMs ?? 0),
      mediaId: mediaId,
      mediaPath: path,
      frameMs: frameMs,
      x: 0.1,
      y: 0.1,
      w: 0.2,
      h: 0.2,
      classIndex: classIndex,
    );
  }

  DatasetPlan planOf(List<DatasetRegion> regions) {
    final classes = {for (final r in regions) r.classIndex};

    return planDataset(
      regions: regions,
      splitByClass: {for (final index in classes) index: DatasetSplit.balanced},
      namesByClass: {
        for (final index in classes) index: index == 0 ? 'marinette' : 'adrien',
      },
    );
  }

  test('monta las carpetas que YOLO espera', () async {
    final plan = planOf([
      for (var id = 1; id <= 10; id++)
        region(mediaId: id, path: addMedia('$id.jpg')),
    ]);

    await builderWithFakeFrames().build(plan: plan, root: root);

    for (final folder in ['train', 'val', 'test']) {
      expect(Directory(p.join(root, 'images', folder)).existsSync(), isTrue);
      expect(Directory(p.join(root, 'labels', folder)).existsSync(), isTrue);
    }

    expect(File(p.join(root, 'data.yaml')).existsSync(), isTrue);
  });

  test('cada imagen tiene su etiqueta al lado y con el mismo nombre', () async {
    final plan = planOf([
      for (var id = 1; id <= 10; id++)
        region(mediaId: id, path: addMedia('$id.jpg')),
    ]);

    await builderWithFakeFrames().build(plan: plan, root: root);

    for (final image in plan.images) {
      final folder = image.split.folder;

      expect(
        File(p.join(root, 'images', folder, '${image.stem}.jpg')).existsSync(),
        isTrue,
        reason: 'falta la imagen ${image.stem} en $folder',
      );
      expect(
        File(p.join(root, 'labels', folder, '${image.stem}.txt')).existsSync(),
        isTrue,
        reason: 'falta la etiqueta ${image.stem} en $folder',
      );
    }
  });

  test('la etiqueta lleva una linea por region', () async {
    final path = addMedia('1.jpg');
    final plan = planOf([
      region(mediaId: 1, path: path, classIndex: 0),
      region(mediaId: 1, path: path, classIndex: 1),
    ]);

    await builderWithFakeFrames().build(plan: plan, root: root);

    final image = plan.images.single;
    final label = File(
      p.join(root, 'labels', image.split.folder, '${image.stem}.txt'),
    ).readAsStringSync();

    expect(label.split('\n'), hasLength(2));
    expect(label, contains('0 0.200000 0.200000 0.200000 0.200000'));
    expect(label, contains('1 0.200000 0.200000 0.200000 0.200000'));
  });

  test('de un video se saca el fotograma, no se copia el fichero', () async {
    final video = addMedia('clip.mp4');
    final plan = planOf([
      region(mediaId: 1, path: video, frameMs: 1200),
      region(mediaId: 2, path: addMedia('foto.jpg')),
    ]);

    await builderWithFakeFrames().build(plan: plan, root: root);

    // Copiar el .mp4 a images/ dejaria a YOLO sin nada que leer.
    expect(extracted, ['$video@1200']);

    final fromVideo = plan.images.firstWhere((image) => image.mediaId == 1);
    expect(
      File(p.join(root, 'images', fromVideo.split.folder,
              '${fromVideo.stem}.jpg'))
          .readAsStringSync(),
      contains('fotograma'),
    );
  });

  test('el data.yaml apunta a la carpeta y nombra las clases', () async {
    final plan = planOf([
      for (var id = 1; id <= 6; id++)
        region(
          mediaId: id,
          path: addMedia('$id.jpg'),
          classIndex: id.isEven ? 1 : 0,
        ),
    ]);

    await builderWithFakeFrames().build(plan: plan, root: root);

    final yaml = File(p.join(root, 'data.yaml')).readAsStringSync();

    expect(yaml, contains('train: images/train'));
    expect(yaml, contains('val: images/val'));
    expect(yaml, contains('  0: marinette'));
    expect(yaml, contains('  1: adrien'));

    // Lo lee Python: una barra invertida dentro de una cadena es un escape.
    expect(yaml, isNot(contains(r'\')));
  });

  test('un fichero que ya no esta se anota y no rompe nada', () async {
    final gone = p.join(library.path, 'borrado.jpg');
    final plan = planOf([
      region(mediaId: 1, path: gone),
      region(mediaId: 2, path: addMedia('2.jpg')),
    ]);

    final result = await builderWithFakeFrames().build(plan: plan, root: root);

    // El contenido se pudo mover fuera de la aplicacion: no es un fallo, pero
    // hay que decirlo, porque esas regiones no han entrenado nada.
    expect(result.missing, [gone]);

    final left = plan.images.firstWhere((image) => image.mediaId == 2);
    expect(
      File(p.join(root, 'images', left.split.folder, '${left.stem}.jpg'))
          .existsSync(),
      isTrue,
    );
  });

  test('sin la imagen no se escribe su etiqueta', () async {
    final gone = p.join(library.path, 'borrado.jpg');
    final plan = planOf([region(mediaId: 1, path: gone)]);

    await builderWithFakeFrames().build(plan: plan, root: root);

    // Una etiqueta suelta sin su imagen hace que ultralytics avise de dataset
    // corrupto.
    final image = plan.images.single;
    expect(
      File(p.join(root, 'labels', image.split.folder, '${image.stem}.txt'))
          .existsSync(),
      isFalse,
    );
  });

  test('montarlo dos veces no mezcla lo de antes', () async {
    final first = planOf([
      for (var id = 1; id <= 6; id++)
        region(mediaId: id, path: addMedia('$id.jpg')),
    ]);

    final builder = builderWithFakeFrames();
    await builder.build(plan: first, root: root);

    final second = planOf([region(mediaId: 99, path: addMedia('99.jpg'))]);
    await builder.build(plan: second, root: root);

    final images = Directory(p.join(root, 'images'))
        .listSync(recursive: true)
        .whereType<File>();

    // Un dataset a medias de un intento anterior mezclaria imagenes que ya no
    // tocan, y el modelo aprenderia de ellas.
    expect(images, hasLength(1));
  });

  test('avisa de por donde va', () async {
    final plan = planOf([
      for (var id = 1; id <= 10; id++)
        region(mediaId: id, path: addMedia('$id.jpg')),
    ]);

    final seen = <int>[];
    await builderWithFakeFrames().build(
      plan: plan,
      root: root,
      onProgress: (done, total) {
        seen.add(done);
        expect(total, 10);
      },
    );

    expect(seen, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
  });

  test('cancelar corta antes de terminar', () async {
    final plan = planOf([
      for (var id = 1; id <= 10; id++)
        region(mediaId: id, path: addMedia('$id.jpg')),
    ]);

    final token = CancellationToken();

    await expectLater(
      builderWithFakeFrames().build(
        plan: plan,
        root: root,
        token: token,
        onProgress: (done, _) {
          if (done == 3) token.cancel();
        },
      ),
      throwsA(isA<JobCancelledException>()),
    );
  });

  test('tirar el dataset lo deja donde estaba: en ningun sitio', () async {
    final plan = planOf([region(mediaId: 1, path: addMedia('1.jpg'))]);

    final builder = builderWithFakeFrames();
    await builder.build(plan: plan, root: root);
    expect(Directory(root).existsSync(), isTrue);

    await builder.discard(root);
    expect(Directory(root).existsSync(), isFalse);
  });
}
