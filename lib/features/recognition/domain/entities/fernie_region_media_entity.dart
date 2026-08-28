import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:equatable/equatable.dart';

/// Una región junto con el contenido sobre el que está marcada.
///
/// Es lo que pinta la rejilla de la pantalla de fernies: cada celda es **una
/// región**, no un contenido, así que un mismo fichero con tres regiones sale
/// tres veces. Van juntos porque la celda necesita las dos cosas: el fichero
/// para leerlo y el rectángulo para recortarlo.
class FernieRegionMediaEntity extends Equatable {
  final FernieRegionEntity region;
  final MediaSummaryEntity media;

  const FernieRegionMediaEntity({required this.region, required this.media});

  @override
  List<Object?> get props => [region, media];
}
