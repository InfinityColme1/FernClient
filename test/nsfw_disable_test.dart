// Desactivar el filtro NSFW del todo.
//
// Es la única acción de esta función que **no se puede deshacer**: borra la
// contraseña y el código de recuperación. Lo que se comprueba aquí es el orden y
// lo que pasa cuando algo falla por en medio, porque quedarse a mitad deja una
// biblioteca que se esconderá sola en cuanto alguien vuelva a poner contraseña.

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/nsfw/data/services/password_service.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_disable_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late NsfwModeService mode;
  late _FakeMedia media;

  setUp(() async {
    mode = NsfwModeService(
      storage: _MemoryStorage(),
      passwords: PasswordService(iterations: 64),
    );
    await mode.configure(password: 'la buena');

    media = _FakeMedia();

    if (getIt.isRegistered<NsfwModeService>()) {
      await getIt.unregister<NsfwModeService>();
    }
    if (getIt.isRegistered<LocalMediaRepository>()) {
      await getIt.unregister<LocalMediaRepository>();
    }

    getIt.registerSingleton<NsfwModeService>(mode);
    getIt.registerSingleton<LocalMediaRepository>(media);
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: NsfwDisableDialog()),
    ));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> confirmWith(WidgetTester tester, String secret) async {
    await tester.enterText(find.byType(TextField).first, secret);
    await tester.tap(find.text('Desactivar el filtro').last);
    await tester.pumpAndSettle();
  }

  testWidgets('con la contraseña buena, limpia y quita la contraseña',
      (tester) async {
    await pump(tester);
    await confirmWith(tester, 'la buena');

    expect(media.cleared, isTrue);
    expect(mode.isConfigured, isFalse);
  });

  testWidgets('con la contraseña mala no toca nada', (tester) async {
    await pump(tester);
    await confirmWith(tester, 'la que no es');

    expect(media.cleared, isFalse);
    expect(mode.isConfigured, isTrue);
  });

  // Lo importante: si la limpieza falla, la contraseña se queda. Al revés, la
  // biblioteca queda con marcas puestas y sin contraseña, y eso no se nota
  // hasta que alguien pone otra y desaparece contenido de golpe.
  testWidgets('si no se pueden quitar las marcas, la contraseña se queda',
      (tester) async {
    media.isBroken = true;

    await pump(tester);
    await confirmWith(tester, 'la buena');

    expect(mode.isConfigured, isTrue);
  });

  testWidgets('y se dice, en vez de darlo por hecho', (tester) async {
    media.isBroken = true;

    await pump(tester);
    await confirmWith(tester, 'la buena');

    expect(
      find.textContaining('No se han podido quitar las marcas'),
      findsOneWidget,
    );
  });
}

class _FakeMedia implements LocalMediaRepository {
  bool cleared = false;
  bool isBroken = false;

  @override
  Future<DataState<int>> clearNsfwMarks() async {
    if (isBroken) return DataException(Exception('roto'));

    cleared = true;

    return const DataSuccess(3);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

class _MemoryStorage implements NsfwStorage {
  final Map<String, String> values = {};

  @override
  String? read(String key) => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
}
