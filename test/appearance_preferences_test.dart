// Lo que se guarda de la apariencia y del visor.
//
// Son ajustes que se leen al arrancar, antes de que haya ninguna pantalla: si no
// vuelven tal y como se dejaron, la aplicación abre con otro aspecto del que se
// eligió.

import 'package:Fern/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/entities/theme_settings_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsRepositoryImpl repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = SettingsRepositoryImpl(
      preferences: await SharedPreferences.getInstance(),
      defaultAvatarsPath: 'avatars',
      defaultRecognitionPath: 'recognition',
    );
  });

  test('de fábrica el tema lo dice el sistema y el visor pasa al siguiente', () {
    final settings = repository.getSettings();

    expect(settings.themeMode, AppThemeMode.system);
    expect(settings.viewerSaveBehavior, ViewerSaveBehavior.goToNext);
    expect(settings.customTheme.isEmpty, isTrue);
  });

  test('el tema elegido vuelve tal cual', () async {
    await repository.saveSettings(
      repository.getSettings().copyWith(themeMode: AppThemeMode.dark),
    );

    expect(repository.getSettings().themeMode, AppThemeMode.dark);
  });

  test('cerrar la visualización al guardar vuelve tal cual', () async {
    await repository.saveSettings(
      repository.getSettings().copyWith(
            viewerSaveBehavior: ViewerSaveBehavior.closeViewer,
          ),
    );

    expect(
      repository.getSettings().viewerSaveBehavior,
      ViewerSaveBehavior.closeViewer,
    );
  });

  test('los colores del usuario vuelven tal cual', () async {
    await repository.saveSettings(
      repository.getSettings().copyWith(
            customTheme: const CustomThemeEntity(
              primary: 0xFF00FF00,
              background: 0xFF101010,
            ),
          ),
    );

    final custom = repository.getSettings().customTheme;

    expect(custom.primary, 0xFF00FF00);
    expect(custom.background, 0xFF101010);
    // Los que no se han tocado siguen sin estar, que es lo que los hace
    // heredarse en lugar de quedarse con un color de más.
    expect(custom.secondary, isNull);
  });

  test('restablecer un color lo borra de lo guardado', () async {
    final saved = repository.getSettings().copyWith(
          customTheme: const CustomThemeEntity(primary: 0xFF00FF00),
        );
    await repository.saveSettings(saved);

    await repository.saveSettings(
      saved.copyWith(
        customTheme: saved.customTheme.withColor(CustomThemeColor.primary, null),
      ),
    );

    expect(repository.getSettings().customTheme.primary, isNull);
  });

  test('un tema guardado que ya no existe se lee como el del sistema', () {
    // Ni la lectura ni el arranque pueden romperse porque en las preferencias
    // haya quedado el identificador de un tema retirado.
    expect(AppThemeMode.fromId('lo-que-sea'), AppThemeMode.system);
    expect(ViewerSaveBehavior.fromId(null), ViewerSaveBehavior.goToNext);
  });
}
