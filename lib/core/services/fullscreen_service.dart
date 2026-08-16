import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

/// Pantalla completa de verdad: la ventana pasa a ocupar el monitor entero y se
/// queda sin marco ni barra de título.
///
/// No es lo mismo que maximizar. Maximizada, la ventana sigue teniendo su barra
/// encima del contenido; aquí se le quita el marco y se la estira hasta los
/// bordes del monitor en el que esté, que es lo que hace que el contenido se vea
/// solo. Al salir se devuelve la ventana exactamente a donde estaba: se guarda
/// su estilo y su colocación antes de tocar nada.
///
/// Se habla con el sistema directamente (no hay ningún complemento de por
/// medio), así que esto sólo funciona en Windows. En el resto de plataformas las
/// llamadas no hacen nada y devuelven `false`, y quien llame se entera de que no
/// se ha cambiado de estado.
class FullscreenService {
  FullscreenService._();

  static final FullscreenService instance = FullscreenService._();

  /// El estilo y la colocación que tenía la ventana antes de ponerse a pantalla
  /// completa. Mientras valgan `null` es que no está a pantalla completa.
  int? _previousStyle;
  Pointer<_WindowPlacement>? _previousPlacement;

  bool get isFullscreen => _previousStyle != null;

  /// `true` si esta plataforma sabe hacerlo. Con `false`, el botón de pantalla
  /// completa no tiene sentido y no se enseña.
  bool get isSupported => Platform.isWindows;

  /// Pone o quita la pantalla completa. Devuelve cómo ha quedado.
  bool toggle() {
    if (!isFullscreen) return enter();
    exit();
    return false;
  }

  /// Devuelve `true` si la ventana ha quedado a pantalla completa.
  bool enter() {
    if (!isSupported || isFullscreen) return isFullscreen;

    final window = _findWindow();
    if (window == nullptr) return false;

    final placement = calloc<_WindowPlacement>();
    placement.ref.length = sizeOf<_WindowPlacement>();
    if (_getWindowPlacement(window, placement) == 0) {
      calloc.free(placement);
      return false;
    }

    final monitorInfo = calloc<_MonitorInfo>();
    monitorInfo.ref.cbSize = sizeOf<_MonitorInfo>();
    final monitor = _monitorFromWindow(window, _monitorDefaultToNearest);
    if (_getMonitorInfo(monitor, monitorInfo) == 0) {
      calloc
        ..free(monitorInfo)
        ..free(placement);
      return false;
    }

    final style = _getWindowLongPtr(window, _gwlStyle);
    _setWindowLongPtr(window, _gwlStyle, style & ~_wsOverlappedWindow);

    final bounds = monitorInfo.ref.rcMonitor;
    // Encima de las demás ventanas (`HWND_TOP` es cero, como el puntero vacío).
    _setWindowPos(
      window,
      nullptr,
      bounds.left,
      bounds.top,
      bounds.right - bounds.left,
      bounds.bottom - bounds.top,
      _swpNoOwnerZOrder | _swpFrameChanged,
    );

    calloc.free(monitorInfo);
    _previousStyle = style;
    _previousPlacement = placement;
    return true;
  }

  /// Devuelve la ventana a como estaba. `true` si había algo que deshacer.
  bool exit() {
    final style = _previousStyle;
    final placement = _previousPlacement;
    if (style == null || placement == null) return false;

    _previousStyle = null;
    _previousPlacement = null;

    final window = _findWindow();
    if (window == nullptr) {
      calloc.free(placement);
      return true;
    }

    _setWindowLongPtr(window, _gwlStyle, style);
    _setWindowPlacement(window, placement);
    // El marco no vuelve solo: hay que decirle a la ventana que su estilo ha
    // cambiado para que lo vuelva a dibujar.
    _setWindowPos(
      window,
      nullptr,
      0,
      0,
      0,
      0,
      _swpNoMove | _swpNoSize | _swpNoZOrder | _swpNoOwnerZOrder |
          _swpFrameChanged,
    );

    calloc.free(placement);
    return true;
  }

