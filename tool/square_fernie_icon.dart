// Deja el icono de los fernies con la misma medida que los demás iconos.
//
// Los iconos de la aplicación son cuadrados (45x45 los de la barra del visor,
// 90x90 las flechas). El de los fernies llegaba a 88x77, así que aquí se centra
// en un lienzo cuadrado de 90x90 **sin reescalarlo**: los píxeles del dibujo
// salen exactamente como entraron y lo único que se añade es el hueco
// transparente que le falta para ser cuadrado.
//
// Se ejecuta a mano y su resultado se guarda en el repositorio:
//
//   dart run tool/square_fernie_icon.dart <origen.png>

import 'dart:io';

import 'package:image/image.dart' as img;

/// El lado del lienzo. El mismo que las flechas, que son los iconos de más
/// resolución que hay: así el de fernies no vuelve a quedarse corto en el
/// avatar de la ficha, que es donde más grande se pinta.
const _side = 90;

const _target = 'assets/icons/ic_fernie.png';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    stderr.writeln('Uso: dart run tool/square_fernie_icon.dart <origen.png>');
    exitCode = 64;
    return;
  }

  final source = img.decodePng(File(arguments.first).readAsBytesSync());

  if (source == null) {
    stderr.writeln('No se ha podido leer ${arguments.first}');
    exitCode = 1;
    return;
  }

  if (source.width > _side || source.height > _side) {
    stderr.writeln(
      'El origen mide ${source.width}x${source.height} y no cabe en '
      '${_side}x$_side sin reescalarlo.',
    );
    exitCode = 1;
    return;
  }

  final canvas = img.Image(
    width: _side,
    height: _side,
    numChannels: 4,
  )..clear(img.ColorRgba8(0, 0, 0, 0));

  img.compositeImage(
    canvas,
    source,
    dstX: (_side - source.width) ~/ 2,
    dstY: (_side - source.height) ~/ 2,
  );

  File(_target).writeAsBytesSync(img.encodePng(canvas));

  stdout.writeln(
    '$_target: ${source.width}x${source.height} centrado en ${_side}x$_side',
  );
}
