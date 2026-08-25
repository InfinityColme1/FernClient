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
