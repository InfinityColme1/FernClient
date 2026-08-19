// El recorrido de Pawchive tal y como lo ve la pantalla.
//
// El cliente ya está probado aparte; lo que se comprueba aquí es lo que hay
// entre él y la interfaz, que es donde un fallo se puede quedar por el camino
// sin que nadie lo vea: que una sesión rechazada llegue hasta arriba, y que una
// cuenta sin nada no se confunda con un fallo.

import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/data/datasources/pawchive_api_client.dart';
import 'package:Fern/features/media/data/datasources/danbooru_api_client.dart';
import 'package:Fern/features/media/data/datasources/gelbooru_api_client.dart';
import 'package:Fern/features/media/data/datasources/pinterest_api_client.dart';
import 'package:Fern/features/media/data/datasources/pixiv_api_client.dart';
import 'package:Fern/features/media/data/datasources/reddit_api_client.dart';
import 'package:Fern/features/media/data/repositories/remote_media_repository_impl.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/remote_media_downloader.dart';
import 'package:Fern/features/media/domain/entities/empty_source.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/remote_session_expired.dart';
import 'package:Fern/features/media/domain/services/import_decisions.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/pawchive_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Unos ajustes con la sesión de Pawchive puesta y nada más.
class _Settings implements SettingsRepository {
  final AppSettingsEntity settings;

  _Settings(this.settings);

  @override
  AppSettingsEntity getSettings() => settings;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Colaboradores que en estas pruebas no llegan a usarse: sin publicaciones no
/// hay nada que descargar ni que dar de alta.
class _Downloader implements RemoteMediaDownloader {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Registry implements MediaRegistry {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Clients {
  static PixivApiClient get pixiv => PixivApiClient();
  static RedditApiClient get reddit => RedditApiClient();
  static DanbooruApiClient get danbooru => DanbooruApiClient();
  static GelbooruApiClient get gelbooru => GelbooruApiClient();
  static PinterestApiClient get pinterest => PinterestApiClient();
}

Future<RemoteMediaRepositoryImpl> repositoryWith(http.Client client) async {
  SharedPreferences.setMockInitialValues({});

  return RemoteMediaRepositoryImpl(
    reddit: _Clients.reddit,
    pixiv: _Clients.pixiv,
    danbooru: _Clients.danbooru,
    gelbooru: _Clients.gelbooru,
    pinterest: _Clients.pinterest,
    pawchive: PawchiveApiClient(client: client),
    decisions: ImportDecisions(),
    downloader: _Downloader(),
    registry: _Registry(),
    settingsRepository: _Settings(const AppSettingsEntity(
      avatarsPath: '',
      recognitionPath: '',
      pawchive: PawchiveSettingsEntity(sessionId: 'la-sesion'),
    )),
    preferencesService: PreferencesService(
      await SharedPreferences.getInstance(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('una sesión rechazada llega hasta la pantalla', () async {
    final repository = await repositoryWith(
      MockClient((request) async => http.Response('{}', 401)),
    );

    final results =
        await repository.scanRemoteSource(ImportSource.pawchive).toList();

    // Sin esto, la importación acaba en silencio y el usuario no se entera de
    // que lo único que pasa es que tiene que volver a entrar en su cuenta.
    expect(results, hasLength(1));
    expect(
      results.single.exception,
      isA<RemoteSessionExpiredException>()
          .having((error) => error.source, 'fuente', ImportSource.pawchive),
    );
  });

  test('una cuenta sin nada marcado lo dice, en vez de acabar en silencio',
      () async {
    final repository = await repositoryWith(
      MockClient((request) async => http.Response('[]', 200)),
    );

    final results =
        await repository.scanRemoteSource(ImportSource.pawchive).toList();

    // Una importación que acaba en cero se ve igual que una rota si nadie la
    // explica.
    expect(results.single.exception, isA<EmptySourceException>());
    expect(
      (results.single.exception as EmptySourceException).hint,
      isNull,
    );
  });

  test('y si lo que hay son creadores, señala la opción que falta', () async {
    final repository = await repositoryWith(
      MockClient((request) async {
        final type = request.url.queryParameters['type'];

        // Ninguna publicación marcada, pero sí un creador.
        return http.Response(
          type == 'artist' ? '[{"id":"1","service":"fanbox"}]' : '[]',
          200,
        );
      }),
    );

    final results =
        await repository.scanRemoteSource(ImportSource.pawchive).toList();

    expect(
      (results.single.exception as EmptySourceException).hint,
      EmptySourceHint.pawchiveHasCreatorsInstead,
    );
  });

  test('una fuente sin configurar lo dice', () async {
    SharedPreferences.setMockInitialValues({});

    final repository = RemoteMediaRepositoryImpl(
      reddit: _Clients.reddit,
      pixiv: _Clients.pixiv,
      danbooru: _Clients.danbooru,
      gelbooru: _Clients.gelbooru,
      pinterest: _Clients.pinterest,
      pawchive: PawchiveApiClient(),
      decisions: ImportDecisions(),
      downloader: _Downloader(),
      registry: _Registry(),
      settingsRepository: _Settings(const AppSettingsEntity(
        avatarsPath: '',
        recognitionPath: '',
      )),
      preferencesService: PreferencesService(
        await SharedPreferences.getInstance(),
      ),
    );

    final results =
        await repository.scanRemoteSource(ImportSource.pawchive).toList();

    expect(results.single.exception, isA<Exception>());
  });
}
