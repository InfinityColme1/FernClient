// Parar una importación en marcha.
//
// Lo que importa de parar son tres cosas, y las tres se comprueban aquí: que
// deje de traerse contenido de verdad (no que se dejen de pintar cosas que se
// siguen descargando), que lo ya traído se quede, y que la fuente se dé por
// importada en este momento, porque no ha fallado nada: ha terminado antes
// porque el usuario lo ha dicho.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/cancellation_token.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/remote_creator.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/domain/repositories/remote_media_repository.dart';
import 'package:Fern/features/media/domain/usecases/scan_source_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Una fuente remota de mentira que va soltando contenido sin parar, y que
/// apunta cuánto ha llegado a producir: es lo que dice si de verdad se ha
/// dejado de traer o sólo se ha dejado de mirar.
class _EndlessRemote implements RemoteMediaRepository {
  int produced = 0;

  @override
  Future<DataState<List<RemoteCreator>>> remoteCreators(ImportSource source) async =>
      const DataSuccess([]);

  @override
  Future<int?> countNewPosts(ImportSource source, RemoteCreator creator) async =>
      null;

  @override
  Stream<DataState<MediaSummaryEntity>> scanRemoteSource(
    ImportSource source, {
    bool untilLastImport = false,
    Set<String> creators = const {},
  }) async* {
    for (var i = 0; i < 100; i++) {
      produced++;
      yield DataSuccess(MediaSummaryEntity(
        id: i,
        path: 'C:/descargas/$i.jpg',
        importSource: source,
      ));
    }
  }
}

/// El equipo no pinta nada en estas pruebas: la fuente que se recorre es
/// remota, así que a esto no se le llega a pedir nada.
class _UnusedLocal implements LocalMediaRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferencesService preferences;
  late CancellationToken token;
  late _EndlessRemote remote;
  late ScanSourceUseCase scan;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    preferences = PreferencesService(await SharedPreferences.getInstance());
    token = CancellationToken();
    remote = _EndlessRemote();
    scan = ScanSourceUseCase(
      localMediaRepository: _UnusedLocal(),
      remoteMediaRepository: remote,
      preferencesService: preferences,
    );
  });

  /// Recorre la fuente y para en cuanto han llegado [after] contenidos.
  Future<List<MediaSummaryEntity>> scanStoppingAfter(int after) async {
    final stream = await scan.call(
      params: (source: ImportSource.pixiv, limit: 0, token: token, creators: const {}),
    );

    final received = <MediaSummaryEntity>[];
    await for (final result in stream) {
      if (result is DataSuccess && result.data != null) {
        received.add(result.data!);
      }
      if (received.length == after) token.cancel();
    }

    return received;
  }

  test('lo que ya había llegado se queda', () async {
    expect(await scanStoppingAfter(3), hasLength(3));
  });

  test('deja de traerse contenido, no sólo de enseñarlo', () async {
    await scanStoppingAfter(3);

    // La fuente puede haber tenido uno preparado de más cuando se paró, pero ni
    // se acerca a los cien que iba a soltar.
    expect(remote.produced, lessThanOrEqualTo(4));
  });

  test('la fuente queda importada a esta hora, que no ha fallado nada',
      () async {
    expect(preferences.getLastImport(ImportSource.pixiv), isNull);

    await scanStoppingAfter(3);

    expect(preferences.getLastImport(ImportSource.pixiv), isNotNull);
  });

  test('parar una importacion no para la que corre al lado', () async {
    // Era el problema de la senal global: la levantaba quien fuera y la miraban
    // todos. Ahora cada trabajo lleva la suya.
    final otra = CancellationToken();

    final stream = await scan.call(
      params: (source: ImportSource.pixiv, limit: 0, token: otra, creators: const {}),
    );

    token.cancel();

    expect(await stream.length, 100);
  });

  test('sin senal de parada tampoco se para nada', () async {
    final stream = await scan.call(
      params: (source: ImportSource.pixiv, limit: 0, token: null, creators: const {}),
    );

    expect(await stream.length, 100);
  });

  test('sin parar nada, se recorre la fuente entera', () async {
    final stream = await scan.call(
      params: (source: ImportSource.pixiv, limit: 0, token: token, creators: const {}),
    );

    expect(await stream.length, 100);
  });
}
