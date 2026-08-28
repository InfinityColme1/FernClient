import 'package:flutter/foundation.dart';

/// Qué contenidos hay que señalar y en qué pantalla.
///
/// Un aviso de «reconocimiento terminado» que sólo lleva a una pantalla deja al
/// usuario delante de una rejilla de trescientas miniaturas sin saber cuáles son
/// las de su aviso. Esto es lo que las señala.
///
/// Se apaga en cuanto el usuario **da señales de haberlo visto**: pasar el ratón
/// por encima, salir de la pantalla o abrir un contenido. Un destacado que se
/// queda puesto deja de significar «esto es nuevo» y pasa a ser decoración.
class RecognitionHighlight extends ChangeNotifier {
  String? _route;
  Set<int> _mediaIds = const {};

  /// En qué pantalla hay algo que señalar.
  String? get route => _route;

  /// Los contenidos señalados.
  Set<int> get mediaIds => _mediaIds;

  bool get isEmpty => _mediaIds.isEmpty;

  /// Si este contenido es de los del último aviso.
  bool contains(int mediaId) => _mediaIds.contains(mediaId);

  /// Señala estos contenidos en esta pantalla.
  ///
  /// Reemplaza lo anterior en vez de sumarse: lo que se señala es **el último
  /// aviso**, y acumular dos reconocimientos dejaría marcado medio catálogo sin
  /// que nada lo distinga.
  void show({required String route, required Set<int> mediaIds}) {
    if (mediaIds.isEmpty) return;

    _route = route;
    _mediaIds = Set.unmodifiable(mediaIds);
    notifyListeners();
  }

  /// Da por visto lo señalado.
  void clear() {
    if (_mediaIds.isEmpty && _route == null) return;

    _route = null;
    _mediaIds = const {};
    notifyListeners();
  }
}

/// Si un aviso de reconocimiento obliga a releer la pantalla que se está viendo.
///
/// Sin releer, el aviso salta pero la rejilla sigue siendo la de antes: los
/// distintivos no aparecen hasta que el usuario sale y vuelve, que es
/// exactamente lo que el aviso le estaba pidiendo que no hiciera falta.
///
/// Dos condiciones, y las dos importan:
///
/// - **Que sea esta pantalla.** Un reconocimiento sobre contenido definitivo
///   señala la rejilla de la biblioteca; releer también la de importación sería
///   trabajo para nada y un parpadeo sin motivo.
/// - **Que no haya nada marcado.** Releer limpia la selección, y quien está
///   marcando contenidos está trabajando: quitarle lo marcado por un aviso es
///   peor que esperar a que termine. El contador del menú sigue ahí.
/// - **Que no haya un contenido abierto.** La rejilla está debajo del visor y su
///   escucha sigue viva: releer cambia la lista que el visor está usando y le
///   tira el estado —el contenido abierto, si está sin revisar, por dónde iba—,
///   así que guardar deja de llevar al siguiente y el visor se queda a medias.
bool shouldReloadOnRecognition({
  required String? highlighted,
  required String screen,
  required bool hasSelection,
  bool isViewingMedia = false,
}) {
  return highlighted == screen && !hasSelection && !isViewingMedia;
}
