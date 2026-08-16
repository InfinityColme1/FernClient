import 'dart:ffi';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:Fern/core/utils/media_type.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

/// Copia un contenido al portapapeles del sistema para poder pegarlo fuera de
/// la aplicación.
///
/// Se copia de las dos maneras a la vez, porque no todos los sitios donde se
/// pega entienden lo mismo:
///
/// * **El fichero** (`CF_HDROP`), que es lo que recogen el explorador, el correo
///   o las aplicaciones de mensajería. Es la única forma de copiar un vídeo:
///   un vídeo no cabe en el portapapeles como imagen.
/// * **La imagen** (`PNG` y `CF_DIB`), que es lo que recogen los editores de
///   imagen y los documentos. El PNG conserva la transparencia; el mapa de bits
///   es el formato de toda la vida, que entiende cualquiera, y ahí lo
///   transparente se compone sobre blanco (si no, sale negro).
///
/// Se habla con el sistema directamente, así que esto sólo funciona en Windows;
/// en el resto de plataformas devuelve `false` y quien llame avisa de que no se
/// ha podido copiar.
class ClipboardService {
  ClipboardService._();

  static final ClipboardService instance = ClipboardService._();

  bool get isSupported => Platform.isWindows;

  /// Copia el contenido de [path]. Devuelve `false` si no se ha podido.
  Future<bool> copyMedia(String path) async {
    if (!isSupported) return false;

    final file = File(path);
    if (!await file.exists()) return false;

    // La imagen se prepara antes de tocar el portapapeles: mientras esté
    // abierto ninguna otra aplicación puede usarlo, así que se tiene por él lo
    // menos posible.
    _ClipboardImage? image;
    if (!path.isVideoPath) {
      image = await _decodeImage(file);
    }

    return await _write(path, image);
  }

  /// Lee el fichero y lo deja listo en los dos formatos de imagen.
  ///
  /// Devuelve `null` si no es algo que se pueda pintar (un fichero roto, o un
  /// formato que la aplicación no sabe descodificar): entonces se copia sólo el
  /// fichero, que es mejor que no copiar nada.
  Future<_ClipboardImage?> _decodeImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final decoded = frame.image;

