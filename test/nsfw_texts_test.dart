// Los textos del modo NSFW.
//
// Dos cosas que se vieron en pantalla y que ninguna prueba habría cazado:
//
// - La sección se llamaba «contenido no apto». La función se llama NSFW en todas
//   partes —en el ajuste de la etiqueta, en el aviso del menú, en la
//   documentación— y llamarla de otra forma sólo en los ajustes obliga a
//   adivinar que son lo mismo.
// - La descripción llevaba `**` alrededor de lo importante, escrito como si
//   alguien fuera a interpretarlo. Nadie lo interpreta: la aplicación pinta
//   `Text`, no markdown, así que los asteriscos salían tal cual.
//
// Lo segundo se comprueba sobre **todas** las cadenas y no sólo las de NSFW: no
// hay una sola pantalla que interprete markdown, así que unos asteriscos dobles
// en cualquier idioma son siempre un error, y este es el sitio donde se ve.

import 'dart:convert';
import 'dart:io';

import 'package:Fern/features/nsfw/presentation/widgets/nsfw_setup_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _languages = ['en', 'es', 'ca', 'fr'];

Future<AppLocalizations> _textsIn(WidgetTester tester, String languageCode) async {
  late AppLocalizations texts;

  await tester.pumpWidget(MaterialApp(
    locale: Locale(languageCode),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(builder: (context) {
      texts = AppLocalizations.of(context);
      return const SizedBox.shrink();
    }),
  ));

  return texts;
}

/// Las cadenas de un idioma, leídas del fichero de traducción.
///
/// Del `.arb` y no de la clase generada porque lo que se busca es un descuido en
/// cualquier texto, y recorrer un mapa es lo que permite mirarlos todos sin
/// tener que nombrarlos uno a uno.
Map<String, String> _stringsOf(String languageCode) {
  final raw = File('lib/l10n/app_$languageCode.arb').readAsStringSync();
  final decoded = jsonDecode(raw) as Map<String, dynamic>;

  return {
    for (final entry in decoded.entries)
      // Las claves que empiezan por arroba son los metadatos del formato, no
      // texto que se enseñe.
      if (!entry.key.startsWith('@') && entry.value is String)
        entry.key: entry.value as String,
  };
}

void main() {
  group('cómo se llama la función', () {
    testWidgets('la sección de ajustes dice NSFW', (tester) async {
      for (final language in _languages) {
        final texts = await _textsIn(tester, language);

        expect(
          texts.settingsNsfw.toUpperCase(),
          contains('NSFW'),
          reason: 'en $language la sección no se llama por su nombre',
        );
      }
    });

    testWidgets('y también la etiqueta de lo tapado', (tester) async {
      for (final language in _languages) {
        final texts = await _textsIn(tester, language);

        expect(texts.nsfwCoveredLabel.toUpperCase(), contains('NSFW'));
      }
    });

    // Se llamaba así antes y volver a ello sería deshacer el arreglo sin que
    // nada lo dijera.
    test('en ningún idioma se la llama «contenido no apto»', () {
      const oldNames = ['no apto', 'no apte', 'not suitable', 'inapproprié'];

      for (final language in _languages) {
        for (final entry in _stringsOf(language).entries) {
          for (final old in oldNames) {
            expect(
              entry.value.toLowerCase(),
              isNot(contains(old)),
              reason: '$language/${entry.key} usa el nombre viejo',
            );
          }
        }
      }
    });
  });

  // La aplicación pinta `Text`, no markdown: lo que se escriba con asteriscos
  // sale con asteriscos. Lo que va en negrita se pide con un `TextStyle`.
  group('nada de markdown en los textos', () {
    test('ninguna cadena lleva negrita escrita a mano', () {
      for (final language in _languages) {
        for (final entry in _stringsOf(language).entries) {
          expect(
            entry.value,
            isNot(contains('**')),
            reason: '$language/${entry.key} lleva asteriscos de negrita, y se '
                'pintan tal cual',
          );
        }
      }
    });

    test('ni cursiva, ni guiones bajos de énfasis', () {
      for (final language in _languages) {
        for (final entry in _stringsOf(language).entries) {
          expect(
            entry.value,
            isNot(contains('__')),
            reason: '$language/${entry.key} lleva guiones bajos de énfasis',
          );
        }
      }
    });
  });

  // Quitar los asteriscos no basta: si no se pone la negrita por el otro lado,
  // el arreglo deja el aviso indistinguible del resto y lo que se buscaba —que
  // no se pueda leer por encima— se pierde sin que nada lo diga.
  //
  // Se mide en el diálogo de poner la contraseña y no en la sección de ajustes:
  // el texto es el mismo y la intención también, y la sección lee el estado del
  // modo al construirse, lo que pediría levantar medio arranque para comprobar
  // un grosor de letra.
  testWidgets('lo que no se puede leer por encima va en negrita',
      (tester) async {
    final texts = await _textsIn(tester, 'es');

    await tester.pumpWidget(MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: NsfwSetupDialog()),
    ));
    await tester.pump(const Duration(milliseconds: 400));

    final warning = tester.widget<Text>(find.text(texts.nsfwSectionWarning));

    expect(warning.style?.fontWeight, FontWeight.w700);
  });

  // La prueba anterior no vale de nada si mira un fichero que no existe o que
  // está vacío: pasaría en verde sin haber comprobado un solo texto.
  test('hay textos que mirar en los cuatro idiomas', () {
    for (final language in _languages) {
      expect(
        _stringsOf(language).length,
        greaterThan(100),
        reason: 'no se han podido leer las cadenas de $language',
      );
    }
  });
}
