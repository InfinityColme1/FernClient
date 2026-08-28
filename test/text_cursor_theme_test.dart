// El cursor de los campos de texto tiene que verse.
//
// De fábrica Material lo pinta con el primario del esquema de color, que aquí
// es el lavanda de la aplicación: sobre el fondo de un campo quedaba una raya de
// un píxel y medio tono, y había que buscarla para saber dónde se estaba
// escribiendo. Va del color del texto, que es lo que de verdad se lee encima del
// fondo en cada tema.

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('en el tema claro el cursor es del color del texto', () {
    expect(
      AppTheme.lightTheme.textSelectionTheme.cursorColor,
      AppColors.light.black,
    );
  });

  test('y en el oscuro también, que allí es casi blanco', () {
    expect(
      AppTheme.darkTheme.textSelectionTheme.cursorColor,
      AppColors.dark.black,
    );

    // La comprobación que da sentido a la anterior: los dos temas no pintan el
    // cursor del mismo color, porque «lo que se escribe encima del fondo» no es
    // lo mismo en uno que en otro.
    expect(
      AppTheme.darkTheme.textSelectionTheme.cursorColor,
      isNot(AppTheme.lightTheme.textSelectionTheme.cursorColor),
    );
  });

  testWidgets('y el campo lo coge del tema, sin pedirlo', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: const Scaffold(body: TextField()),
    ));

    final editable = tester.widget<EditableText>(find.byType(EditableText));

    expect(editable.cursorColor, AppColors.dark.black);
  });
}