      try {
        final pixels = await decoded.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        if (pixels == null) return null;

        return _ClipboardImage(
          // Lo que se copia como PNG es el fichero tal cual cuando ya lo es. De
          // los demás formatos no se copia esta versión: volver a codificarlo
          // aquí costaría más de lo que aporta, y el mapa de bits ya cubre el
          // caso.
          png: _isPng(bytes) ? bytes : null,
          bitmap: _buildDib(
            pixels.buffer.asUint8List(),
            decoded.width,
            decoded.height,
          ),
        );
      } finally {
        decoded.dispose();
        codec.dispose();
      }
    } catch (e) {
      debugPrint('ClipboardService: no se pudo leer la imagen: $e');
      return null;
    }
  }

  /// Un PNG se reconoce por su firma, que son sus ocho primeros bytes.
  bool _isPng(Uint8List bytes) {
    const signature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    if (bytes.length < signature.length) return false;

    for (var i = 0; i < signature.length; i++) {
      if (bytes[i] != signature[i]) return false;
    }
    return true;
  }

  /// Monta el mapa de bits que espera el portapapeles: su cabecera y, detrás,
  /// los píxeles.
  ///
  /// Hay dos diferencias con lo que da Flutter: los colores van en otro orden
  /// (azul, verde, rojo) y las filas van de abajo arriba. Lo transparente se
  /// compone sobre blanco porque este formato no lleva transparencia y lo que
  /// no se compone acaba pintado de negro.
  ///
  /// Devuelve `null` si la imagen es tan grande que no compensa: pasarla al
  /// portapapeles obliga a tenerla dos veces en memoria, y para eso ya está la
  /// copia del fichero.
  Uint8List? _buildDib(Uint8List rgba, int width, int height) {
    if (width <= 0 || height <= 0) return null;
    if (width * height > _maxBitmapPixels) return null;

    const headerSize = 40;
    final pixelCount = width * height;
    final output = Uint8List(headerSize + pixelCount * 4);
    final header = ByteData.view(output.buffer, 0, headerSize);

    header.setUint32(0, headerSize, Endian.little); // biSize
    header.setInt32(4, width, Endian.little); // biWidth
    header.setInt32(8, height, Endian.little); // biHeight (de abajo arriba)
    header.setUint16(12, 1, Endian.little); // biPlanes
    header.setUint16(14, 32, Endian.little); // biBitCount
    header.setUint32(16, 0, Endian.little); // biCompression: sin comprimir
    header.setUint32(20, pixelCount * 4, Endian.little); // biSizeImage

    final rowBytes = width * 4;
    for (var y = 0; y < height; y++) {
      final source = y * rowBytes;
      final target = headerSize + (height - 1 - y) * rowBytes;

      for (var x = 0; x < rowBytes; x += 4) {
        final r = rgba[source + x];
        final g = rgba[source + x + 1];
        final b = rgba[source + x + 2];
        final a = rgba[source + x + 3];

        // Flutter da los píxeles ya multiplicados por su transparencia, así que
        // componer sobre blanco es sumarles lo que les falta para llegar a él.
        final missing = 255 - a;
        output[target + x] = b + missing;
        output[target + x + 1] = g + missing;
        output[target + x + 2] = r + missing;
        output[target + x + 3] = 255;
      }
    }

    return output;
  }

  /// Deja en el portapapeles todo lo que se haya podido preparar.
  ///
  /// El portapapeles es de uno en uno: si otra aplicación lo tiene abierto en
  /// ese momento, se reintenta un rato antes de darlo por perdido.
  Future<bool> _write(String path, _ClipboardImage? image) async {
    final window = _findWindow();

    var opened = false;
    for (var attempt = 0; attempt < _openAttempts && !opened; attempt++) {
      opened = _openClipboard(window) != 0;
      if (!opened) await Future<void>.delayed(_openRetryDelay);
    }
    if (!opened) return false;

    try {
      _emptyClipboard();

      var copied = false;
      // Primero lo más fiel: quien entienda varios formatos se queda con el
      // primero que le sirva.
      final png = image?.png;
      if (png != null) copied |= _setData(_pngFormat, png);

      final bitmap = image?.bitmap;
      if (bitmap != null) copied |= _setData(_cfDib, bitmap);

      copied |= _setData(_cfHdrop, _buildFileList(path));
      return copied;
    } catch (e) {
      debugPrint('ClipboardService: no se pudo copiar: $e');
      return false;
    } finally {
      _closeClipboard();
    }
  }

  /// La lista de ficheros que se copia, con un solo fichero dentro: una
  /// cabecera que dice dónde empieza la lista y que va en texto ancho, y detrás
  /// la ruta, terminada dos veces (una por la ruta y otra por la lista).
  Uint8List _buildFileList(String path) {
    const headerSize = 20;
    final units = path.codeUnits;
    final output = Uint8List(headerSize + (units.length + 2) * 2);
    final data = ByteData.view(output.buffer);

    data.setUint32(0, headerSize, Endian.little); // pFiles
    data.setUint32(16, 1, Endian.little); // fWide: rutas en texto ancho

    for (var i = 0; i < units.length; i++) {
      data.setUint16(headerSize + i * 2, units[i], Endian.little);
    }
    return output;
  }

  /// Pasa unos bytes al portapapeles en el formato dado.
  ///
  /// La memoria es del sistema en cuanto la acepta, así que no se libera aquí;
  /// si la rechaza, se devuelve.
  bool _setData(int format, Uint8List bytes) {
    final handle = _globalAlloc(_gmemMoveable, bytes.length);
    if (handle == nullptr) return false;

    final target = _globalLock(handle);
    if (target == nullptr) {
      _globalFree(handle);
      return false;
    }

    target.cast<Uint8>().asTypedList(bytes.length).setAll(0, bytes);
    _globalUnlock(handle);

    if (_setClipboardData(format, handle) == nullptr) {
      _globalFree(handle);
      return false;
    }
    return true;
  }

  /// La ventana de la aplicación, que es quien dice ser dueña del portapapeles.
  Pointer<Void> _findWindow() {
    final className = _windowClassName.toNativeUtf16();
    try {
      return _findWindowW(className, nullptr);
    } finally {
      calloc.free(className);
    }
  }
}