  /// La ventana de la aplicación, buscada por la clase con la que la registra
  /// el arranque de Windows (`windows/runner/win32_window.cpp`).
  Pointer<Void> _findWindow() {
    final className = _windowClassName.toNativeUtf16();
    try {
      return _findWindowW(className, nullptr);
    } finally {
      calloc.free(className);
    }
  }
}

// -----------------------------------------------------------------------------
// Lo que hace falta de la API de Windows.
//
// Se declara aquí lo justo para esta pantalla en lugar de traerse una librería
// entera de enlaces con el sistema: son cinco llamadas y dos estructuras.
// -----------------------------------------------------------------------------

const _windowClassName = 'FLUTTER_RUNNER_WIN32_WINDOW';

/// El índice del estilo de una ventana dentro de sus datos.
const _gwlStyle = -16;

/// Los adornos de una ventana normal: marco, barra de título y botones. Es lo
/// que se le quita para dejarla a pantalla completa.
const _wsOverlappedWindow = 0x00CF0000;

const _swpNoSize = 0x0001;
const _swpNoMove = 0x0002;
const _swpNoZOrder = 0x0004;
const _swpFrameChanged = 0x0020;
const _swpNoOwnerZOrder = 0x0200;

/// Con qué monitor se queda una ventana que no está en ninguno: el más cercano.
const _monitorDefaultToNearest = 0x00000002;

final class _Rect extends Struct {
  @Int32()
  external int left;
  @Int32()
  external int top;
  @Int32()
  external int right;
  @Int32()
  external int bottom;
}

final class _Point extends Struct {
  @Int32()
  external int x;
  @Int32()
  external int y;
}

final class _MonitorInfo extends Struct {
  @Uint32()
  external int cbSize;
  external _Rect rcMonitor;
  external _Rect rcWork;
  @Uint32()
  external int dwFlags;
}

final class _WindowPlacement extends Struct {
  @Uint32()
  external int length;
  @Uint32()
  external int flags;
  @Uint32()
  external int showCmd;
  external _Point ptMinPosition;
  external _Point ptMaxPosition;
  external _Rect rcNormalPosition;
}

final DynamicLibrary _user32 = DynamicLibrary.open('user32.dll');

final _findWindowW = _user32.lookupFunction<
    Pointer<Void> Function(Pointer<Utf16>, Pointer<Utf16>),
    Pointer<Void> Function(Pointer<Utf16>, Pointer<Utf16>)>('FindWindowW');

final _getWindowLongPtr = _user32.lookupFunction<
    IntPtr Function(Pointer<Void>, Int32),
    int Function(Pointer<Void>, int)>('GetWindowLongPtrW');

final _setWindowLongPtr = _user32.lookupFunction<
    IntPtr Function(Pointer<Void>, Int32, IntPtr),
    int Function(Pointer<Void>, int, int)>('SetWindowLongPtrW');

final _setWindowPos = _user32.lookupFunction<
    Int32 Function(Pointer<Void>, Pointer<Void>, Int32, Int32, Int32, Int32,
        Uint32),
    int Function(Pointer<Void>, Pointer<Void>, int, int, int, int,
        int)>('SetWindowPos');

final _monitorFromWindow = _user32.lookupFunction<
    Pointer<Void> Function(Pointer<Void>, Uint32),
    Pointer<Void> Function(Pointer<Void>, int)>('MonitorFromWindow');

final _getMonitorInfo = _user32.lookupFunction<
    Int32 Function(Pointer<Void>, Pointer<_MonitorInfo>),
    int Function(Pointer<Void>, Pointer<_MonitorInfo>)>('GetMonitorInfoW');

final _getWindowPlacement = _user32.lookupFunction<
    Int32 Function(Pointer<Void>, Pointer<_WindowPlacement>),
    int Function(Pointer<Void>, Pointer<_WindowPlacement>)>(
    'GetWindowPlacement');

final _setWindowPlacement = _user32.lookupFunction<
    Int32 Function(Pointer<Void>, Pointer<_WindowPlacement>),
    int Function(Pointer<Void>, Pointer<_WindowPlacement>)>(
    'SetWindowPlacement');
