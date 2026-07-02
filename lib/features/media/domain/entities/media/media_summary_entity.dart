import 'package:equatable/equatable.dart';


class MediaSummaryEntity extends Equatable {

  final int id;
  final String path;

  const MediaSummaryEntity({
    required this.id,
    required this.path,
  });

  @override
  List<Object?> get props => [
    id,
    path
  ];


}