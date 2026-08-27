// Los creadores de una fuente remota, para elegir de quien traerse contenido.
//
// Lo que hace util la lista no es la lista: son los dos datos que lleva cada
// tarjeta. **Cuantas publicaciones nuevas** convierte cincuenta nombres en tres
// que interesan, y **si ya lo tienes** distingue a quien se sigue desde hace
// meses de un hallazgo. Sin ninguno de los dos, la pantalla es un directorio.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/remote_creator.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/domain/repositories/remote_media_repository.dart';
import 'package:Fern/features/media/domain/usecases/get_remote_creators_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

/// Una fuente de mentira con los creadores que se le digan.
class _Remote implements RemoteMediaRepository {
  final List<RemoteCreator> creators;
  final Map<String, int?> counts;

  /// A quien se le ha preguntado, para comprobar que no se pregunta de golpe.
  final asked = <String>[];

  _Remote({this.creators = const [], this.counts = const {}});

  @override
  Future<DataState<List<RemoteCreator>>> remoteCreators(ImportSource source) async =>
      DataSuccess(creators);

  @override
  Future<int?> countNewPosts(ImportSource source, RemoteCreator creator) async {
    asked.add(creator.id);
    return counts[creator.id];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

/// Una biblioteca de mentira con los creadores que ya se tienen.
class _Library implements LocalMediaRepository {
  final List<String> names;

  const _Library(this.names);

  @override
  Future<DataState<List<CreatorEntity>>> getCreators() async {
    return DataSuccess([
      for (final (index, name) in names.indexed)
        CreatorEntity(id: index + 1, name: name),
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('${invocation.memberName}');
}

RemoteCreator _creator(String id, String name) =>
    RemoteCreator(id: id, name: name, service: 'algo');

void main() {
  group('cruzar con la biblioteca', () {
    test('el que ya se tiene sale marcado', () async {
      final usecase = GetRemoteCreatorsUseCase(
        remote: _Remote(creators: [
          _creator('a-1', 'Marinette'),
          _creator('a-2', 'Adrien'),
        ]),
        creators: const _Library(['Adrien']),
      );

      final found = await usecase(params: ImportSource.pawchive);
      final creators = found.data!;

      expect(creators.first.isKnown, isFalse);
      expect(creators.last.isKnown, isTrue);
      expect(creators.last.knownCreatorId, 1);
    });

    test('el nombre se cruza sin distinguir mayusculas ni espacios', () async {
      final usecase = GetRemoteCreatorsUseCase(
        remote: _Remote(creators: [_creator('a-1', '  MARINETTE ')]),
        creators: const _Library(['marinette']),
      );

      final found = await usecase(params: ImportSource.pawchive);

      expect(found.data!.single.isKnown, isTrue);
    });

    test('sin nada en la biblioteca no se marca nadie', () async {
      final usecase = GetRemoteCreatorsUseCase(
        remote: _Remote(creators: [_creator('a-1', 'Marinette')]),
        creators: const _Library([]),
      );

      final found = await usecase(params: ImportSource.pawchive);

      expect(found.data!.single.isKnown, isFalse);
    });
  });

  group('contar lo nuevo', () {
    test('va soltando cada uno segun se sabe', () async {
      final remote = _Remote(
        creators: [_creator('a-1', 'Una'), _creator('a-2', 'Otra')],
        counts: const {'a-1': 3, 'a-2': 0},
      );

      final counted = await CountRemoteCreatorPostsUseCase(remote: remote)(
        ImportSource.pawchive,
        remote.creators,
      ).toList();

      expect(counted.map((one) => one.newPosts), [3, 0]);
      expect(remote.asked, ['a-1', 'a-2']);
    });

    test('el que no se puede contar no se suelta', () async {
      // Un hueco y no un cero: un cero significa «no ha publicado nada», que es
      // lo contrario de «no lo se».
      final remote = _Remote(
        creators: [_creator('a-1', 'Una'), _creator('a-2', 'Otra')],
        counts: const {'a-1': null, 'a-2': 5},
      );

      final counted = await CountRemoteCreatorPostsUseCase(remote: remote)(
        ImportSource.pawchive,
        remote.creators,
      ).toList();

      expect(counted.map((one) => one.id), ['a-2']);
    });

    test('cero es cero, y se cuenta', () async {
      final remote = _Remote(
        creators: [_creator('a-1', 'Una')],
        counts: const {'a-1': 0},
      );

      final counted = await CountRemoteCreatorPostsUseCase(remote: remote)(
        ImportSource.pawchive,
        remote.creators,
      ).toList();

      expect(counted.single.newPosts, 0);
      expect(counted.single.hasNews, isFalse);
    });

    test('con muchos no se preguntan todos de golpe', () async {
      final creators = [
        for (var index = 0; index < 20; index++) _creator('a-$index', 'N$index'),
      ];
      final remote = _Remote(
        creators: creators,
        counts: {for (final one in creators) one.id: 1},
      );

      final counted = await CountRemoteCreatorPostsUseCase(remote: remote)(
        ImportSource.pawchive,
        creators,
      ).toList();

      // Contar es una peticion por creador: con cincuenta de golpe el sitio
      // corta. Lo que importa es que no se pierda ninguno por el camino.
      expect(counted, hasLength(20));
      expect(remote.asked, hasLength(20));
    });

    test('sin creadores no se pregunta nada', () async {
      final remote = _Remote();

      final counted = await CountRemoteCreatorPostsUseCase(remote: remote)(
        ImportSource.pawchive,
        const [],
      ).toList();

      expect(counted, isEmpty);
      expect(remote.asked, isEmpty);
    });
  });

  group('si tiene novedades', () {
    test('la cuenta manda cuando esta', () {
      // Es el dato bueno: dice cuantas, no solo que las hay.
      expect(
        const RemoteCreator(id: 'a', name: 'A', newPosts: 3).hasNews,
        isTrue,
      );
      expect(
        const RemoteCreator(id: 'a', name: 'A', newPosts: 0).hasNews,
        isFalse,
      );
    });

    test('un cero de verdad gana a dos fechas que dirian que si', () {
      // Contarlas es mas fiable que cruzar fechas: si la cuenta dice que no hay
      // ninguna, no hay ninguna.
      final creator = RemoteCreator(
        id: 'a',
        name: 'A',
        newPosts: 0,
        lastImport: DateTime(2026, 8, 12),
        updatedAt: DateTime.utc(2026, 8, 20),
      );

      expect(creator.hasNews, isFalse);
    });

    test('sin la cuenta se cruzan las dos fechas', () {
      // Lo que se sabe sin pedir nada: cuando publico el, y cuando se miro aqui.
      expect(
        RemoteCreator(
          id: 'a',
          name: 'A',
          lastImport: DateTime(2026, 8, 12),
          updatedAt: DateTime.utc(2026, 8, 20),
        ).hasNews,
        isTrue,
      );
      expect(
        RemoteCreator(
          id: 'a',
          name: 'A',
          lastImport: DateTime(2026, 8, 20),
          updatedAt: DateTime.utc(2026, 8, 12),
        ).hasNews,
        isFalse,
      );
    });

    test('sin haber importado nunca no es que no tenga', () {
      // Es que esta sin estrenar, que la tarjeta dice aparte y resaltado.
      expect(
        RemoteCreator(
          id: 'a',
          name: 'A',
          updatedAt: DateTime.utc(2026, 8, 20),
        ).hasNews,
        isFalse,
      );
    });

    test('y sin saber nada de el, tampoco', () {
      expect(const RemoteCreator(id: 'a', name: 'A').hasNews, isFalse);
    });
  });
}
