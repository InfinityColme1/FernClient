import 'dart:math' as math;

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// El logotipo de la aplicación: la marca y el nombre.
///
/// **Por qué se dibuja y no se carga.** El logotipo era un fichero de 85 KB de
/// los que 67 eran un PNG incrustado dentro de un `<pattern>` de SVG —el bastón—
/// que Flutter no sabe pintar: por eso desaparecía y dejaba el hueco. Y el
/// nombre iba en un violeta escrito a mano, `#6100ED`, que no sale de la paleta:
/// con el tema oscuro o con uno propio, el logotipo era el único sitio de la
/// aplicación que no se enteraba.
///
/// Dibujado, las tres cosas se arreglan solas: se pinta nítido a cualquier
/// tamaño, sigue al tema —y a la paleta que se haya montado el usuario— y no pesa
/// nada.
///
/// **Qué es la marca.** Un bastón cuyo remate se desenrolla en un báculo de
/// helecho. Es donde se cruzan las dos cosas que dan nombre a esto: el bastón de
/// Fern, que es lo que lleva en la mano, y el helecho —*fern*—, cuyo brote nace
/// justamente así, enrollado sobre sí mismo y abriéndose. En la punta del rizo
/// va el color con el que la aplicación llama la atención, que hace de gema del
/// bastón.
///
/// Está trazada con el mismo grosor y los mismos remates redondeados que los
/// iconos, así que no es un cuerpo extraño en la pantalla.
class FernLogo extends StatelessWidget {
  /// Lo alto que se pinta. Lo demás sale de aquí.
  final double height;

  /// Sin el nombre, sólo la marca.
  final bool isMarkOnly;

  const FernLogo({super.key, required this.height}) : isMarkOnly = false;

  const FernLogo.mark({super.key, required this.height}) : isMarkOnly = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final markHeight = height * logoMarkHeightRatio;

    final mark = SizedBox(
      width: markHeight * logoMarkAspect,
      height: markHeight,
      child: CustomPaint(
        painter: _FernMarkPainter(
          stroke: colors.black,
          accent: colors.terciary,
        ),
      ),
    );

    if (isMarkOnly) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Subida lo justo para cuadrar con las mayusculas del nombre: ver
        // [logoOpticalLift].
        Transform.translate(
          offset: Offset(0, -height * logoOpticalLift),
          child: mark,
        ),
        SizedBox(width: height * logoGapRatio),
        // El nombre va con la tipografía de la aplicación y no dibujado: así es
        // el mismo texto que todo lo demás, se pinta nítido a cualquier escala y
        // no hay dos sitios donde arreglar una letra.
        //
        // La `e` en minúscula entre mayúsculas es la firma: no se toca.
        Text(
          appName,
          style: TextStyle(
            color: colors.black,
            fontSize: height * logoTextRatio,
            fontWeight: FontWeight.w600,
            letterSpacing: -height * logoTrackingRatio,
            height: 1,
          ),
        ),
      ],
    );
  }
}

/// La marca: el bastón y su rizo.
class _FernMarkPainter extends CustomPainter {
  final Color stroke;
  final Color accent;

  const _FernMarkPainter({required this.stroke, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    // Se dibuja sobre una retícula fija y se escala: así las proporciones son
    // las mismas a cualquier tamaño y los números de aquí significan algo.
    final scale = size.height / logoMarkGridHeight;
    canvas.save();
    canvas.scale(scale);

    final trazo = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = logoStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final espiral = fernFiddleheadPoints();

    final path = Path()
      // El bastón, recto de abajo arriba.
      ..moveTo(logoStaffX, logoMarkGridHeight - logoStrokeWidth)
      ..lineTo(logoStaffX, logoStaffTopY);

    // Y el enlace hasta donde empieza el rizo, entrando con la misma tangente
    // con la que sale el bastón: sin esto se vería el codo del empalme.
    final entrada = espiral.first;
    path.cubicTo(
      logoStaffX,
      logoStaffTopY - logoJoinReach,
      entrada.dx,
      entrada.dy + logoJoinReach,
      entrada.dx,
      entrada.dy,
    );

    for (final punto in espiral.skip(1)) {
      path.lineTo(punto.dx, punto.dy);
    }

    canvas.drawPath(path, trazo);

    // La gema del bastón, en el centro del rizo.
    canvas.drawCircle(
      espiral.last,
      logoGemRadius,
      Paint()..color = accent,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_FernMarkPainter old) =>
      old.stroke != stroke || old.accent != accent;
}

/// Los puntos del rizo, de fuera hacia dentro.
///
/// Es una espiral logarítmica, que es la que traza un brote de helecho al
/// abrirse: el radio se reduce en la misma proporción a cada vuelta, y por eso
/// se lee como algo que crece y no como una caracola dibujada a mano.
///
/// Va aparte y sin nada de pintura para poder comprobarla: que no se salga de su
/// caja y que el radio no deje de encoger en ningún punto son dos cosas que se
/// ven en cuanto fallan y no se pueden mirar en un `CustomPainter`.
List<Offset> fernFiddleheadPoints() {
  const centro = Offset(logoCoilCentreX, logoCoilCentreY);

  // Cuánto se encoge por radián, para que del principio al final el radio se
  // divida entre [logoCoilShrink].
  final k = math.log(logoCoilShrink) / logoCoilSweep;

  return [
    for (var i = 0; i <= logoCoilSteps; i++)
      () {
        final t = logoCoilSweep * i / logoCoilSteps;
        final r = logoCoilRadius * math.exp(-k * t);
        final angulo = logoCoilStartAngle + t;

        return Offset(
          centro.dx + r * math.cos(angulo),
          centro.dy + r * math.sin(angulo),
        );
      }(),
  ];
}
