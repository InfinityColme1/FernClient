// El bloqueo visto desde el recorrido de una fuente, que es donde tiene que
// notarse.
//
// Lo importante no es que la pieza no aparezca —eso ya lo hacía descartarla—,
// sino **que no llegue a bajarse**. Por eso se mira por su dirección en la
// fuente, que se conoce antes de descargar, y por eso lo que se comprueba aquí
// es a quién se le pidió el fichero al descargador.
//
// Lo otro que se sostiene es lo que un salto no debe romper: saltarse una pieza
// no es que haya fallado, así que ni cuenta como importación rota ni tira la
// marca de por dónde iba el recorrido.

import 'dart:convert';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/data/datasources/danbooru_api_client.dart';
import 'package:Fern/features/media/data/datasources/gelbooru_api_client.dart';
import 'package:Fern/features/media/data/datasources/pawchive_api_client.dart';
import 'package:Fern/features/media/data/datasources/pinterest_api_client.dart';
import 'package:Fern/features/media/data/datasources/pixiv_api_client.dart';
import 'package:Fern/features/media/data/datasources/reddit_api_client.dart';
import 'package:Fern/features/media/data/repositories/remote_media_repository_impl.dart';
import 'package:Fern/features/media/data/services/blocked_imports.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/remote_media_downloader.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/domain/services/import_decisions.dart';
import 'package:Fern/features/media/domain/usecases/scan_source_usecase.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/gelbooru_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Se recorre Gelbooru porque su listado es el más corto de fingir: unas cuantas
/// referencias y una publicación por cada una. La guarda es la misma en las seis
/// fuentes.
http.Client _fakeGelbooru(List<int> postIds) {
  return MockClient((request) async {
    final params = request.url.queryParameters;

    if (params['s'] == 'favorite') {
      final page = int.parse(params['pid'] ?? '0');

      return http.Response(
        jsonEncode({
          '@attributes': {'count': postIds.length},
          'favorite': page > 0
              ? const []
              : [
                  for (final id in postIds) {'id': id, 'favorite': id},
                ],
        }),
        200,
      );
    }

    final id = params['id'] ?? '';

    return http.Response(
      jsonEncode({
        'post': {
          'id': int.parse(id),
          'file_url': 'https://img3.gelbooru.com/images/$id.jpg',
          'source': '',
        },
      }),
      200,
    );
  });
}

/// Apunta a quién se le pidió el fichero, que es lo único que hay que mirar: si
/// una pieza bloqueada llega hasta aquí, la guarda no sirve de nada.
class _Downloader implements RemoteMediaDownloader {
  final asked = <String>[];

