// Qué hace el visor después de guardar.
//
// El salto al siguiente existe para una cosa muy concreta: revisar una tanda
// recién importada sin volver a la rejilla entre uno y otro. Estaba puesto para
// **todo lo pendiente**, y lo pendiente también se abre desde otras pantallas
// —la de una etiqueta, la de un fernie—; allí se ha ido a *ese* contenido, y
// llevarse al usuario a otro al guardar le quita de delante justo lo que estaba
// mirando.
//
// La otra mitad de la regla es más vieja: lo pendiente no puede quedarse. Darlo
// por definitivo lo saca de la lista de la que se abrió, así que el visor se
// quedaría apuntando a un sitio que ya no es el suyo.

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/domain/services/viewer_save_action.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:flutter_test/flutter_test.dart';

ViewerSaveAction action({
  required bool isNew,
  required bool isReviewing,
  ViewerSaveBehavior behavior = ViewerSaveBehavior.goToNext,
}) =>
    viewerSaveActionFor(
      isNew: isNew,
      isReviewing: isReviewing,
      behavior: behavior,
    );

void main() {
  group('revisando lo importado', () {
    test('guardar pasa al siguiente', () {
      expect(
        action(isNew: true, isReviewing: true),
        ViewerSaveAction.goToNext,
      );
    });

    // El ajuste manda: quien lo prefiera puede seguir cerrando el visor.
    test('salvo que se haya pedido cerrar', () {
      expect(
        action(
          isNew: true,
          isReviewing: true,
          behavior: ViewerSaveBehavior.closeViewer,
        ),
        ViewerSaveAction.close,
      );
    });
  });

  group('fuera de la revisión', () {
    // Es lo que se venía haciendo mal: lo pendiente abierto desde la pantalla de
    // una etiqueta saltaba al siguiente igual que en la importación.
    test('lo pendiente se cierra, no salta', () {
      expect(
        action(isNew: true, isReviewing: false),
        ViewerSaveAction.close,
      );
    });

    test('aunque el ajuste diga «pasar al siguiente»', () {
      expect(
        action(
          isNew: true,
          isReviewing: false,
          behavior: ViewerSaveBehavior.goToNext,
        ),
        isNot(ViewerSaveAction.goToNext),
      );
    });
  });

  group('lo que ya era definitivo', () {
    // Guardarlo no lo saca de ninguna lista, así que el visor puede seguir
    // enseñándolo: es editar desde la biblioteca.
    test('se queda donde está', () {
      expect(
        action(isNew: false, isReviewing: false),
        ViewerSaveAction.stay,
      );
    });

    // Ni siquiera revisando: si ya estaba dado por bueno, guardar es sólo
    // guardar.
    test('también revisando', () {
      expect(
        action(isNew: false, isReviewing: true),
        ViewerSaveAction.stay,
      );
    });

    test('y con cualquier ajuste', () {
      for (final behavior in ViewerSaveBehavior.values) {
        expect(
          action(isNew: false, isReviewing: true, behavior: behavior),
          ViewerSaveAction.stay,
          reason: 'con $behavior',
        );
      }
    });
  });

  // La bandera llega por la dirección, y sólo la pone la pantalla de
  // importación: si el parámetro se perdiera, el salto dejaría de ocurrir en el
  // único sitio donde tiene sentido.
  group('la dirección que abre la revisión', () {
    test('lleva la marca', () {
      expect(
        viewerRouteForReview(),
        contains('$viewerReviewQueryParam=true'),
      );
    });

    test('y abre el panel, como antes', () {
      expect(
        viewerRouteForReview(),
        contains('$viewerInfoQueryParam=true'),
      );
    });

    // Abrir el panel y saltar al siguiente son dos cosas distintas: atarlas
    // haría que abrir el panel desde cualquier otro sitio arrastrara el salto.
    test('abrir el panel a secas no la lleva', () {
      expect(
        viewerRouteWithInfo(true),
        isNot(contains(viewerReviewQueryParam)),
      );
    });

    test('ni la de resaltar una región', () {
      expect(
        viewerRouteWithHighlight(42),
        isNot(contains(viewerReviewQueryParam)),
      );
    });
  });
}
