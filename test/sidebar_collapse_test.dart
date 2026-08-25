// Cuándo se pliega solo el menú lateral.
//
// Importa más de lo que parece desde que la aplicación no tiene un layout de
// móvil: se dibuja igual a cualquier tamaño, y lo único que la salva de que las
// cabeceras desborden al estrechar la ventana es que el menú se quite de en
// medio a tiempo.
//
// Lo que se sostiene: que al arrancar se despliegue **siempre**, que el ancho
// mande al cruzar el umbral, y que entre umbral y umbral mande el usuario, que
// para eso hay un botón.
//
// Lo de arrancar desplegado no es un descuido: la regla de media pantalla dice
// «has puesto esta ventana al lado de otra cosa», y eso no se puede saber de una
// que acaba de abrirse. En un monitor de 4K, cualquier ventana de tamaño
// razonable ocupa menos de media pantalla, así que aplicar la regla en el primer
// fotograma dejaba la aplicación arrancando siempre plegada. Que ahí quepa
// desplegado lo garantiza el tamaño con el que nace la ventana, que se comprueba
// en `layout_breakpoints_test.dart`.

import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/navigation/sidebar_collapse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Un monitor normal: su mitad queda por debajo del ancho al que las
  /// cabeceras dejan de caber, así que manda ese ancho.
  const halfOfNormalScreen = 960.0;

  /// Y uno muy ancho, donde media pantalla es de sobra.
  const halfOfWideScreen = 1920.0;

  SidebarCollapse at(
    double width, {
    double halfScreen = halfOfNormalScreen,
    bool wasCollapsed = false,
    bool? lastVerdict,
  }) =>
      sidebarCollapse(
        width: width,
        halfScreenWidth: halfScreen,
        wasCollapsed: wasCollapsed,
        lastVerdict: lastVerdict,
      );

  group('al arrancar se despliega siempre', () {
    test('con sitio de sobra', () {
      expect(at(1600).isCollapsed, isFalse);
    });

    test('y también en una ventana estrecha', () {
      // Aunque a este ancho la regla diría que toca plegado. La ventana no nace
      // así —de eso se encarga el ejecutable— y si alguien la deja de este
      // tamaño, plegarla es cosa del botón.
      expect(at(1280).isCollapsed, isFalse);
    });

    test('y en un monitor muy ancho, que es donde más se notaba', () {
      // Media pantalla son 1920: con la regla puesta desde el primer fotograma,
      // cualquier ventana razonable arrancaba plegada.
      expect(
        at(1400, halfScreen: halfOfWideScreen).isCollapsed,
        isFalse,
      );
    });
  });

  group('después manda cruzar el umbral', () {
    test('al estrecharse por debajo, se pliega', () {
      final collapse = at(1280, wasCollapsed: false, lastVerdict: false);

      expect(collapse.isCollapsed, isTrue);
      expect(collapse.verdict, isTrue);
    });

    test('al ensancharse por encima, se despliega', () {
      final collapse = at(1600, wasCollapsed: true, lastVerdict: true);

      expect(collapse.isCollapsed, isFalse);
    });
  });

  group('entre umbral y umbral manda el botón', () {
    test('plegado a mano con sitio de sobra, se queda plegado', () {
      // Sin esto, cualquier repintado desharía lo que el usuario acaba de
      // pulsar.
      expect(at(1600, wasCollapsed: true, lastVerdict: false).isCollapsed,
          isTrue);
    });

    test('y desplegado a mano en una ventana estrecha, se queda desplegado',
        () {
      expect(at(1280, wasCollapsed: false, lastVerdict: true).isCollapsed,
          isFalse);
    });
  });

  group('el umbral', () {
    test('nunca es más tarde del ancho que necesitan las cabeceras', () {
      // En un monitor muy ancho, media pantalla son 1920: esperar a esa mitad
      // dejaría las cabeceras desbordando entre 1920 y 1340.
      expect(
        at(1500, halfScreen: halfOfWideScreen, lastVerdict: false).isCollapsed,
        isTrue,
        reason: 'con media pantalla tan ancha, el menú tiene que plegarse ya',
      );
    });

    test('y en un monitor normal es ése y no la mitad de la pantalla', () {
      expect(
        at(1400, halfScreen: halfOfNormalScreen, lastVerdict: true).isCollapsed,
        isFalse,
      );
      expect(
        at(AppSizes.sidebarAutoCollapseMinWidth, lastVerdict: false).isCollapsed,
        isTrue,
        reason: 'justo en el umbral ya toca plegado',
      );
    });
  });
}
