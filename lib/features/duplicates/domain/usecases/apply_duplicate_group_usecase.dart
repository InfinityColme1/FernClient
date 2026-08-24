import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/duplicates/domain/repositories/duplicate_repository.dart';
import 'package:Fern/features/duplicates/domain/services/duplicate_merge.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/duplicates/domain/services/region_merge.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_region_entity.dart';
import 'package:Fern/features/recognition/domain/repositories/fernie_repository.dart';
import 'package:flutter/foundation.dart';

/// Qué se conserva de un grupo y qué se tira.
@immutable
class ApplyDuplicateGroupParams {
  final int groupId;
  final MediaEntity keeper;
  final List<MediaEntity> discarded;

  /// Si lo que había en las descartadas pasa a la que se queda.
  final bool mergeMetadata;

  const ApplyDuplicateGroupParams({
    required this.groupId,
    required this.keeper,
    required this.discarded,
    this.mergeMetadata = true,
  });
}

/// Resuelve un grupo de repetidos: fusiona, tira lo que sobra y lo da por visto.
///
/// El orden es lo importante y no es negociable:
///
/// 1. **Fusionar primero.** Las etiquetas, el creador y las regiones de fernies
///    que sólo tenía la copia descartada hay que recogerlos mientras la copia
///    todavía cuenta.
/// 2. **Luego a la papelera**, no borrar. `isDeleted` deja siete días de margen
///    para arrepentirse, y esta pantalla es precisamente donde más fácil es
///    equivocarse.
/// 3. **Dar el grupo por visto al final.** Si tirar las copias falla, el grupo
///    tiene que seguir apareciendo: marcarlo resuelto antes lo haría desaparecer
///    dejando los duplicados donde estaban.
class ApplyDuplicateGroupUseCase
    extends UseCase<DataState<bool>, ApplyDuplicateGroupParams> {
  final LocalMediaRepository _media;
  final DuplicateRepository _duplicates;
  final FernieRepository _fernies;

  ApplyDuplicateGroupUseCase({
    required LocalMediaRepository media,
    required DuplicateRepository duplicates,
    required FernieRepository fernies,
  })  : _media = media,
        _duplicates = duplicates,
        _fernies = fernies;

  @override
  Future<DataState<bool>> call({ApplyDuplicateGroupParams? params}) async {
    if (params == null) {
      return DataException(Exception('No se dijo qué grupo aplicar'));
    }

    if (params.mergeMetadata) {
      final merged = mergeInto(params.keeper, params.discarded);

      final saved = await _media.saveMedia(merged);
      if (saved is! DataSuccess) {
        // Sin la fusión no se sigue: tirar las copias ahora perdería justo lo
        // que se estaba intentando salvar.
        return DataException(
          saved.exception ?? Exception('No se pudo guardar la copia que queda'),
        );
      }

      await _carryRegions(params);
    }

    final ids = [for (final one in params.discarded) one.id];
    if (ids.isNotEmpty) {
      final trashed = await _media.markMediaListAsDeleted(ids);
      if (trashed is! DataSuccess) {
        return DataException(
          trashed.exception ?? Exception('No se pudo vaciar el grupo'),
        );
      }
    }

    return _duplicates.markResolved(params.groupId);
  }

  /// Lleva a la copia que se queda los fernies marcados sobre las descartadas.
  ///
  /// Que esto falle **no** para el resto. Es lo menos grave de la fusión —las
  /// regiones de las descartadas siguen donde están mientras la papelera no se
  /// vacíe, así que hay siete días para volver a intentarlo— y abortar aquí
  /// dejaría el grupo sin resolver con las etiquetas ya fusionadas, que es un
  /// estado a medias peor que perder unas marcas.
  Future<void> _carryRegions(ApplyDuplicateGroupParams params) async {
    try {
      final keeperRegions = await _regionsOf(params.keeper.id);

      final discardedRegions = <FernieRegionEntity>[];
      for (final one in params.discarded) {
        discardedRegions.addAll(await _regionsOf(one.id));
      }

      if (discardedRegions.isEmpty) return;

      final copies = regionsToCopy(
        keeperId: params.keeper.id,
        keeperRegions: keeperRegions,
        discardedRegions: discardedRegions,
      );

      if (copies.isNotEmpty) await _fernies.addRegions(copies);
    } on Object catch (error) {
      debugPrint('No se pudieron llevar las regiones de fernies: $error');
    }
  }

  Future<List<FernieRegionEntity>> _regionsOf(int mediaId) async {
    final found = await _fernies.getRegionsOfMedia(mediaId);

    return found is DataSuccess ? found.data ?? const [] : const [];
  }
}

/// Marca que un grupo no era de duplicados y no se vuelve a proponer.
///
/// Sin esto, cada escaneo automático volvería a poner delante los mismos falsos
/// positivos y el aviso del menú pasaría a ser ruido permanente.
class DismissDuplicateGroupUseCase extends UseCase<DataState<bool>, int> {
  final DuplicateRepository _duplicates;

  DismissDuplicateGroupUseCase(this._duplicates);

  @override
  Future<DataState<bool>> call({int? params}) async {
    if (params == null) {
      return DataException(Exception('No se dijo qué grupo descartar'));
    }

    return _duplicates.markDismissed(params);
  }
}
