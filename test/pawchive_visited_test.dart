// Cuando se dio por mirado a cada creador de Pawchive.
//
// Es distinto de la marca de por donde se iba, y por eso se guarda aparte: la
// marca dice «de aqui para atras ya esta traido» y solo se mueve cuando llega
// algo nuevo; la fecha dice «te he mirado», y eso pasa aunque no hubiera nada.
//
// Sin esa diferencia, el creador que no publica se queda con la fecha de la
// ultima vez que si publico, y su tarjeta sigue diciendo que tiene novedades
// para siempre.

import 'dart:convert';

import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/features/media/data/datasources/danbooru_api_client.dart';
import 'package:Fern/features/media/data/datasources/gelbooru_api_client.dart';
import 'package:Fern/features/media/data/datasources/pawchive_api_client.dart';
import 'package:Fern/features/media/data/datasources/pinterest_api_client.dart';
import 'package:Fern/features/media/data/datasources/pixiv_api_client.dart';
import 'package:Fern/features/media/data/datasources/reddit_api_client.dart';
import 'package:Fern/features/media/data/repositories/remote_media_repository_impl.dart';
import 'package:Fern/features/media/data/services/media_registry.dart';
import 'package:Fern/features/media/data/services/remote_media_downloader.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/services/import_decisions.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/pawchive_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:Fern/features/media/data/services/blocked_imports.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Settings implements SettingsRepository {
  @override
  AppSettingsEntity getSettings() => const AppSettingsEntity(
        avatarsPath: '',
        recognitionPath: '',
        pawchive: PawchiveSettingsEntity(sessionId: 'la-sesion'),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Downloader implements RemoteMediaDownloader {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Registry implements MediaRegistry {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Una cuenta con un creador marcado que no ha publicado nada nuevo: lo unico
/// que tiene es la publicacion en la que se quedo la importacion anterior.
http.Client _accountWithNothingNew() {
  return MockClient((request) async {
    if (request.url.path.contains('favorites')) {
      return http.Response(
        jsonEncode([
          {'id': '1', 'service': 'patreon', 'name': 'Alguien', 'faved_seq': 1},
        ]),
        200,
      );
    }

    return http.Response(jsonEncode([
      {'id': 'p1', 'service': 'patreon', 'user': '1', 'title': 'Lo de siempre'},
    ]), 200);
  });
}

Future<(RemoteMediaRepositoryImpl, PreferencesService)> _repository(
  http.Client client,
) async {
  final preferences = PreferencesService(await SharedPreferences.getInstance());

  return (
    RemoteMediaRepositoryImpl(
      reddit: RedditApiClient(),
      pixiv: PixivApiClient(),
      danbooru: DanbooruApiClient(),
      gelbooru: GelbooruApiClient(),
      pinterest: PinterestApiClient(),
      pawchive: PawchiveApiClient(client: client),
      decisions: ImportDecisions(),
      downloader: _Downloader(),
      registry: _Registry(),
      settingsRepository: _Settings(),
      blocked: _blocked(),
      preferencesService: preferences,
    ),
    preferences,
  );
}

/// Sin base de datos: aqui no se prueba el bloqueo, y abrir una entera para
/// preguntar por algo que esta vacio seria pedir mucho a cambio de nada.
BlockedImports _blocked() => BlockedImports();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Ya se importo de este creador una vez, y se quedo en `p1`.
    SharedPreferences.setMockInitialValues({
      'last_import_marker_pawchive_patreon-1': 'p1',
    });
  });

  test('al que no ha publicado nada tambien se le da por mirado', () async {
    final (repository, preferences) = await _repository(
      _accountWithNothingNew(),
    );

    await repository
        .scanRemoteSource(
          ImportSource.pawchive,
          untilLastImport: true,
          creators: {'patreon-1'},
        )
        .toList();

    // No ha entrado nada, y aun asi se le ha mirado: es lo que apaga el aviso de
    // novedades hasta que vuelva a publicar.
    expect(
      preferences.importDates(ImportSource.pawchive).keys,
      contains('patreon-1'),
    );
  });

  test('y su marca se queda donde estaba', () async {
    // La fecha se mueve y la marca no: son dos cosas distintas y por eso la
    // proxima importacion seguira mirando desde `p1`.
    final (repository, preferences) = await _repository(
      _accountWithNothingNew(),
    );

    await repository
        .scanRemoteSource(
          ImportSource.pawchive,
          untilLastImport: true,
          creators: {'patreon-1'},
        )
        .toList();

    expect(
      preferences.importMarkers(ImportSource.pawchive)['patreon-1'],
      'p1',
    );
  });

  test('al que no se ha mirado no se le pone fecha', () async {
    // Elegir a uno es no elegir a los demas: al que no entra en la tanda no se
    // le ha mirado, y decir lo contrario esconderia sus novedades.
    SharedPreferences.setMockInitialValues({
      'last_import_marker_pawchive_patreon-1': 'p1',
    });

    final (repository, preferences) = await _repository(
      MockClient((request) async {
        if (request.url.path.contains('favorites')) {
          return http.Response(
            jsonEncode([
              {'id': '1', 'service': 'patreon', 'name': 'A', 'faved_seq': 1},
              {'id': '2', 'service': 'patreon', 'name': 'B', 'faved_seq': 2},
            ]),
            200,
          );
        }

        return http.Response(jsonEncode([
          {'id': 'p1', 'service': 'patreon', 'user': '1', 'title': 'x'},
        ]), 200);
      }),
    );

    await repository
        .scanRemoteSource(
          ImportSource.pawchive,
          untilLastImport: true,
          creators: {'patreon-1'},
        )
        .toList();

    final dates = preferences.importDates(ImportSource.pawchive);

    expect(dates.keys, contains('patreon-1'));
    expect(dates.keys, isNot(contains('patreon-2')));
  });
}
