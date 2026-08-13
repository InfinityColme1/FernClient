
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

  const MediaSummaryEntity({
    required this.id,
    required this.path,
    this.isImported = false,
    this.isDeleted = false,
    this.deletedAt,
    this.importSource = ImportSource.local,
  });

  @override
  List<Object?> get props => [id, path, isImported, isDeleted, deletedAt, importSource];
}