/// Un contenido listo para el portapapeles en los formatos de imagen.
class _ClipboardImage {
  final Uint8List? png;
  final Uint8List? bitmap;

  const _ClipboardImage({this.png, this.bitmap});
}

// -----------------------------------------------------------------------------
// Lo que hace falta de la API de Windows.
// -----------------------------------------------------------------------------

const _windowClassName = 'FLUTTER_RUNNER_WIN32_WINDOW';

/// Los dos formatos de siempre del portapapeles: el mapa de bits y la lista de
/// ficheros.
const _cfDib = 8;
const _cfHdrop = 15;

/// El PNG no es un formato de los de siempre: hay que pedirle al sistema el
/// número con el que lo conoce, que es el mismo para todas las aplicaciones.
final _pngFormat = () {
  final name = 'PNG'.toNativeUtf16();
  try {
    return _registerClipboardFormat(name);
  } finally {
    calloc.free(name);
  }
}();

/// Memoria que el sistema puede mover de sitio, que es como la quiere el
/// portapapeles.
const _gmemMoveable = 0x0002;

/// Cuántas veces se intenta abrir el portapapeles antes de rendirse, y lo que
/// se espera entre intento e intento.
const _openAttempts = 10;
const _openRetryDelay = Duration(milliseconds: 20);

final DynamicLibrary _user32 = DynamicLibrary.open('user32.dll');
final DynamicLibrary _kernel32 = DynamicLibrary.open('kernel32.dll');

final _findWindowW = _user32.lookupFunction<
    Pointer<Void> Function(Pointer<Utf16>, Pointer<Utf16>),
    Pointer<Void> Function(Pointer<Utf16>, Pointer<Utf16>)>('FindWindowW');

final _openClipboard = _user32.lookupFunction<Int32 Function(Pointer<Void>),
    int Function(Pointer<Void>)>('OpenClipboard');

final _closeClipboard =
    _user32.lookupFunction<Int32 Function(), int Function()>('CloseClipboard');

final _emptyClipboard =
    _user32.lookupFunction<Int32 Function(), int Function()>('EmptyClipboard');

final _setClipboardData = _user32.lookupFunction<
    Pointer<Void> Function(Uint32, Pointer<Void>),
    Pointer<Void> Function(int, Pointer<Void>)>('SetClipboardData');

final _registerClipboardFormat = _user32.lookupFunction<
    Uint32 Function(Pointer<Utf16>),
    int Function(Pointer<Utf16>)>('RegisterClipboardFormatW');

final _globalAlloc = _kernel32.lookupFunction<
    Pointer<Void> Function(Uint32, IntPtr),
    Pointer<Void> Function(int, int)>('GlobalAlloc');

final _globalLock = _kernel32.lookupFunction<
    Pointer<Void> Function(Pointer<Void>),
    Pointer<Void> Function(Pointer<Void>)>('GlobalLock');

final _globalUnlock = _kernel32.lookupFunction<Int32 Function(Pointer<Void>),
    int Function(Pointer<Void>)>('GlobalUnlock');

final _globalFree = _kernel32.lookupFunction<
    Pointer<Void> Function(Pointer<Void>),
    Pointer<Void> Function(Pointer<Void>)>('GlobalFree');

/// Tope de píxeles que se copian como mapa de bits.
const _maxBitmapPixels = 40 * 1000 * 1000;
