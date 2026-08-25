import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';

/// Se queda con una imagen como avatar y devuelve dónde ha quedado.
///
/// Existe para que las fichas —de etiqueta, de creador, de fernie, de modelo—
/// no llamen al servicio que escribe en disco. Elegir una imagen es cosa de la
/// pantalla; copiarla a la carpeta de avatares, decidir el nombre y qué hacer
/// si el fichero ya no está, no lo es.
///
/// Está en los ajustes porque de ellos sale la carpeta de avatares, que es lo
/// único configurable de todo esto.
///
/// Devuelve la ruta que hay que guardar en la base de datos. Si la copia no se
/// puede hacer devuelve la de partida: es mejor un avatar que apunta al fichero
/// del usuario que ningún avatar.
class StoreAvatarUseCase extends UseCase<String, String> {
  final AvatarStorageService _storage;

  StoreAvatarUseCase({required AvatarStorageService storage})
      : _storage = storage;

  @override
  Future<String> call({String? params}) async {
    final path = params;
    if (path == null || path.isEmpty) return '';

    return _storage.store(path);
  }
}
