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

  test('de fábrica, soltar en una etiqueta desmarca la selección', () {
    // El comportamiento de siempre: soltar es dar el trabajo por terminado, y
    // una selección que sobrevive sin haberla pedido se arrastra a lo siguiente
    // que se haga.
    expect(repository.getSettings().keepsSelectionOnDrop, isFalse);
  });

  test('mantener la selección al soltar vuelve tal cual', () async {
    await repository.saveSettings(
      repository.getSettings().copyWith(keepsSelectionOnDrop: true),
    );

    expect(repository.getSettings().keepsSelectionOnDrop, isTrue);
  });

  // Encendido de fábrica: es el comportamiento que se quiere sin tocar nada.
  // Con la clave ausente vale lo mismo, que es lo que hace que las instalaciones
  // que ya existen lo tengan puesto sin escribir nada.
  test('de fábrica, filtrar etiquetas trae la rama entera', () {
    expect(repository.getSettings().showsTagBranchOnFilter, isTrue);
  });

  test('apagar la rama al filtrar vuelve tal cual', () async {
    await repository.saveSettings(
      repository.getSettings().copyWith(showsTagBranchOnFilter: false),
    );

    expect(repository.getSettings().showsTagBranchOnFilter, isFalse);
  });

  // Encendido de fabrica: es lo que la aplicacion hacia antes de que esto se
  // pudiera elegir, asi que las instalaciones que ya existen —con la clave
  // ausente— se comportan igual que ayer sin escribir nada.
  test('de fábrica, una etiqueta marcada esconde su contenido', () {
    expect(repository.getSettings().nsfwTagsHideMedia, isTrue);
  });

  test('dejar la marca sólo en la etiqueta vuelve tal cual', () async {
    await repository.saveSettings(
      repository.getSettings().copyWith(nsfwTagsHideMedia: false),
    );

    expect(repository.getSettings().nsfwTagsHideMedia, isFalse);
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
