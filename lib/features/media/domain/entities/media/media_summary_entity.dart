
import 'package:equatable/equatable.dart';

class MediaSummaryEntity extends Equatable {
  final int id; // Cambiado a int no nulo
  final String path;
  final bool isImported; // Nuevo campo

  const MediaSummaryEntity({
    required this.id,
    required this.path,
    this.isImported = false,
  });

  @override
  List<Object?> get props => [id, path, isImported];
}