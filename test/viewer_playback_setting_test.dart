// Comprueba el ajuste de parar el video al coger la barra del visor.
//
// Es lo que decide si recorrer un video lo detiene. Apagado de fabrica: recorrer
// un video es normalmente buscar un momento **viendolo**, y pararlo en cada
// toque obliga a darle a reproducir otra vez.
//
// Lo que se comprueba aqui es que se guarda y que vuelve, que es el fallo tipico
// al anadir un ajuste: la pantalla lo cambia, se ve el cambio, y al reiniciar la
// aplicacion vuelve a estar como estaba.

import 'package:Fern/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SettingsRepositoryImpl> _repository() async {
  final preferences = await SharedPreferences.getInstance();

  return SettingsRepositoryImpl(
    preferences: preferences,
    defaultAvatarsPath: 'avatares',
    defaultRecognitionPath: 'reconocimiento',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('de fabrica esta apagado', () {
    const settings = AppSettingsEntity(
      avatarsPath: 'avatares',
      recognitionPath: 'reconocimiento',
    );

    expect(settings.pauseWhenSeeking, isFalse);
  });

  test('sin haberlo tocado nunca, se lee apagado', () async {
    final repository = await _repository();
    final settings = repository.getSettings();

    expect(settings.pauseWhenSeeking, isFalse);
  });

  test('lo que se guarda es lo que vuelve', () async {
    final repository = await _repository();

    final settings = repository.getSettings();
    await repository.saveSettings(settings.copyWith(pauseWhenSeeking: true));

    // Se relee de cero, como al arrancar la aplicacion.
    final again = (await _repository()).getSettings();

    expect(again.pauseWhenSeeking, isTrue);
  });

  test('apagarlo tambien se guarda', () async {
    SharedPreferences.setMockInitialValues({'pause_when_seeking': true});

    final repository = await _repository();
    final settings = repository.getSettings();
    expect(settings.pauseWhenSeeking, isTrue);

    await repository.saveSettings(settings.copyWith(pauseWhenSeeking: false));

    expect(
      ((await _repository()).getSettings()).pauseWhenSeeking,
      isFalse,
    );
  });
}
