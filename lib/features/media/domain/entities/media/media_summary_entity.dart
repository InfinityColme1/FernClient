
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

  const MediaSummaryEntity({
    required this.id,
    required this.path,
    this.isImported = false,
    this.isDeleted = false,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [id, path, isImported, isDeleted, deletedAt];
}