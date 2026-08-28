import 'package:equatable/equatable.dart';

/// Un creador al que el usuario sigue o tiene marcado en una fuente remota.
///
/// No es un [CreatorEntity]: aquél es de la biblioteca —lo que el usuario ha
/// dado de alta aquí— y esto es lo que hay **al otro lado**, en la plataforma.
/// Los dos pueden ser la misma persona y por eso se cruzan por el nombre, pero
/// mientras no se traiga nada suyo, éste no existe en la base de datos.
class RemoteCreator extends Equatable {
  /// Con qué se le identifica dentro de la fuente. En Pawchive es el servicio y
  /// el identificador juntos, porque el mismo autor puede estar en varios.
  final String id;

  final String name;

  /// De qué plataforma de dentro de la fuente sale, cuando la fuente agrupa
  /// varias. Vacío en las que no.
  final String service;

  /// Su avatar en la plataforma. `null` si no lo tiene o no se sabe.
  final String? avatarUrl;

  /// Cuántas publicaciones ha sacado desde el último escaneo.
  ///
  /// `null` mientras no se sepa: contarlas obliga a preguntar por cada creador,
  /// así que se hace aparte y va llegando. Un cero es un cero de verdad — no ha
  /// publicado nada — y eso es información, no ausencia de ella.
  final int? newPosts;

  /// Cuándo se importó de este creador por última vez. `null` si nunca.
  ///
  /// Es lo que sabe esta máquina, así que está desde el primer momento y sin
  /// pedirle nada a nadie. Dice menos que [newPosts] —cuándo se miró, no qué ha
  /// pasado desde entonces— pero está, y algo que está siempre le gana a algo
  /// mejor que casi nunca llega.
  final DateTime? lastImport;

  /// Cuándo publicó algo por última vez, según la propia fuente. `null` si no
  /// lo dice.
  ///
  /// Viene en el mismo listado de creadores marcados, así que no cuesta ni una
  /// petición: es lo que permite decir «tiene novedades» sin preguntar por cada
  /// uno, que es lo que casi nunca llega a tiempo.
  final DateTime? updatedAt;

  /// El creador de la biblioteca con el que se ha emparejado, si hay alguno.
  ///
  /// Es lo que permite decir «a éste ya lo tienes»: sin ello, una lista de
  /// cincuenta creadores no dice cuáles son nuevos y cuáles se llevan siguiendo
  /// desde hace meses.
  final int? knownCreatorId;

  const RemoteCreator({
    required this.id,
    required this.name,
    this.service = '',
    this.avatarUrl,
    this.newPosts,
    this.lastImport,
    this.updatedAt,
    this.knownCreatorId,
  });

  bool get isKnown => knownCreatorId != null;

  /// Si ha publicado algo desde la última vez que se miró.
  ///
  /// Dos maneras de saberlo, y la buena no siempre está: [newPosts] dice cuántas
  /// y es lo que se prefiere, pero contarlas cuesta una petición por creador y
  /// del que nunca se ha importado no hay nada que contar.
  ///
  /// La otra sale de cruzar dos fechas que ya se tienen —cuándo publicó él y
  /// cuándo se miró aquí—, así que está desde el primer momento y para todos.
  /// Dice menos, pero dice lo que hace falta para elegir a quién pulsar.
  bool get hasNews {
    if (newPosts case final count?) return count > 0;

    if (updatedAt case final published?) {
      // Sin haber importado nunca no hay «desde cuándo», y eso no es «no tiene
      // novedades»: es que está sin estrenar, que la tarjeta dice aparte.
      if (lastImport case final since?) return published.isAfter(since);
    }

    return false;
  }

  RemoteCreator copyWith({
    int? newPosts,
    DateTime? lastImport,
    DateTime? updatedAt,
    int? knownCreatorId,
  }) {
    return RemoteCreator(
      id: id,
      name: name,
      service: service,
      avatarUrl: avatarUrl,
      newPosts: newPosts ?? this.newPosts,
      lastImport: lastImport ?? this.lastImport,
      updatedAt: updatedAt ?? this.updatedAt,
      knownCreatorId: knownCreatorId ?? this.knownCreatorId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        service,
        avatarUrl,
        newPosts,
        lastImport,
        updatedAt,
        knownCreatorId,
      ];
}
