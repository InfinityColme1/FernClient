import 'package:Fern/features/media/domain/entities/tag_entity.dart';

/// Quién arrastra a quién entre dos etiquetas relacionadas.
///
/// Ser hermanas dice **que van juntas**; esto dice qué pasa al poner una. Hasta
/// ahora era siempre [both] y no se podía elegir: poner cualquiera de las dos
/// ponía la otra, que para «un personaje y su serie» está bien —la serie va con
/// el personaje— pero al revés no: poner la serie no debería poner a uno de sus
/// personajes en concreto.
enum SiblingDirection {
  /// Poner cualquiera pone la otra. Es lo que hacían todas antes de que esto se
  /// pudiera elegir, y sigue siendo lo de fábrica.
  both,

  /// Poner la etiqueta pone a la hermana, pero no al revés.
  forward,

  /// Poner a la hermana pone la etiqueta, pero no al revés.
  backward,

  /// Ninguna pone a la otra.
  ///
  /// La relación se queda: sigue saliendo en el árbol y en la cuenta de la
  /// ficha. Sirve para dejar escrito que dos etiquetas van juntas sin que eso
  /// obligue a nada — que no es lo mismo que no relacionarlas, porque entonces
  /// no quedaría constancia en ninguna parte.
  none,
}

/// Qué dirección tiene la relación entre [tag] y [sibling].
///
/// Se lee de las dos listas de silenciadas, y por eso hacen falta las dos: una
/// sola contesta media pregunta.
SiblingDirection siblingDirectionBetween({
  required TagEntity tag,
  required TagEntity sibling,
}) {
  final pulls = !tag.mutedSiblings.contains(sibling.id);
  final pulled = !sibling.mutedSiblings.contains(tag.id);

  return switch ((pulls, pulled)) {
    (true, true) => SiblingDirection.both,
    (true, false) => SiblingDirection.forward,
    (false, true) => SiblingDirection.backward,
    (false, false) => SiblingDirection.none,
  };
}

/// Si con esta dirección poner la etiqueta arrastra a la hermana.
bool pullsSibling(SiblingDirection direction) =>
    direction == SiblingDirection.both || direction == SiblingDirection.forward;

/// Si con esta dirección poner a la hermana arrastra la etiqueta.
bool isPulledBySibling(SiblingDirection direction) =>
    direction == SiblingDirection.both ||
    direction == SiblingDirection.backward;

/// La lista de silenciadas de [tag] después de poner [direction] con cada
/// hermana.
///
/// Se calcula entera y no se va tocando entrada a entrada: quien guarda escribe
/// la lista completa, y así una hermana que se quita del árbol no deja su
/// silencio detrás para cuando alguien la vuelva a relacionar.
List<int> mutedFor(Map<int, SiblingDirection> directions) => [
      for (final entry in directions.entries)
        if (!pullsSibling(entry.value)) entry.key,
    ];

/// La entrada que le toca a la hermana [siblingId] en **su** lista, para la
/// pareja con [tagId].
///
/// Es la otra mitad de [mutedFor]: guardar una dirección escribe en las dos
/// etiquetas, porque cada una lleva la suya.
bool siblingMutes(SiblingDirection direction) => !isPulledBySibling(direction);
