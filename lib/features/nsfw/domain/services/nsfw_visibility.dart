import 'package:Fern/features/media/data/services/nsfw_index.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';

/// Cómo se comporta el bloqueo, leído de los ajustes cada vez que se pregunta.
///
/// Llegan como funciones y no como valores para que esto no tenga que enterarse
/// de que el usuario los ha cambiado: se leen en el momento, y lo siguiente que
/// se pinte ya sale como toca.
typedef NsfwOption = bool Function();

/// La respuesta del modo NSFW a «¿esto se puede enseñar?».
///
/// Une las tres piezas: **qué** está marcado lo sabe el índice, **si** el
/// bloqueo está levantado lo sabe el modo, y **cómo** se comporta lo dicen los
/// ajustes. Ninguna sirve sola, y juntarlas en cada sitio que pregunta sería
/// repetir la condición: bastaría escribirla al revés una vez.
class NsfwVisibility extends ContentVisibility {
  final NsfwIndex _index;
  final NsfwModeService _mode;

  /// Con el bloqueo abierto, sólo se enseña lo marcado.
  final NsfwOption _showsOnlyMarked;

  /// Con el bloqueo cerrado, lo marcado se enseña tapado en vez de esconderse.
  final NsfwOption _covers;

  const NsfwVisibility({
    required NsfwIndex index,
    required NsfwModeService mode,
    NsfwOption showsOnlyMarked = _never,
    NsfwOption covers = _never,
  })  : _index = index,
        _mode = mode,
        _showsOnlyMarked = showsOnlyMarked,
        _covers = covers;

  static bool _never() => false;

  /// Sin contraseña puesta no se esconde nada, esté lo que esté marcado.
  ///
  /// Es la salvaguarda contra la única trampa que tiene todo esto: sin
  /// contraseña no hay forma de abrir el modo, así que una etiqueta marcada —de
  /// una configuración a medias, de un «quitar el bloqueo» que falló por en
  /// medio— escondería contenido para siempre y sin salida. Marcar sin
  /// contraseña simplemente no hace nada todavía, y eso se puede deshacer.
  bool get _isActive => _mode.isConfigured;

  @override
  bool hidesMedia(int mediaId) {
    if (!_isActive) return false;

    // Abierto: puede que se esté mirando **sólo** lo marcado, y entonces lo que
    // sobra es todo lo demás.
    if (_mode.isUnlocked) {
      return _showsOnlyMarked() && !_index.hasMedia(mediaId);
    }

    // Cerrado: fuera lo marcado, salvo que se haya pedido verlo tapado.
    return _index.hasMedia(mediaId) && !_covers();
  }

  /// Abrir un contenido marcado pide la contraseña, se esté enseñando tapado o
  /// no. Tapar es una forma de enseñar que existe, no un permiso para verlo.
  @override
  bool hidesDetails(int mediaId) =>
      _isActive && !_mode.isUnlocked && _index.hasMedia(mediaId);

  @override
  bool blursMedia(int mediaId) =>
      _isActive && !_mode.isUnlocked && _covers() && _index.hasMedia(mediaId);

  /// Las etiquetas marcadas se esconden con el bloqueo cerrado, tapado o no.
  ///
  /// Un nombre no se puede tapar: o se lee o no está. Y con el bloqueo abierto
  /// se enseñan todas aunque se esté mirando sólo lo marcado, porque el
  /// contenido marcado lleva puestas también etiquetas normales y esconderlas
  /// dejaría sin nombre a lo que se está viendo.
  @override
  bool hidesTag(int tagId) =>
      _isActive && !_mode.isUnlocked && _index.hasTag(tagId);

  /// La rama entera, no sólo donde el usuario puso la marca: el índice ya la
  /// resuelve al leerla.
  ///
  /// Sin mirar si el filtro está puesto ni si hay contraseña: esto no decide qué
  /// se enseña, sólo dice qué es qué. Una etiqueta marcada lo está aunque el
  /// filtro esté quitado, y es entonces cuando hay que reconocerla.
  @override
  bool marksTag(int tagId) => _index.hasTag(tagId);

  /// Los creadores marcados se esconden con el bloqueo cerrado, igual que las
  /// etiquetas y por lo mismo: un nombre no se puede tapar, o se lee o no está.
  @override
  bool hidesCreator(int creatorId) =>
      _isActive && !_mode.isUnlocked && _index.hasCreator(creatorId);

  @override
  bool marksCreator(int creatorId) => _index.hasCreator(creatorId);

  /// Los fernies marcados se esconden con el bloqueo cerrado, igual que las
  /// etiquetas y por lo mismo: un fernie es un nombre y una cara, y eso no se
  /// puede tapar a medias.
  ///
  /// El índice ya incluye los que lo están por su etiqueta enlazada, así que
  /// aquí no hay que resolver nada.
  @override
  bool hidesFernie(int fernieId) =>
      _isActive && !_mode.isUnlocked && _index.hasFernie(fernieId);

  @override
  bool marksFernie(int fernieId) => _index.hasFernie(fernieId);

  /// Igual con los modelos, y el índice ya trae también los que están
  /// escondidos porque **todos** sus fernies lo están.
  @override
  bool hidesModel(int modelId) =>
      _isActive && !_mode.isUnlocked && _index.hasModel(modelId);

  @override
  bool marksModel(int modelId) => _index.hasModel(modelId);

  /// Las direcciones marcadas se esconden con el bloqueo cerrado, como las
  /// etiquetas y los fernies, y por lo mismo: una dirección no se puede tapar a
  /// medias, o se lee o no está.
  @override
  bool get hidesMarkedLinks => _isActive && !_mode.isUnlocked;
}
