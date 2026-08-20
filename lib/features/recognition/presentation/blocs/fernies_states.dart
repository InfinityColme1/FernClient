import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_media_entity.dart';
import 'package:equatable/equatable.dart';

/// Los fernies de la aplicación y, del que esté elegido, sus regiones.
///
/// Las dos cosas viven en el mismo estado porque la pantalla las enseña a la
/// vez y una depende de la otra: la rejilla es siempre la del fernie marcado en
/// la lista.
class FerniesState extends Equatable {
  final List<FernieEntity> fernies;

  /// Si ya se ha leído la base de datos. Sirve para no dar por hecho que no hay
  /// fernies mientras la primera lectura está en marcha.
  final bool isLoaded;

  /// Hay una lectura o una escritura de la lista en marcha.
  final bool isBusy;

  /// El fernie elegido, por identificador: al guardarlo cambian su nombre y su
  /// avatar, pero sigue siendo el mismo fernie.
  final int? selectedFernieId;

  /// Las regiones del fernie elegido, cada una con el contenido sobre el que
  /// está marcada. Una celda de la rejilla por región.
  final List<FernieRegionMediaEntity> regions;

  /// Hay una lectura de las regiones en marcha. Va aparte de [isBusy] porque
  /// cambiar de fernie deja la lista quieta y sólo hace esperar a la rejilla.
  final bool areRegionsBusy;

  /// Regiones marcadas en la rejilla, por identificador. Es lo que habilita el
  /// botón de borrarlas de la ficha.
  final Set<int> selectedRegionIds;

  const FerniesState({
    this.fernies = const [],
    this.isLoaded = false,
    this.isBusy = false,
    this.selectedFernieId,
    this.regions = const [],
    this.areRegionsBusy = false,
    this.selectedRegionIds = const {},
  });

  /// El fernie elegido, o `null` si no hay ninguno o el que había ha
  /// desaparecido.
  FernieEntity? get selectedFernie {
    for (final fernie in fernies) {
      if (fernie.id == selectedFernieId) return fernie;
    }
    return null;
  }

  FerniesState copyWith({
    List<FernieEntity>? fernies,
    bool? isLoaded,
    bool? isBusy,
    int? selectedFernieId,
    List<FernieRegionMediaEntity>? regions,
    bool? areRegionsBusy,
    Set<int>? selectedRegionIds,
  }) {
    return FerniesState(
      fernies: fernies ?? this.fernies,
      isLoaded: isLoaded ?? this.isLoaded,
      isBusy: isBusy ?? this.isBusy,
      selectedFernieId: selectedFernieId ?? this.selectedFernieId,
      regions: regions ?? this.regions,
      areRegionsBusy: areRegionsBusy ?? this.areRegionsBusy,
      selectedRegionIds: selectedRegionIds ?? this.selectedRegionIds,
    );
  }

  @override
  List<Object?> get props => [
        fernies,
        isLoaded,
        isBusy,
        selectedFernieId,
        regions,
        areRegionsBusy,
        selectedRegionIds,
      ];
}
