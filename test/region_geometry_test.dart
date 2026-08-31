// Comprueba la conversión entre el rectángulo que se arrastra en pantalla y las
// coordenadas normalizadas con las que se guarda una región.
//
// Es la prueba más importante de la fase de fernies: si esta conversión falla,
// las regiones se guardan desplazadas y el entrenamiento aprende basura, sin
// ningún síntoma visible hasta que el modelo no acierta. Por eso se comprueba
// con imágenes más anchas y más altas que el widget, con zoom y sin él.

import 'package:Fern/core/utils/region_geometry.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Margen que se admite al comparar coordenadas normalizadas: un uno por mil del
/// contenido, muy por debajo de lo que un ojo distingue en una región marcada a
/// mano.
const _tolerance = 0.001;

/// Comprueba que dos rectángulos normalizados son el mismo, lado a lado, para
/// que el fallo diga cuál de los cuatro se ha ido.
void expectRect(Rect actual, Rect expected) {
  expect(actual.left, closeTo(expected.left, _tolerance), reason: 'left');
  expect(actual.top, closeTo(expected.top, _tolerance), reason: 'top');
  expect(actual.right, closeTo(expected.right, _tolerance), reason: 'right');
  expect(actual.bottom, closeTo(expected.bottom, _tolerance), reason: 'bottom');
}

