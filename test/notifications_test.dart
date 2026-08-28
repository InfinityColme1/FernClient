// Los avisos de lo que tarda.
//
// Dos cosas que sostener. Los contadores: que suban al avisar, que sobrevivan a
// cerrar la aplicación (por eso van a preferencias), que se apaguen al ir a
// mirar y que respeten lo que el usuario haya apagado. Y la bolita: que no se
// vea con cero, que diga el número, y que a partir de cien deje de decirlo y
// pase a "+99", que es lo único que cabe.

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/notifications/data/services/notification_service.dart';
import 'package:Fern/features/notifications/data/services/notification_sound_service.dart';
import 'package:Fern/features/notifications/domain/entities/app_notification.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/notification_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Settings implements SettingsRepository {
  NotificationSettingsEntity notifications;

  _Settings([this.notifications = const NotificationSettingsEntity()]);

  @override
  AppSettingsEntity getSettings() => AppSettingsEntity(
        avatarsPath: 'avatars',
        recognitionPath: 'recognition',
        notifications: notifications,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// El sonido no se prueba aquí: reproducir audio necesita libmpv y una salida
/// de sonido, que en una prueba no hay. Lo que sí se comprueba es que se le pida
/// sonar sólo cuando toca.
class _Sounds implements NotificationSoundService {
  final played = <NotificationKind>[];

  @override
  Future<void> play(
    NotificationKind kind, {
    required NotificationSettingsEntity settings,
  }) async {
    played.add(kind);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<NotificationService> serviceWith(
  _Settings settings,
  _Sounds sounds, {
  Map<String, Object> initial = const {},
}) async {
  SharedPreferences.setMockInitialValues(initial);

  return NotificationService(
    preferences: await SharedPreferences.getInstance(),
    settingsRepository: settings,
    sounds: sounds,
  );
}

Future<void> pumpBadge(WidgetTester tester, int count) {
  return tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Center(
        child: FernBadge(
          count: count,
          maxCount: notificationBadgeMaxCount,
          child: const Icon(Symbols.folder),
        ),
      ),
    ),
  ));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('los contadores', () {
    test('avisar sube el contador de su clase y sólo el suyo', () async {
      final sounds = _Sounds();
      final service = await serviceWith(_Settings(), sounds);

      await service.notify(NotificationKind.duplicatesFound, count: 12);

      expect(service.counts.of(NotificationKind.duplicatesFound), 12);
      expect(service.counts.of(NotificationKind.trainingFinished), 0);
      expect(sounds.played, [NotificationKind.duplicatesFound]);
    });

    test('dos avisos de la misma clase se suman', () async {
      final service = await serviceWith(_Settings(), _Sounds());

      await service.notify(NotificationKind.importFinished, count: 3);
      await service.notify(NotificationKind.importFinished, count: 4);

      expect(service.counts.of(NotificationKind.importFinished), 7);
    });

    test('una pantalla suma todo lo que lleva a ella', () async {
      final service = await serviceWith(_Settings(), _Sounds());

      // Reconocer e importar acaban los dos en la pantalla de importación.
      await service.notify(NotificationKind.recognitionFinished, count: 2);
      await service.notify(NotificationKind.importFinished, count: 5);

      expect(service.counts.forRoute(importRoute), 7);
      expect(service.counts.forRoute(modelsRoute), 0);
    });

    test('ir a la pantalla da por vistos sus avisos y deja los demás', () async {
      final service = await serviceWith(_Settings(), _Sounds());

      await service.notify(NotificationKind.importFinished);
      await service.notify(NotificationKind.trainingFinished);

      await service.markRouteSeen(importRoute);

      expect(service.counts.forRoute(importRoute), 0);
      expect(service.counts.of(NotificationKind.trainingFinished), 1);
    });

    test('lo pendiente sobrevive a cerrar la aplicación', () async {
      final sounds = _Sounds();
      final service = await serviceWith(_Settings(), sounds);
      await service.notify(NotificationKind.duplicatesFound, count: 4);

      // Otro servicio sobre las mismas preferencias es lo que pasa al volver a
      // abrir: lo anotado anoche sigue ahí.
      final reopened = NotificationService(
        preferences: await SharedPreferences.getInstance(),
        settingsRepository: _Settings(),
        sounds: sounds,
      );

      expect(reopened.counts.of(NotificationKind.duplicatesFound), 4);
    });

    test('con los avisos apagados no se anota ni suena nada', () async {
      final sounds = _Sounds();
      final settings = _Settings(
        const NotificationSettingsEntity(enabled: false),
      );
      final service = await serviceWith(settings, sounds);

      await service.notify(NotificationKind.trainingFinished);

      expect(service.counts.isEmpty, isTrue);
      expect(sounds.played, isEmpty);
    });

    test('en silencio se anota pero no suena', () async {
      final sounds = _Sounds();
      final settings = _Settings(
        const NotificationSettingsEntity(muted: true),
      );
      final service = await serviceWith(settings, sounds);

      await service.notify(NotificationKind.trainingFinished);

      expect(service.counts.of(NotificationKind.trainingFinished), 1);
      expect(sounds.played, isEmpty);
    });

    test('una clase con el contador quitado no suma, pero sigue sonando',
        () async {
      final sounds = _Sounds();
      final settings = _Settings(
        const NotificationSettingsEntity().withChannel(
          NotificationKind.trainingFinished,
          const NotificationChannelEntity(badge: false),
        ),
      );
      final service = await serviceWith(settings, sounds);

      await service.notify(NotificationKind.trainingFinished);

      expect(service.counts.of(NotificationKind.trainingFinished), 0);
      expect(sounds.played, [NotificationKind.trainingFinished]);
    });

    test('quien escucha se entera de cada cambio', () async {
      final service = await serviceWith(_Settings(), _Sounds());
      final seen = <int>[];

      final subscription = service.changes.listen(
        (counts) => seen.add(counts.of(NotificationKind.duplicatesFound)),
      );

      await service.notify(NotificationKind.duplicatesFound, count: 2);
      await service.notify(NotificationKind.duplicatesFound, count: 3);
      await service.markRouteSeen(repeatedMediaRoute);
      await Future<void>.delayed(Duration.zero);

      expect(seen, [2, 5, 0]);

      await subscription.cancel();
      await service.dispose();
    });
  });

  group('la bolita del contador', () {
    testWidgets('con cero no se pinta', (tester) async {
      await pumpBadge(tester, 0);

      expect(find.byIcon(Symbols.folder), findsOneWidget);
      expect(find.textContaining('0'), findsNothing);
    });

    testWidgets('dice el número mientras quepa', (tester) async {
      await pumpBadge(tester, 7);
      expect(find.text('7'), findsOneWidget);

      await pumpBadge(tester, 99);
      expect(find.text('99'), findsOneWidget);
    });

    testWidgets('a partir de cien deja de decirlo', (tester) async {
      await pumpBadge(tester, 100);
      expect(find.text('+99'), findsOneWidget);

      await pumpBadge(tester, 4321);
      expect(find.text('+99'), findsOneWidget);
    });
  });
}
