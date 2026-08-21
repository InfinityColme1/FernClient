// El arbol de modelos, guardado.
//
// Se prueba contra una base de datos de verdad porque lo que importa aqui es lo
// que pasa **entre** filas: que sacar un nodo se lleve sus aristas y deje a sus
// hijos como raices, que un modelo no pueda estar dos veces, y que una arista
// que cerraria un ciclo no llegue a escribirse.
//
// Lo del ciclo es lo unico que no se puede arreglar despues: no da un error, da
// un recorrido que no termina, y desde fuera parece que la aplicacion se ha
// colgado.

import 'dart:ffi' show Abi;
import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/persona/persona_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_model.dart';
import 'package:Fern/features/recognition/data/models/fernie_region_model.dart';
import 'package:Fern/features/recognition/data/models/model_fernie_model.dart';
import 'package:Fern/features/recognition/data/models/model_tree_edge_model.dart';
import 'package:Fern/features/recognition/data/models/model_tree_node_model.dart';
import 'package:Fern/features/recognition/data/models/recognition_model_model.dart';
import 'package:Fern/features/recognition/data/repositories/model_repository_impl.dart';
import 'package:Fern/features/recognition/data/repositories/model_tree_repository_impl.dart';
import 'package:Fern/features/recognition/domain/entities/model_tree_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late ModelRepositoryImpl models;
  late ModelTreeRepositoryImpl tree;

  final isarLibrary = _isarLibrary();

  setUpAll(() async {
    if (isarLibrary == null) {
      throw StateError(
        'No se encuentra isar.dll. Se coge de la compilación de la aplicación '
        '(flutter build windows --debug) o del paquete isar_flutter_libs.',
      );
    }

    await Isar.initializeIsarCore(libraries: {Abi.windowsX64: isarLibrary});
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fern_tree_test');

    isar = await Isar.open(
      [
        TagModelSchema,
        PersonaModelSchema,
        CreatorModelSchema,
        MediaSummaryModelSchema,
        MediaModelSchema,
        FernieModelSchema,
        FernieRegionModelSchema,
        RecognitionModelModelSchema,
        ModelFernieModelSchema,
        ModelTreeNodeModelSchema,
        ModelTreeEdgeModelSchema,
      ],
      directory: directory.path,
      inspector: false,
    );

    models = ModelRepositoryImpl(database: isar);
    tree = ModelTreeRepositoryImpl(database: isar, models: models);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  Future<int> addModel(String name) async {
    final result = await models.saveModel(
      RecognitionModelEntity(
        id: unsavedId,
        name: name,
        createdAt: DateTime.now(),
      ),
    );

    expect(result, isA<DataSuccess>());
    return result.data!.id;
  }

  /// Mete un modelo nuevo en el arbol y devuelve su nodo.
  Future<int> addNode(String name) async {
    final result = await tree.addModel(modelId: await addModel(name));

    expect(result, isA<DataSuccess>());
    return result.data!.id;
  }

  Future<ModelTreeEntity> read() async {
    final result = await tree.getTree();
    expect(result, isA<DataSuccess>());

    return result.data!;
  }

  group('meter modelos', () {
    test('un modelo entra en el arbol', () async {
      final node = await addNode('General');
      final current = await read();

      expect(current.nodes, hasLength(1));
      expect(current.nodes.single.id, node);
      expect(current.nodes.single.model.name, 'General');
    });

    test('el mismo modelo no entra dos veces', () async {
      final modelId = await addModel('General');

      final first = await tree.addModel(modelId: modelId);
      final second = await tree.addModel(modelId: modelId);

      // Repetirlo no aporta nada y complicaria la ejecucion.
      expect(second.data!.id, first.data!.id);
      expect((await read()).nodes, hasLength(1));
    });

    test('un modelo que no existe no entra', () async {
      final result = await tree.addModel(modelId: 999);

      expect(result, isA<DataException>());
      expect((await read()).nodes, isEmpty);
    });

    test('un nodo recien metido es raiz', () async {
      await addNode('General');

      // No cuelga de nadie, asi que se ejecuta siempre.
      expect((await read()).roots, hasLength(1));
    });
  });

  group('colgar unos de otros', () {
    test('se guarda con su condicion', () async {
      final parent = await addNode('General');
      final child = await addNode('Especializado');

      final result = await tree.connect(
        parentNodeId: parent,
        childNodeId: child,
        conditionFernieId: 7,
      );

      expect(result, isA<DataSuccess>());

      final current = await read();
      expect(current.edges.single.conditionFernieId, 7);
      expect(current.roots.map((node) => node.id), [parent]);
    });

    test('sin condicion se guarda como «cualquier cosa»', () async {
      final parent = await addNode('General');
      final child = await addNode('Especializado');

      await tree.connect(parentNodeId: parent, childNodeId: child);

      expect((await read()).edges.single.conditionFernieId, isNull);
    });

    test('un ciclo no llega a escribirse', () async {
      final one = await addNode('Uno');
      final two = await addNode('Dos');
      final three = await addNode('Tres');

      await tree.connect(parentNodeId: one, childNodeId: two);
      await tree.connect(parentNodeId: two, childNodeId: three);

      final result = await tree.connect(parentNodeId: three, childNodeId: one);

      // Un ciclo no da un error: da un recorrido que no termina.
      expect(result, isA<DataException>());
      expect((await read()).edges, hasLength(2));
    });

    test('colgarse de si mismo tampoco', () async {
      final node = await addNode('Uno');

      expect(
        await tree.connect(parentNodeId: node, childNodeId: node),
        isA<DataException>(),
      );
    });

    test('la misma arista dos veces tampoco', () async {
      final parent = await addNode('General');
      final child = await addNode('Especializado');

      await tree.connect(parentNodeId: parent, childNodeId: child);
      final again = await tree.connect(
        parentNodeId: parent,
        childNodeId: child,
      );

      expect(again, isA<DataException>());
      expect((await read()).edges, hasLength(1));
    });

    test('dos padres para el mismo hijo si', () async {
      final one = await addNode('Uno');
      final two = await addNode('Dos');
      final child = await addNode('Hijo');

      await tree.connect(parentNodeId: one, childNodeId: child);
      final second = await tree.connect(parentNodeId: two, childNodeId: child);

      // Es un grafo, no un arbol estricto: se ejecutara una sola vez.
      expect(second, isA<DataSuccess>());
      expect((await read()).edges, hasLength(2));
    });

    test('cambiar la condicion de una arista', () async {
      final parent = await addNode('General');
      final child = await addNode('Especializado');

      final edge = (await tree.connect(
        parentNodeId: parent,
        childNodeId: child,
      ))
          .data!;

      await tree.setEdgeCondition(edgeId: edge.id, conditionFernieId: 3);
      expect((await read()).edges.single.conditionFernieId, 3);

      await tree.setEdgeCondition(edgeId: edge.id, conditionFernieId: null);
      expect((await read()).edges.single.conditionFernieId, isNull);
    });
  });

  group('cambiar de padre', () {
    test('deja de colgar del viejo y cuelga del nuevo', () async {
      final one = await addNode('Uno');
      final two = await addNode('Dos');
      final child = await addNode('Hijo');

      await tree.connect(parentNodeId: one, childNodeId: child);
      final moved = await tree.reparent(parentNodeId: two, childNodeId: child);

      expect(moved, isA<DataSuccess>());

      final current = await read();

      // Lo que se espera al arrastrar una tarjeta sobre otra es «ahora cuelga de
      // esta», no «ahora cuelga de las dos».
      expect(current.edges, hasLength(1));
      expect(current.edges.single.parentNodeId, two);
      expect(current.roots.map((node) => node.id).toList()..sort(), [one, two]);
    });

    test('un ciclo lo deja como estaba, no suelto', () async {
      final one = await addNode('Uno');
      final two = await addNode('Dos');
      final three = await addNode('Tres');

      await tree.connect(parentNodeId: one, childNodeId: two);
      await tree.connect(parentNodeId: two, childNodeId: three);

      final moved = await tree.reparent(parentNodeId: three, childNodeId: one);

      expect(moved, isA<DataException>());

      // Hecho en dos pasos, un fallo a mitad lo dejaria suelto, y un nodo suelto
      // se ejecuta siempre: justo lo contrario de lo que se pedia.
      final current = await read();
      expect(current.edges, hasLength(2));
      expect(current.roots.map((node) => node.id), [one]);
    });

    test('un nodo suelto se puede colgar de otro', () async {
      final parent = await addNode('Padre');
      final child = await addNode('Hijo');

      await tree.reparent(parentNodeId: parent, childNodeId: child);

      expect((await read()).roots.map((node) => node.id), [parent]);
    });

    test('se pierde la condicion que tuviera, que era del padre viejo',
        () async {
      final one = await addNode('Uno');
      final two = await addNode('Dos');
      final child = await addNode('Hijo');

      await tree.connect(
        parentNodeId: one,
        childNodeId: child,
        conditionFernieId: 7,
      );

      await tree.reparent(parentNodeId: two, childNodeId: child);

      // La clase 7 era una clase del padre viejo: arrastrada al nuevo no
      // significa nada.
      expect((await read()).edges.single.conditionFernieId, isNull);
    });
  });

  group('soltar de sus padres', () {
    test('pasa a ser raiz sin salir del arbol', () async {
      final parent = await addNode('Padre');
      final child = await addNode('Hijo');
      await tree.connect(parentNodeId: parent, childNodeId: child);

      await tree.promoteToRoot(child);

      final current = await read();
      expect(current.nodes, hasLength(2));
      expect(current.edges, isEmpty);
      expect(current.roots, hasLength(2));
    });

    test('no toca a sus hijos', () async {
      final grandparent = await addNode('Abuelo');
      final parent = await addNode('Padre');
      final child = await addNode('Hijo');

      await tree.connect(parentNodeId: grandparent, childNodeId: parent);
      await tree.connect(parentNodeId: parent, childNodeId: child);

      await tree.promoteToRoot(parent);

      final current = await read();
      expect(current.edges, hasLength(1));
      expect(current.edges.single.parentNodeId, parent);
    });

    test('uno que ya era raiz se queda igual', () async {
      final node = await addNode('Uno');

      expect(await tree.promoteToRoot(node), isA<DataSuccess>());
      expect((await read()).roots, hasLength(1));
    });
  });

  group('sacar del arbol', () {
    test('se lleva sus aristas', () async {
      final parent = await addNode('General');
      final child = await addNode('Especializado');
      await tree.connect(parentNodeId: parent, childNodeId: child);

      await tree.removeNode(parent);

      final current = await read();
      expect(current.nodes.map((node) => node.id), [child]);
      expect(current.edges, isEmpty);
    });

    test('los hijos que se quedan sin padre pasan a ser raices', () async {
      final parent = await addNode('General');
      final child = await addNode('Especializado');
      await tree.connect(parentNodeId: parent, childNodeId: child);

      await tree.removeNode(parent);

      // Lo que no cuelga de nadie se ejecuta siempre: es lo que le pasa a
      // cualquier raiz, y salir del arbol de otro no puede dejarlo mudo.
      expect((await read()).roots.map((node) => node.id), [child]);
    });

    test('el hijo con otro padre sigue colgando de el', () async {
      final one = await addNode('Uno');
      final two = await addNode('Dos');
      final child = await addNode('Hijo');

      await tree.connect(parentNodeId: one, childNodeId: child);
      await tree.connect(parentNodeId: two, childNodeId: child);

      await tree.removeNode(one);

      expect((await read()).roots.map((node) => node.id), [two]);
    });

    test('el modelo sigue existiendo', () async {
      final modelId = await addModel('General');
      final node = (await tree.addModel(modelId: modelId)).data!;

      await tree.removeNode(node.id);

      // Sale del arbol, que es dejar de ejecutarse. No es borrarlo.
      expect((await models.getModel(modelId)).data?.name, 'General');
      expect((await read()).nodes, isEmpty);
    });

    test('y puede volver a entrar', () async {
      final modelId = await addModel('General');
      final node = (await tree.addModel(modelId: modelId)).data!;

      await tree.removeNode(node.id);
      final again = await tree.addModel(modelId: modelId);

      // El indice unico por modelo no puede dejar el sitio ocupado por un nodo
      // que ya no esta.
      expect(again, isA<DataSuccess>());
      expect((await read()).nodes, hasLength(1));
    });
  });

  group('un modelo borrado por fuera', () {
    test('deja de verse en el arbol', () async {
      final modelId = await addModel('General');
      await tree.addModel(modelId: modelId);

      // Borrar un modelo no sabe del arbol: la fila del nodo se queda, y un nodo
      // sin modelo no es nada que pintar ni que ejecutar.
      await models.deleteModel(modelId);

      expect((await read()).nodes, isEmpty);
    });

    test('y sus aristas tampoco', () async {
      final parentModel = await addModel('General');
      final parent = (await tree.addModel(modelId: parentModel)).data!;
      final child = await addNode('Especializado');

      await tree.connect(parentNodeId: parent.id, childNodeId: child);
      await models.deleteModel(parentModel);

      final current = await read();
      expect(current.edges, isEmpty);
      expect(current.roots.map((node) => node.id), [child]);
    });
  });

  group('mover', () {
    test('cambia donde se pinta y nada mas', () async {
      final parent = await addNode('General');
      final child = await addNode('Especializado');
      await tree.connect(parentNodeId: parent, childNodeId: child);

      await tree.moveNode(nodeId: child, row: 3, column: 2);

      final current = await read();
      final moved = current.nodeById(child)!;

      expect(moved.row, 3);
      expect(moved.column, 2);
      expect(current.edges, hasLength(1));
    });
  });
}

String? _isarLibrary() {
  final pubCache = Platform.environment['PUB_CACHE'] ??
      '${Platform.environment['LOCALAPPDATA']}\\Pub\\Cache';

  final candidates = [
    r'build\windows\x64\runner\Debug\isar.dll',
    r'build\windows\x64\runner\Release\isar.dll',
    '$pubCache\\hosted\\pub.dev\\isar_flutter_libs-3.1.0+1\\windows\\isar.dll',
  ];

  for (final candidate in candidates) {
    if (File(candidate).existsSync()) return candidate;
  }

  return null;
}