  @override
  Future<String?> download({
    required String url,
    required String name,
    required ImportSource source,
    Map<String, String> headers = const {},
    List<int>? frameDelays,
    bool asArchive = false,
  }) async {
    asked.add(name);

    return r'C:\biblioteca\' '$name.jpg';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Registry implements MediaRegistry {
  var _next = 1;

  /// Con qué nombre se ha dado de alta cada pieza en su fuente: es lo que hace
  /// falta para poder bloquearla luego sin tener que deducirlo de nada.
  final registered = <String, String?>{};

  @override
  Future<MediaSummaryEntity?> register({
    required String path,
    required ImportSource source,
    String? description,
    String? sourceTagName,
    List<String> sourceUrls = const [],
    String? remoteId,
  }) async {
    registered[path] = remoteId;

    return MediaSummaryEntity(
      id: _next++,
      path: path,
      importSource: source,
      remoteId: remoteId,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Settings implements SettingsRepository {
  @override
  AppSettingsEntity getSettings() => const AppSettingsEntity(
        avatarsPath: '',
        recognitionPath: '',
        gelbooru: GelbooruSettingsEntity(userId: '4242', apiKey: 'clave'),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Downloader downloader;
  late _Registry registry;
  late BlockedImports blocked;
  late PreferencesService preferences;

  /// Un bloqueo de mentira sin base de datos detrás: aquí no se prueba dónde se
  /// guarda —eso es de `blocked_imports_test`— sino qué hace el recorrido con la
  /// respuesta.
  Future<RemoteMediaRepositoryImpl> scanning(List<int> postIds) async {
    SharedPreferences.setMockInitialValues({});
    preferences = PreferencesService(await SharedPreferences.getInstance());
    downloader = _Downloader();
    registry = _Registry();

    return RemoteMediaRepositoryImpl(
      reddit: RedditApiClient(),
      pixiv: PixivApiClient(),
      danbooru: DanbooruApiClient(),
      gelbooru: GelbooruApiClient(client: _fakeGelbooru(postIds)),
      pinterest: PinterestApiClient(),
      pawchive: PawchiveApiClient(),
      decisions: ImportDecisions(),
      blocked: blocked,
      downloader: downloader,
      registry: registry,
      settingsRepository: _Settings(),
      preferencesService: preferences,
    );
  }

  setUp(() {
    blocked = _MemoryBlocked();
  });

  test('lo que no está bloqueado se descarga, como siempre', () async {
    final repository = await scanning([1, 2]);

    final results =
        await repository.scanRemoteSource(ImportSource.gelbooru).toList();

    // Sin orden: el listado de esta plataforma no siempre llega igual y su
    // cliente lo recoloca. Lo que se mira aqui es qué se pidió, no en qué orden.
    expect(downloader.asked, unorderedEquals(['gelbooru_1', 'gelbooru_2']));
    expect(results.whereType<DataSuccess>(), hasLength(2));
  });

  test('una pieza bloqueada no se descarga', () async {
    (blocked as _MemoryBlocked).add('gelbooru_1');

    final repository = await scanning([1, 2]);

    await repository.scanRemoteSource(ImportSource.gelbooru).toList();

    // Ni siquiera se le pide el fichero: la dirección se conocía antes.
    expect(downloader.asked, ['gelbooru_2']);
  });

  test('ni aparece en la importación', () async {
    (blocked as _MemoryBlocked).add('gelbooru_1');

    final repository = await scanning([1, 2]);

    final results =
        await repository.scanRemoteSource(ImportSource.gelbooru).toList();

    expect(results.whereType<DataSuccess>(), hasLength(1));
  });

  test('se cuenta, para poder decir cuántas se saltaron', () async {
    (blocked as _MemoryBlocked).add('gelbooru_1');
    (blocked as _MemoryBlocked).add('gelbooru_2');

    final repository = await scanning([1, 2, 3]);

    await repository.scanRemoteSource(ImportSource.gelbooru).toList();

    expect(blocked.skipped, 2);
  });

  // Sin esto habría que deducirlo del nombre del fichero, y eso no vale para lo
  // que sale de un comprimido: esos ficheros se llaman como venían dentro.
  test('lo que entra se queda sabiendo cómo se llamaba en la fuente', () async {
    final repository = await scanning([1]);

    await repository.scanRemoteSource(ImportSource.gelbooru).toList();

    expect(registry.registered.values.single, 'gelbooru_1');
  });

  test('desbloquearla la vuelve a traer', () async {
    (blocked as _MemoryBlocked).add('gelbooru_1');

    var repository = await scanning([1, 2]);
    await repository.scanRemoteSource(ImportSource.gelbooru).toList();
    expect(downloader.asked, ['gelbooru_2']);

    (blocked as _MemoryBlocked).remove('gelbooru_1');

    repository = await scanning([1, 2]);
    await repository.scanRemoteSource(ImportSource.gelbooru).toList();

    expect(downloader.asked, unorderedEquals(['gelbooru_1', 'gelbooru_2']));
  });

  // Un identificador de otra fuente no puede tapar una pieza de ésta.
  test('el bloqueo es de esta fuente', () async {
    (blocked as _MemoryBlocked).add('gelbooru_1', source: 'reddit');

    final repository = await scanning([1]);

    await repository.scanRemoteSource(ImportSource.gelbooru).toList();

    expect(downloader.asked, ['gelbooru_1']);
  });

  // El corte por cuenta va sobre lo que **llega**, no sobre lo que la fuente
  // ofrece. Es lo que hay que sostener: pedir tres con dos bloqueadas por medio
  // tiene que traer tres, no una.
  group('el tope de la importación', () {
    Future<int> broughtAskingFor(int limit, {required List<int> postIds}) async {
      final repository = await scanning(postIds);

      final scan = ScanSourceUseCase(
        localMediaRepository: _UnusedLocal(),
        remoteMediaRepository: repository,
        preferencesService: preferences,
      );

      final stream = await scan.call(params: (
        source: ImportSource.gelbooru,
        limit: limit,
        token: null,
        creators: const <String>{},
      ));

      return (await stream.toList()).whereType<DataSuccess>().length;
    }

    test('sin nada bloqueado trae los que se piden', () async {
      expect(await broughtAskingFor(3, postIds: [1, 2, 3, 4, 5]), 3);
    });

    test('y con dos bloqueadas por medio, los mismos', () async {
      (blocked as _MemoryBlocked).add('gelbooru_5');
      (blocked as _MemoryBlocked).add('gelbooru_4');

      // Sin esto, una tanda con la mitad bloqueada traería la mitad de lo
      // pedido y parecería que la fuente se ha quedado sin nada.
      expect(await broughtAskingFor(3, postIds: [1, 2, 3, 4, 5]), 3);
    });
  });

  group('lo que un salto no debe romper', () {
    // Con todo bloqueado no ha entrado nada, y eso se parece mucho a una
    // importación rota. No lo es: no ha fallado ninguna descarga porque no se ha
    // intentado ninguna.
    test('todo bloqueado no es una importación rota', () async {
      (blocked as _MemoryBlocked).add('gelbooru_1');

      final repository = await scanning([1]);

      final results =
          await repository.scanRemoteSource(ImportSource.gelbooru).toList();

      expect(results.whereType<DataException>(), isEmpty);
    });

    // Sin esto, saltarse la pieza más reciente dejaría la marca donde estaba y
    // la siguiente importación volvería a recorrer lo mismo para nada.
    test('la marca de por dónde iba se guarda igual', () async {
      (blocked as _MemoryBlocked).add('gelbooru_2');

      final repository = await scanning([2, 1]);

      await repository.scanRemoteSource(ImportSource.gelbooru).toList();

      expect(preferences.getLastImportMarker(ImportSource.gelbooru), '2');
    });
  });
}

/// El equipo no pinta nada aquí: la fuente que se recorre es remota.
class _UnusedLocal implements LocalMediaRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Lo bloqueado sin base de datos detrás, para poder moverlo dentro de la
/// prueba.
class _MemoryBlocked implements BlockedImports {
  final _rows = <String>{};

  void add(String remoteId, {String source = 'gelbooru'}) =>
      _rows.add('$source/$remoteId');

  void remove(String remoteId, {String source = 'gelbooru'}) =>
      _rows.remove('$source/$remoteId');

  @override
  bool blocks(String source, String remoteId) =>
      _rows.contains('$source/$remoteId');

  int _skipped = 0;

  @override
  int get skipped => _skipped;

  @override
  void noteSkipped() => _skipped++;

  @override
  void resetSkipped() => _skipped = 0;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
