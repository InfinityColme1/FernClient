// Los ajustes del contenido repetido: el interruptor del escaneo automático, su
// periodo y el listón de similitud.
//
// Lo que se comprueba es que se guardan y que vuelven, que es el fallo típico al
// añadir un ajuste: la pantalla lo cambia, se ve el cambio, y al reiniciar la
// aplicación vuelve a estar como estaba. Y que un valor imposible en las
// preferencias —de una versión anterior, o tocado a mano— no deja el escaneo
// agrupando por un número que no existe.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/services/preferences_service.dart';
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

  group('de fábrica', () {
    test('el escaneo automático viene encendido, cada tres meses', () {
      const settings = AppSettingsEntity(
        avatarsPath: 'avatares',
        recognitionPath: 'reconocimiento',
      );

      expect(settings.automaticDuplicateScan, isTrue);
      expect(settings.duplicateScanPeriod, DuplicateScanPeriod.quarterly);
    });

    test('sin haberlo tocado nunca, se lee igual', () async {
      final settings = (await _repository()).getSettings();

      expect(settings.automaticDuplicateScan, isTrue);
      expect(settings.duplicateScanPeriod, DuplicateScanPeriod.quarterly);
      expect(settings.duplicateThreshold, defaultDuplicateThreshold);
      expect(settings.duplicateScanIncludesMoving, isTrue);
    });

    // Encendido de fábrica: los vídeos repetidos son los ficheros que más
    // ocupan de todos, y dejarlos fuera por defecto sería no encontrar justo lo
    // que más pesa.
    test('vídeos y GIF se miran de fábrica', () {
      const settings = AppSettingsEntity(
        avatarsPath: 'avatares',
        recognitionPath: 'reconocimiento',
      );

      expect(settings.duplicateScanIncludesMoving, isTrue);
    });
  });

  group('lo que se guarda es lo que vuelve', () {
    test('el interruptor apagado', () async {
      final repository = await _repository();

      await repository.saveSettings(
        repository.getSettings().copyWith(automaticDuplicateScan: false),
      );

      expect(repository.getSettings().automaticDuplicateScan, isFalse);
    });

    // El valor de fábrica está en dos sitios —el constructor de la entidad y el
    // `?? true` con el que se lee la preferencia— y tienen que decir lo mismo:
    // descuadrados, el comportamiento depende de por dónde se haya creado la
    // entidad, que es de las cosas que nadie va a mirar.
    test('la entidad nace arrastrando a las hijas', () {
      const settings = AppSettingsEntity(
        avatarsPath: 'avatares',
        recognitionPath: 'reconocimiento',
      );

      expect(settings.nsfwMarksChildTags, isTrue);
    });

    // Arrastrar a las hijas viene encendido: quien marca una etiqueta madre está
    // pensando en todo lo que hay debajo, y tener que repetir la marca rama por
    // rama es donde se olvida una.
    test('lo de las etiquetas hijas viene encendido y se puede apagar',
        () async {
      final repository = await _repository();

      expect(repository.getSettings().nsfwMarksChildTags, isTrue);

      await repository.saveSettings(
        repository.getSettings().copyWith(nsfwMarksChildTags: false),
      );

      expect(repository.getSettings().nsfwMarksChildTags, isFalse);
    });

    test('cómo se comporta el modo NSFW', () async {
      final repository = await _repository();

      await repository.saveSettings(
        repository.getSettings().copyWith(
              nsfwUnlockedView: NsfwUnlockedView.onlyNsfw,
              nsfwLockedView: NsfwLockedView.blurred,
            ),
      );

      expect(
        repository.getSettings().nsfwUnlockedView,
        NsfwUnlockedView.onlyNsfw,
      );
      expect(repository.getSettings().nsfwLockedView, NsfwLockedView.blurred);
    });

    test('de fábrica, todo junto y escondido', () async {
      final settings = (await _repository()).getSettings();

      // Escondido de fábrica: es lo único que cumple lo que promete la función.
      // Tapar deja ver que ahí hay algo, y eso es una elección que hay que
      // hacer, no una que se herede.
      expect(settings.nsfwUnlockedView, NsfwUnlockedView.mixed);
      expect(settings.nsfwLockedView, NsfwLockedView.hidden);
    });

    test('lo que se mueve, apagado', () async {
      final repository = await _repository();

      await repository.saveSettings(
        repository.getSettings().copyWith(duplicateScanIncludesMoving: false),
      );

      expect(repository.getSettings().duplicateScanIncludesMoving, isFalse);
    });

    test('el periodo elegido', () async {
      final repository = await _repository();

      await repository.saveSettings(
        repository
            .getSettings()
            .copyWith(duplicateScanPeriod: DuplicateScanPeriod.yearly),
      );

      expect(
        repository.getSettings().duplicateScanPeriod,
        DuplicateScanPeriod.yearly,
      );
    });

    test('el listón movido', () async {
      final repository = await _repository();

      await repository.saveSettings(
        repository.getSettings().copyWith(duplicateThreshold: 3),
      );

      expect(repository.getSettings().duplicateThreshold, 3);
    });
  });

  group('valores imposibles', () {
    test('un periodo que no existe cae en el de fábrica', () {
      expect(
        DuplicateScanPeriod.fromId('cada-martes'),
        DuplicateScanPeriod.quarterly,
      );
      expect(DuplicateScanPeriod.fromId(null), DuplicateScanPeriod.quarterly);
    });

    test('un listón fuera de rango se acota al leerlo', () async {
      SharedPreferences.setMockInitialValues({
        duplicateThresholdPreferenceKey: 999,
      });

      expect(
        (await _repository()).getSettings().duplicateThreshold,
        maxDuplicateThreshold,
      );
    });
  });

  // La marca es lo que decide cuándo vuelve a tocar. Se guarda como texto ISO,
  // así que lo que puede romperse es la vuelta.
  group('la marca del último escaneo', () {
    test('sin haber escaneado nunca no hay marca', () async {
      final preferences = PreferencesService(
        await SharedPreferences.getInstance(),
      );

      expect(preferences.getLastDuplicateScan(), isNull);
    });

    test('lo que se sella es lo que vuelve', () async {
      final preferences = PreferencesService(
        await SharedPreferences.getInstance(),
      );
      final at = DateTime(2026, 8, 24, 13, 45);

      await preferences.setLastDuplicateScan(at);

      expect(preferences.getLastDuplicateScan(), at);
    });

    test('una marca ilegible se lee como si no hubiera', () async {
      SharedPreferences.setMockInitialValues({
        lastDuplicateScanPreferenceKey: 'el martes pasado',
      });
      final preferences = PreferencesService(
        await SharedPreferences.getInstance(),
      );

      // Y entonces toca escanear, que es lo prudente: lo contrario es dejar la
      // función apagada para siempre por una preferencia estropeada.
      expect(preferences.getLastDuplicateScan(), isNull);
    });
  });

  // El periodo se guarda por su identificador y no por su posición: renumerar
  // el enum al añadir un periodo nuevo dejaría a todo el mundo con otro distinto.
  test('los identificadores del periodo no cambian', () {
    expect(
      DuplicateScanPeriod.values.map((period) => period.id),
      ['monthly', 'quarterly', 'biannual', 'yearly'],
    );
  });
}
