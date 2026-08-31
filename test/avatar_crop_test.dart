// Recortar un trozo de lo que se está mirando como avatar.
//
// Antes, crear una etiqueta desde el visor cogía el contenido entero: en una
// ilustración apaisada con cuatro personajes, el avatar de uno de ellos salía
// siendo la escena completa metida en un círculo.
//
// Lo que hay que sostener:
//
// - **El recorte cae donde se marcó.** Un rectángulo desplazado da un avatar de
//   otra cosa, y nada lo explica.
// - **Nada se escribe hasta que se confirma.** El diálogo devuelve el
//   rectángulo y no el fichero: cerrarlo sin elegir no puede dejar un recorte
//   tirado en la carpeta de avatares.
// - **La imagen entera sigue siendo una salida.** Es lo que hacía el botón antes
//   de que hubiera recorte, y para un contenido que ya es un retrato es lo
//   correcto.

import 'dart:io';
import 'dart:typed_data';

import 'package:Fern/features/media/domain/services/avatar_source.dart';
import 'package:Fern/features/media/presentation/widgets/avatar_crop_dialog.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/features/settings/data/services/image_cropper.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:Fern/features/settings/domain/repositories/settings_repository.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/ui/display/fern_region_selection_layer.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

/// Una imagen con la mitad izquierda roja y la derecha azul: así se puede decir
/// **de dónde** ha salido el recorte y no sólo cuánto mide.
Uint8List _twoHalves({int width = 200, int height = 100}) {
  final image = img.Image(width: width, height: height);

  for (var x = 0; x < width; x++) {
    for (var y = 0; y < height; y++) {
      image.setPixelRgba(
        x,
        y,
        x < width ~/ 2 ? 255 : 0,
        0,
        x < width ~/ 2 ? 0 : 255,
        255,
      );
    }
  }

  return img.encodePng(image);
}

