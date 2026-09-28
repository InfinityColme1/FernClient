import 'package:flutter/foundation.dart';

/// Lo último que se ha mirado en el visor.
///
/// Existe para una sola cosa: al salir del visor, la rejilla tiene que saber a
/// dónde volver. Va aparte del estado del `MediaBloc` porque ahí no sobrevive
/// —cada relectura de la pantalla arma un estado nuevo y el índice del visor se
/// queda por el camino— y lo que hace falta es justo lo contrario, algo que dure
/// más que la pantalla que lo escribió.
///
/// Es lo mismo que hace `RecognitionHighlight` para lo que hay que señalar, y
/// por el mismo motivo.
class ViewedMedia extends ChangeNotifier {
  int? _mediaId;

  /// El identificador de lo último que se miró, o `null` si aún no se ha
  /// abierto nada.
  int? get mediaId => _mediaId;

  /// Se está mirando esto.
  void see(int mediaId) {
    if (_mediaId == mediaId) return;

    _mediaId = mediaId;
    notifyListeners();
  }

  /// Si el visor está abierto encima de la rejilla.
  ///
  /// Mientras lo está, la rejilla de debajo **se queda quieta**: no se rehace
  /// con cada contenido que se pasa en el visor ni va siguiéndolo por debajo.
  /// Hacerlo era trabajo para nada —no se ve— y, sobre todo, lo que se
  /// amontonaba después de mirar cientos de contenidos seguidos: saltos,
  /// celdas montadas y miniaturas pedidas para sitios por los que sólo se
  /// pasaba. Al cerrar el visor se pone al día **una vez**, en lo último que
  /// se miró.
  bool get isViewerOpen => _isViewerOpen;
  bool _isViewerOpen = false;

  void viewerOpened() {
    if (_isViewerOpen) return;

    _isViewerOpen = true;
    notifyListeners();
  }

  void viewerClosed() {
    if (!_isViewerOpen) return;

    _isViewerOpen = false;
    notifyListeners();
  }

  /// Ya no hay a dónde volver.
  ///
  /// Lo usa quien cambia de pantalla o de lista: el contenido número mil de la
  /// biblioteca no es el número mil de los favoritos, y volver a «esa» posición
  /// en otra lista es saltar a un sitio cualquiera.
  void forget() {
    if (_mediaId == null) return;

    _mediaId = null;
    notifyListeners();
  }
}
