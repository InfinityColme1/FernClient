#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

namespace {

// El tamano con el que se abre la ventana, en pixeles logicos.
//
// Ancha a proposito: el menu lateral arranca desplegado y, por debajo de
// AppSizes.sidebarAutoCollapseMinWidth (1340), la cabecera de importacion no
// cabe con el menu abierto. Con los 1280 de antes la aplicacion nacia
// desbordando o con el menu plegado, y ninguna de las dos cosas es lo que se
// quiere ver al abrirla.
constexpr int kInitialWindowWidth = 1400;
constexpr int kInitialWindowHeight = 860;

// El tamano pedido, o lo que quepa en el escritorio.
//
// Sin esto, en un portatil de 1366x768 la ventana nace mas grande que la
// pantalla y con los botones de la barra de titulo fuera de ella. El area de
// trabajo (y no la pantalla entera) descuenta ya la barra de tareas.
// Lo pedido, acotado entre lo que quepa y el minimo que la ventana impone de
// todas formas: por debajo de kMinimumWindowWidth no se puede abrir, asi que
// tampoco tiene sentido nacer ahi.
unsigned int Clamp(int requested, int available, int minimum) {
  int fits = available < requested ? available : requested;

  return static_cast<unsigned int>(fits < minimum ? minimum : fits);
}

Win32Window::Size InitialWindowSize() {
  RECT work_area;
  if (!::SystemParametersInfoW(SPI_GETWORKAREA, 0, &work_area, 0)) {
    return Win32Window::Size(static_cast<unsigned int>(kInitialWindowWidth),
                             static_cast<unsigned int>(kInitialWindowHeight));
  }

  // El area de trabajo viene en pixeles fisicos y el tamano de la ventana se
  // pide en logicos, asi que se comparan en la misma unidad.
  double scale_factor = ::GetDpiForSystem() / 96.0;
  int available_width =
      static_cast<int>((work_area.right - work_area.left) / scale_factor);
  int available_height =
      static_cast<int>((work_area.bottom - work_area.top) / scale_factor);

  return Win32Window::Size(
      Clamp(kInitialWindowWidth, available_width, kMinimumWindowWidth),
      Clamp(kInitialWindowHeight, available_height, kMinimumWindowHeight));
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size = InitialWindowSize();
  if (!window.Create(L"FeRN", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