void main() {
  group('el recorte', () {
    test('sale con el tamaño que se marcó', () {
      final cropped = cropImageSync(
        _twoHalves(),
        const Rect.fromLTWH(0, 0, 0.5, 0.5),
      );

      final decoded = img.decodeImage(cropped!.bytes)!;

      expect(decoded.width, 100);
      expect(decoded.height, 50);
    });

    // Lo que de verdad importa: que caiga donde se marcó. Un recorte del tamaño
    // correcto sacado del sitio equivocado es un avatar de otra cosa.
    test('y del sitio que se marcó', () {
      final left = img.decodeImage(
        cropImageSync(_twoHalves(), const Rect.fromLTWH(0, 0, 0.25, 1))!.bytes,
      )!;
      final right = img.decodeImage(
        cropImageSync(_twoHalves(), const Rect.fromLTWH(0.75, 0, 0.25, 1))!
            .bytes,
      )!;

      // Con margen: lo que sale es JPEG, que no devuelve el mismo número que
      // entró. Lo que se comprueba es de qué color es, no el valor exacto.
      expect(left.getPixel(0, 0).r, greaterThan(200),
          reason: 'la mitad izquierda es roja');
      expect(right.getPixel(0, 0).b, greaterThan(200),
          reason: 'la derecha es azul');
    });

    // El rectángulo se marca sobre lo pintado y el redondeo a píxeles puede
    // sacarlo por un punto: pasarse del borde reventaría el recorte.
    test('pegado al borde no se pasa', () {
      final cropped = cropImageSync(
        _twoHalves(),
        const Rect.fromLTWH(0.9, 0.9, 0.2, 0.2),
      );

      final decoded = img.decodeImage(cropped!.bytes)!;

      expect(decoded.width, lessThanOrEqualTo(20));
      expect(decoded.height, lessThanOrEqualTo(10));
    });

    test('uno que no llega a un píxel no devuelve nada', () {
      expect(
        cropImageSync(_twoHalves(), const Rect.fromLTWH(0, 0, 0.001, 0.001)),
        isNull,
      );
    });

    test('y lo que no es una imagen tampoco', () {
      expect(
        cropImageSync(Uint8List.fromList([1, 2, 3]), wholeImageRect),
        isNull,
      );
    });

    // Un PNG con transparencia vuelve a salir en PNG: pasarlo a JPEG le pondría
    // un fondo negro que nadie ha pedido.
    test('lo transparente se queda en PNG', () {
      final image = img.Image(width: 20, height: 20, numChannels: 4);
      final cropped = cropImageSync(
        img.encodePng(image),
        const Rect.fromLTWH(0, 0, 0.5, 0.5),
      );

      expect(cropped!.extension, '.png');
    });
  });

  group('guardarlo', () {
    late Directory root;
    late AvatarStorageService storage;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('fern_avatar_crop');
      storage = AvatarStorageService(
        settingsRepository: _Settings(avatarsPath: p.join(root.path, 'avatars')),
      );
    });

    tearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });

    Future<String> source() async {
      final file = File(p.join(root.path, 'ilustracion.png'));
      await file.writeAsBytes(_twoHalves());

      return file.path;
    }

    test('el recorte acaba en la carpeta de avatares', () async {
      final stored = await storage.storeCrop(
        await source(),
        const Rect.fromLTWH(0, 0, 0.5, 1),
      );

      expect(p.dirname(stored), p.normalize(storage.avatarsDirectory));
      expect(await File(stored).exists(), isTrue);
    });

    test('y lleva dentro sólo lo marcado', () async {
      final stored = await storage.storeCrop(
        await source(),
        const Rect.fromLTWH(0, 0, 0.5, 1),
      );

      final decoded = img.decodeImage(await File(stored).readAsBytes())!;

      expect(decoded.width, 100);
      expect(decoded.getPixel(0, 0).r, greaterThan(200));
    });

    // Mejor un avatar más ancho de lo que se pidió que ningún avatar: quien ha
    // marcado un cuadrado quiere una imagen ahí.
    test('lo que no se puede descodificar se guarda entero', () async {
      final broken = File(p.join(root.path, 'roto.png'));
      await broken.writeAsBytes(Uint8List.fromList([1, 2, 3]));

      final stored = await storage.storeCrop(
        broken.path,
        const Rect.fromLTWH(0, 0, 0.5, 1),
      );

      expect(p.dirname(stored), p.normalize(storage.avatarsDirectory));
      expect(await File(stored).readAsBytes(), [1, 2, 3]);
    });

    test('un fichero que ya no está no revienta', () async {
      final missing = p.join(root.path, 'no_existe.png');

      expect(await storage.storeCrop(missing, wholeImageRect), missing);
    });

    // Dos recortes de la misma imagen son dos avatares: el segundo no puede
    // pisar al primero, que puede estar puesto en otra ficha.
    test('dos recortes no se pisan', () async {
      final path = await source();

      final first = await storage.storeCrop(
        path,
        const Rect.fromLTWH(0, 0, 0.5, 1),
      );
      final second = await storage.storeCrop(
        path,
        const Rect.fromLTWH(0.5, 0, 0.5, 1),
      );

      expect(first, isNot(second));
      expect(await File(first).exists(), isTrue);
    });
  });

  // De qué se puede elegir un trozo. En vídeo y GIF el botón sigue sin abrir
  // nada: allí lo que se ve no es lo que hay en el fichero.
  group('de qué se recorta', () {
    test('de una imagen, sí', () {
      expect(cropsAvatarOf('ilustracion.png'), isTrue);
      expect(cropsAvatarOf('foto.JPG'), isTrue);
    });

    test('de un vídeo, no', () {
      expect(cropsAvatarOf('escena.mp4'), isFalse);
      expect(cropsAvatarOf('escena.webm'), isFalse);
    });

    test('y de un GIF tampoco', () {
      expect(cropsAvatarOf('bucle.gif'), isFalse);
    });
  });

  // El diálogo: lo que devuelve y cuándo deja devolverlo.
  //
  // El fichero **no se escribe aquí**. Es lo que hace que cerrarlo sin elegir no
  // deje un recorte tirado en la carpeta de avatares.
  group('el diálogo', () {
    late AppLocalizations texts;

    setUpAll(() async {
      texts = await AppLocalizations.delegate.load(const Locale('es'));
    });

    /// Abre el recorte y devuelve lo que conteste.
    ///
    /// El fichero no existe a propósito: el visor pinta su aviso de contenido
    /// roto y la capa sigue funcionando igual, que es lo que se mide aquí.
    Future<Rect?> open(WidgetTester tester) async {
      Rect? answer;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                answer = await showDialog<Rect>(
                  context: context,
                  builder: (_) => const AvatarCropDialog(
                    path: 'ilustracion.png',
                    contentSize: Size(400, 400),
                  ),
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      return answer;
    }

    bool canConfirm(WidgetTester tester) =>
        tester
            .widget<FernConfirmButton>(find.byType(FernConfirmButton))
            .onPressed !=
        null;

    testWidgets('sin marcar nada no hay nada que confirmar', (tester) async {
      await open(tester);

      expect(canConfirm(tester), isFalse);
    });

    // Para quedarse con el contenido entero está su propio botón, que dice lo
    // que hace: es lo que hacía el botón antes de que hubiera recorte, y para un
    // retrato es lo correcto.
    testWidgets('la imagen entera tiene su botón', (tester) async {
      await open(tester);

      await tester.tap(find.text(texts.avatarCropWholeImage));
      await tester.pumpAndSettle();

      expect(find.byType(AvatarCropDialog), findsNothing);
    });

    testWidgets('marcar un cuadrado enciende el confirmar', (tester) async {
      await open(tester);

      // Desde el centro: la imagen se pinta con `contain`, así que la esquina
      // del lienzo puede caer sobre una banda y ahí no hay nada que marcar.
      final center = tester.getCenter(find.byType(FernRegionSelectionLayer));
      await _dragMouse(
        tester,
        center - const Offset(40, 40),
        center + const Offset(20, 10),
      );

      expect(canConfirm(tester), isTrue);
    });

    // Lo que se devuelve es el rectángulo, no un fichero: el recorte se escribe
    // fuera y sólo si se confirma.
    testWidgets('y lo que devuelve es lo marcado, cuadrado', (tester) async {
      Rect? answer;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                answer = await showDialog<Rect>(
                  context: context,
                  builder: (_) => const AvatarCropDialog(
                    path: 'ilustracion.png',
                    contentSize: Size(400, 400),
                  ),
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      final center = tester.getCenter(find.byType(FernRegionSelectionLayer));
      await _dragMouse(
        tester,
        center - const Offset(40, 40),
        center + const Offset(20, 10),
      );

      await tester.tap(find.byType(FernConfirmButton));
      await tester.pumpAndSettle();

      expect(answer, isNotNull);
      expect(answer!.width, closeTo(answer!.height, 0.001));
      expect(answer, isNot(wholeImageRect));
    });

    testWidgets('cerrarlo no devuelve nada', (tester) async {
      await open(tester);

      await tester.tap(find.byIcon(Symbols.close));
      await tester.pumpAndSettle();

      expect(find.byType(AvatarCropDialog), findsNothing);
    });

    // 600 px es lo más bajo que la ventana se deja poner
    // (`kMinimumWindowHeight`), y 400 el caso extremo. El lienzo pide 420: sin
    // ceder, en una ventana baja empujaba los botones fuera del diálogo y no
    // había forma de confirmar el recorte.
    group('el alto', () {
      for (final height in [600.0, 400.0]) {
        testWidgets('no desborda a ${height.toInt()}px en ningún idioma',
            (tester) async {
          for (final locale in const [
            Locale('en'),
            Locale('es'),
            Locale('ca'),
            Locale('fr'),
          ]) {
            tester.view.physicalSize = Size(1000, height);
            tester.view.devicePixelRatio = 1.0;
            addTearDown(tester.view.reset);

            // El árbol se tira abajo antes de cada medida: reaprovechando los
            // render objects, el aviso sólo se da la primera vez.
            await tester.pumpWidget(const SizedBox.shrink());
            tester.takeException();

            await tester.pumpWidget(MaterialApp(
              theme: AppTheme.lightTheme,
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(
                body: AvatarCropDialog(
                  path: 'ilustracion.png',
                  contentSize: Size(400, 400),
                ),
              ),
            ));
            await tester.pump(const Duration(milliseconds: 400));

            expect(
              tester.takeException(),
              isNull,
              reason: 'desborda a ${height.toInt()}px en ${locale.languageCode}',
            );
          }
        });
      }
    });
  });
}

/// Un ratón de verdad: la capa mira qué botón viene pulsado, así que un dedo no
/// vale para el arrastre que marca.
Future<void> _dragMouse(WidgetTester tester, Offset from, Offset to) async {
  final gesture = await tester.startGesture(from, kind: PointerDeviceKind.mouse);
  await tester.pump();

  await gesture.moveTo(to);
  await tester.pump();

  await gesture.up();
  await tester.pumpAndSettle();
}

class _Settings implements SettingsRepository {
  final String avatarsPath;

  _Settings({required this.avatarsPath});

  @override
  AppSettingsEntity getSettings() =>
      AppSettingsEntity(avatarsPath: avatarsPath, recognitionPath: '');

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
