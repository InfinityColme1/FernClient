import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:flutter/rendering.dart';

/// Qué imagen se recorta y por dónde, normalizado de 0 a 1.
typedef AvatarCrop = ({String path, Rect rect});

/// Se queda con **un trozo** de una imagen como avatar y devuelve dónde ha
/// quedado.
///
/// Es el hermano de [StoreAvatarUseCase] para lo que se marca en el visor: allí
/// no se elige un fichero, se elige un cuadrado de lo que se está mirando, y el
/// fichero con ese cuadrado dentro hay que escribirlo.
class CropAvatarUseCase extends UseCase<String, AvatarCrop> {
  final AvatarStorageService _storage;

  CropAvatarUseCase({required AvatarStorageService storage})
      : _storage = storage;

  @override
  Future<String> call({AvatarCrop? params}) async {
    if (params == null || params.path.isEmpty) return '';

    return _storage.storeCrop(params.path, params.rect);
  }
}