void main() {
  group('containedRect', () {
    test('una imagen cuadrada en un widget cuadrado lo llena entero', () {
      final painted = containedRect(const Size(100, 100), const Size(400, 400));

      expect(painted, const Rect.fromLTWH(0, 0, 400, 400));
    });

    test('una imagen más ancha que el widget deja banda arriba y abajo', () {
      // 200x100 dentro de 400x400: se escala x2 y ocupa 400x200, centrada.
      final painted = containedRect(const Size(200, 100), const Size(400, 400));

      expect(painted, const Rect.fromLTWH(0, 100, 400, 200));
    });

    test('una imagen más alta que el widget deja banda a los lados', () {
      final painted = containedRect(const Size(100, 200), const Size(400, 400));

      expect(painted, const Rect.fromLTWH(100, 0, 200, 400));
    });
  });

  group('widgetRectToNormalized sin zoom', () {
    test('el centro del widget se guarda alrededor de 0.5', () {
      final normalized = widgetRectToNormalized(
        const Rect.fromLTWH(150, 150, 100, 100),
        transform: Matrix4.identity(),
        widgetSize: const Size(400, 400),
        imageSize: const Size(800, 800),
      );

      expectRect(normalized, const Rect.fromLTRB(0.375, 0.375, 0.625, 0.625));
    });

    test('descuenta la banda de una imagen más ancha que el widget', () {
      // La imagen ocupa 400x200 centrada verticalmente, así que el borde
      // superior de la imagen está en y=100 del widget.
      final normalized = widgetRectToNormalized(
        const Rect.fromLTWH(0, 100, 200, 100),
        transform: Matrix4.identity(),
        widgetSize: const Size(400, 400),
        imageSize: const Size(200, 100),
      );

      expectRect(normalized, const Rect.fromLTRB(0, 0, 0.5, 0.5));
    });

    test('descuenta la banda de una imagen más alta que el widget', () {
      // La imagen ocupa 200x400 centrada horizontalmente: su borde izquierdo
      // está en x=100.
      final normalized = widgetRectToNormalized(
        const Rect.fromLTWH(100, 0, 100, 200),
        transform: Matrix4.identity(),
        widgetSize: const Size(400, 400),
        imageSize: const Size(100, 200),
      );

      expectRect(normalized, const Rect.fromLTRB(0, 0, 0.5, 0.5));
    });

    test('lo arrastrado fuera de la imagen se recorta a sus bordes', () {
      final normalized = widgetRectToNormalized(
        const Rect.fromLTWH(-200, -200, 400, 400),
        transform: Matrix4.identity(),
        widgetSize: const Size(400, 400),
        imageSize: const Size(400, 400),
      );

      expectRect(normalized, const Rect.fromLTRB(0, 0, 0.5, 0.5));
    });
  });

  group('widgetRectToNormalized con zoom', () {
    /// La misma zona física de la imagen, marcada con zoom y sin él, tiene que
    /// dar las mismas coordenadas normalizadas.
    ///
    /// Se mira con las tres formas de imagen (cuadrada, apaisada y vertical)
    /// porque cada una deja las bandas en un sitio distinto, que es donde
    /// aparecen los desplazamientos.
    for (final imageSize in const [
      Size(800, 800),
      Size(1600, 800),
      Size(800, 1600),
    ]) {
      test('zoom 4x sobre una imagen de $imageSize da lo mismo que sin zoom',
          () {
        const widgetSize = Size(400, 400);
        const sinZoom = Rect.fromLTWH(120, 140, 80, 60);

        final esperado = widgetRectToNormalized(
          sinZoom,
          transform: Matrix4.identity(),
          widgetSize: widgetSize,
          imageSize: imageSize,
        );

        // El mismo trozo de imagen visto con la escena escalada x4 y desplazada:
        // un punto de la escena acaba en `punto * 4 + traslación`.
        const escala = 4.0;
        const traslacion = Offset(-300, -420);

        final transform = Matrix4.identity()
          ..translateByDouble(traslacion.dx, traslacion.dy, 0, 1)
          ..scaleByDouble(escala, escala, escala, 1);

        final conZoom = Rect.fromLTRB(
          sinZoom.left * escala + traslacion.dx,
          sinZoom.top * escala + traslacion.dy,
          sinZoom.right * escala + traslacion.dx,
          sinZoom.bottom * escala + traslacion.dy,
        );

        final obtenido = widgetRectToNormalized(
          conZoom,
          transform: transform,
          widgetSize: widgetSize,
          imageSize: imageSize,
        );

        expectRect(obtenido, esperado);
      });
    }
  });

  group('ida y vuelta', () {
    test('normalizado -> pantalla -> normalizado devuelve lo mismo', () {
      const widgetSize = Size(640, 360);
      const imageSize = Size(1920, 1080);
      const original = Rect.fromLTRB(0.2, 0.3, 0.55, 0.8);

      final transform = Matrix4.identity()
        ..translateByDouble(-80, -35, 0, 1)
        ..scaleByDouble(2.5, 2.5, 2.5, 1);

      final enPantalla = normalizedRectToWidget(
        original,
        transform: transform,
        widgetSize: widgetSize,
        imageSize: imageSize,
      );

      final devuelta = widgetRectToNormalized(
        enPantalla,
        transform: transform,
        widgetSize: widgetSize,
        imageSize: imageSize,
      );

      expectRect(devuelta, original);
    });
  });

  group('RegionCrop', () {
    test('la proporción es la de la región, no la de sus fracciones', () {
      // Media anchura y todo el alto de una imagen 1000x500: 500x500, cuadrada.
      const crop = RegionCrop(x: 0, y: 0, w: 0.5, h: 1);

      expect(crop.aspectRatio(const Size(1000, 500)), closeTo(1, _tolerance));
    });

    test('una región degenerada no revienta la proporción', () {
      const crop = RegionCrop(x: 0, y: 0, w: 0, h: 0);

      expect(crop.aspectRatio(const Size(1000, 500)), 1);
    });
  });

  group('clampNormalized', () {
    test('deja el rectángulo dentro de la imagen', () {
      final clamped = clampNormalized(const Rect.fromLTRB(-0.5, 0.2, 1.5, 1.4));

      expectRect(clamped, const Rect.fromLTRB(0, 0.2, 1, 1));
    });

    test('endereza un rectángulo arrastrado hacia arriba y a la izquierda', () {
      // Arrastrar de abajo-derecha a arriba-izquierda da un rectángulo con los
      // lados cambiados: se devuelve con la esquina superior izquierda donde
      // toca.
      final clamped = clampNormalized(const Rect.fromLTRB(0.8, 0.9, 0.3, 0.4));

      expectRect(clamped, const Rect.fromLTRB(0.3, 0.4, 0.8, 0.9));
    });
  });

  // El cuadrado del recorte de avatar. Va en coordenadas de pantalla porque el
  // avatar es redondo: lo que se marca tiene que ser exactamente lo que se ve, y
  // en coordenadas normalizadas un cuadrado de píxeles no tiene los lados
  // iguales.
  group('squareBetween', () {
    const bounds = Rect.fromLTWH(0, 0, 400, 400);

    test('el lado lo manda el eje que más se ha movido', () {
      final square = squareBetween(
        const Offset(100, 100),
        const Offset(200, 130),
        bounds: bounds,
      );

      expectRect(square, const Rect.fromLTWH(100, 100, 100, 100));
    });

    test('y sigue al ratón hacia arriba y a la izquierda', () {
      final square = squareBetween(
        const Offset(300, 300),
        const Offset(200, 250),
        bounds: bounds,
      );

      expectRect(square, const Rect.fromLTWH(200, 200, 100, 100));
    });

    // Lo que hay que sostener: arrastrando cerca de un borde el cuadrado deja de
    // crecer en vez de salirse de la imagen, y sin deformarse.
    test('no se sale de la imagen', () {
      final square = squareBetween(
        const Offset(350, 100),
        const Offset(700, 700),
        bounds: bounds,
      );

      expectRect(square, const Rect.fromLTWH(350, 100, 50, 50));
    });

    test('ni por arriba', () {
      final square = squareBetween(
        const Offset(200, 30),
        const Offset(-100, -100),
        bounds: bounds,
      );

      expectRect(square, const Rect.fromLTWH(170, 0, 30, 30));
    });

    // Las bandas de los lados no son la imagen: empezar ahí recorta la esquina en
    // lugar de no hacer nada.
    test('empezar fuera arranca desde el borde', () {
      final square = squareBetween(
        const Offset(-40, 200),
        const Offset(100, 300),
        bounds: bounds,
      );

      expectRect(square, const Rect.fromLTWH(0, 200, 100, 100));
    });

    test('sin mover no hay cuadrado', () {
      final square = squareBetween(
        const Offset(100, 100),
        const Offset(100, 100),
        bounds: bounds,
      );

      expect(square.width, 0);
      expect(square.height, 0);
    });

    // Con bandas, el borde no es el del widget: es el de la imagen pintada
    // dentro.
    test('el borde es el de lo pintado, no el del hueco', () {
      final square = squareBetween(
        const Offset(200, 150),
        const Offset(400, 400),
        bounds: const Rect.fromLTWH(0, 100, 400, 200),
      );

      expectRect(square, const Rect.fromLTWH(200, 150, 150, 150));
    });
  });
}
