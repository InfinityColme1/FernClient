// Los diálogos del modo NSFW en una ventana baja.
//
// El de poner la contraseña son tres campos, dos avisos y un mensaje de error, y
// `FernDialog` le da a su contenido la altura que sobra: en una ventana de
// portátil se desbordaba por abajo, y lo que se salía era justo el campo de la
// frase clave y el error. Lo que se comprueba aquí es que ninguno desborda a la
// altura a la que se vio el fallo, y que lo que no cabe se puede desplazar.
//
// El de desbloqueo lee la frase clave del localizador de servicios al pintarse,
// así que se le registra un modo de mentira con una puesta: es el diálogo que
// más veces se ve, y dejarlo fuera de la medida sería dejar fuera el caso
// normal.
//
// La tipografía de la aplicación se carga a mano, como en las demás pruebas de
// medidas: sin ella se mide con la fuente de pruebas, en la que cada letra es un
// cuadrado, y los textos salen mucho más altos de lo que se ven.

import 'dart:io';

import 'package:Fern/config/theme/app_theme.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/nsfw/data/services/password_service.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_change_password_dialog.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_disable_dialog.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_recover_dialog.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_recovery_code_dialog.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_setup_dialog.dart';
import 'package:Fern/features/nsfw/presentation/widgets/nsfw_unlock_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _locales = [Locale('en'), Locale('es'), Locale('ca'), Locale('fr')];

/// La altura a la que se vio el fallo: una ventana de portátil sin maximizar.
const _laptopHeight = 600.0;

/// El caso extremo, donde no cabe casi nada y todo tiene que poder desplazarse.
const _tinyHeight = 400.0;

final _dialogs = <String, Widget>{
  'poner la contraseña': const NsfwSetupDialog(),
  'cambiar la contraseña': const NsfwChangePasswordDialog(),
  'recuperar': const NsfwRecoverDialog(),
  'código de recuperación':
      const NsfwRecoveryCodeDialog(code: 'ABCD-EFGH-JKLM-NPQR'),
  'quitar el bloqueo': const NsfwDisableDialog(),
  'desbloquear': const NsfwUnlockDialog(),
};

/// Lo que el diálogo de desbloqueo pide al arrancar.
///
/// Con frase clave puesta a propósito: es el texto más largo que puede aparecer
/// ahí, y sin él la medida se haría sobre el diálogo más corto de todos.
Future<void> _registerNsfwMode() async {
  final storage = _MemoryStorage();
  final mode = NsfwModeService(
    storage: storage,
    passwords: PasswordService(iterations: 64),
  );
  await mode.configure(password: 'secreto', hint: _longHint);

  if (getIt.isRegistered<NsfwModeService>()) {
    await getIt.unregister<NsfwModeService>();
  }
  getIt.registerSingleton<NsfwModeService>(mode);
}

const _longHint =
    'La que uso siempre para las cosas que no quiero que vea nadie, '
    'la de la libreta del cajón de arriba';

class _MemoryStorage implements NsfwStorage {
  final Map<String, String> values = {};

  @override
  String? read(String key) => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
}

Future<void> _loadAppFont() async {
  final loader = FontLoader('Google Sans Flex');
  for (final weight in ['Light', 'Medium', 'Regular', 'SemiBold']) {
    loader.addFont(File('assets/fonts/GoogleSansFlex_24pt-$weight.ttf')
        .readAsBytes()
        .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer)));
  }
  await loader.load();
}

Widget _harness(Widget dialog, Locale locale) => MaterialApp(
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: dialog),
    );

/// Monta un diálogo a la altura dada y devuelve el aviso de desbordamiento, si
/// lo hay.
Future<Object?> _overflowAt(
  WidgetTester tester, {
  required Widget dialog,
  required Locale locale,
  required double height,
}) async {
  tester.view.physicalSize = Size(1000, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  // El árbol se tira abajo antes de cada medida: reaprovechando los render
  // objects, el aviso sólo se da la primera vez y las siguientes saldrían
  // limpias sin serlo.
  await tester.pumpWidget(const SizedBox.shrink());
  tester.takeException();

  await tester.pumpWidget(_harness(dialog, locale));
  await tester.pump(const Duration(milliseconds: 400));

  return tester.takeException();
}

void main() {
  setUpAll(() async {
    await _loadAppFont();
    await _registerNsfwMode();
  });

  for (final height in [_laptopHeight, _tinyHeight]) {
    group('a ${height.toInt()}px de alto', () {
      for (final entry in _dialogs.entries) {
        // Los cuatro idiomas en la misma prueba: el que desborda es siempre el
        // texto más largo, y no es el mismo idioma en cada aviso.
        testWidgets('el de ${entry.key} no desborda', (tester) async {
          for (final locale in _locales) {
            final overflow = await _overflowAt(
              tester,
              dialog: entry.value,
              locale: locale,
              height: height,
            );

            expect(
              overflow,
              isNull,
              reason: 'el diálogo de ${entry.key} desborda a '
                  '${height.toInt()}px en ${locale.languageCode}',
            );
          }
        });
      }
    });
  }

  testWidgets('lo que no cabe se alcanza desplazándose', (tester) async {
    final overflow = await _overflowAt(
      tester,
      dialog: const NsfwSetupDialog(),
      locale: const Locale('es'),
      height: _tinyHeight,
    );
    expect(overflow, isNull);

    // Lo que sube y baja es el formulario, no el diálogo entero: el botón de
    // guardar se queda fijo abajo. Sin esto, la frase clave sería inalcanzable
    // en una ventana baja.
    expect(find.byType(SingleChildScrollView), findsOneWidget);

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsWidgets);
  });
}
