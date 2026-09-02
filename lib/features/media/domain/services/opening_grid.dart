import 'package:Fern/features/media/presentation/blocs/media_states.dart';

/// Qué rejilla enseña una pantalla que se acaba de abrir.
///
/// El bloc de contenido es **uno solo** y lo comparten seis pantallas, así que
/// su lista sobrevive al cambio. Sin decidir esto, la biblioteca se abría
/// enseñando lo que hubiera dejado la importación —y durante toda la
/// transición, que es cuando más se mira—.
enum OpeningGrid {
  /// La que ya estaba: es la misma pantalla. Volver del visor a la biblioteca
  /// no puede vaciarla, ni tirar la búsqueda que hubiera puesta.
  keep,

  /// La biblioteca que se guardó la última vez, que sigue valiendo tal cual.
  /// Entra en el acto: ni lectura, ni hueco, ni espera.
  restore,

  /// Ninguna: hueco de carga hasta que llegue la suya.
  clear,
}

/// Lo que hay que hacer con la rejilla al abrir [opening] estando en [shown].
OpeningGrid gridOnOpening({
  required MediaListing shown,
  required MediaListing opening,
  required bool hasFreshLibrary,
}) {
  if (shown == opening) return OpeningGrid.keep;

  if (opening == MediaListing.library && hasFreshLibrary) {
    return OpeningGrid.restore;
  }

  return OpeningGrid.clear;
}
