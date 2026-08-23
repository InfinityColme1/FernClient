
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:equatable/equatable.dart';

class MediaSummaryEntity extends Equatable {
  final int id; // Cambiado a int no nulo
  final String path;
  final bool isImported; // Nuevo campo

  /// Marcado para borrar: no se muestra en contenido ni en importación, sólo en
  /// la pantalla de eliminados.
  final bool isDeleted;

  /// Cuándo se marcó para borrar: pasada una semana, el contenido sale solo de
  /// la base de datos. `null` en lo que no está marcado.
  final DateTime? deletedAt;

  /// De dónde ha llegado el contenido: el equipo o una plataforma remota. Es lo
  /// que filtra la rejilla de la pantalla de importación.
  ///
  /// No tiene nada que ver con la etiqueta de origen de [MediaEntity], que es un
  /// dato del contenido y lo pone quien lo revisa.
  final ImportSource importSource;

  /// Si algún modelo ha propuesto algo sobre esto y nadie lo ha contestado.
  ///
  /// Está en el sumario y no se pregunta por las sugerencias de cada celda a
  /// propósito: la rejilla de importación pinta cientos de miniaturas, y una
  /// consulta por celda para decidir si lleva un distintivo es una consulta por
  /// celda de más.
  final bool hasPendingSuggestions;

  /// Cuándo se miró por última vez con los modelos. `null` si nunca.
  ///
  /// Va junto a lo anterior porque el filtro de la pantalla de importación las
  /// necesita a las dos: «con sugerencias» y «sin mirar nunca» son dos listas
  /// distintas, y la segunda no se puede sacar de la primera.
  final DateTime? recognizedAt;

  const MediaSummaryEntity({
    required this.id,
    required this.path,
    this.isImported = false,
    this.isDeleted = false,
    this.deletedAt,
    this.importSource = ImportSource.local,
    this.hasPendingSuggestions = false,
    this.recognizedAt,
  });

  @override
  List<Object?> get props => [
        id,
        path,
        isImported,
        isDeleted,
        deletedAt,
        importSource,
        hasPendingSuggestions,
        recognizedAt,
      ];
}