import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/remote_creator.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/domain/repositories/remote_media_repository.dart';

/// Los creadores que el usuario sigue o tiene marcados en una fuente remota, ya
/// cruzados con los de la biblioteca.
///
/// El cruce es la mitad del valor de la lista: sin él, cincuenta tarjetas no
/// dicen cuáles son gente que ya se sigue desde hace meses y cuáles son un
/// hallazgo. Se cruza **por el nombre** porque es lo único que las dos partes
/// comparten: aquí no se guarda el identificador que tenía en la plataforma.
class GetRemoteCreatorsUseCase
    extends UseCase<DataState<List<RemoteCreator>>, ImportSource> {
  final RemoteMediaRepository _remote;
  final LocalMediaRepository _creators;

  GetRemoteCreatorsUseCase({
    required RemoteMediaRepository remote,
    required LocalMediaRepository creators,
  })  : _remote = remote,
        _creators = creators;

  @override
  Future<DataState<List<RemoteCreator>>> call({ImportSource? params}) async {
    final source = params ?? ImportSource.all;

    final found = await _remote.remoteCreators(source);
    if (found is! DataSuccess || found.data == null) return found;

    final known = await _creators.getCreators();
    if (known is! DataSuccess || known.data == null) return found;

    final byName = {
      for (final creator in known.data!) creator.name.toLowerCase().trim(): creator.id,
    };

    return DataSuccess([
      for (final creator in found.data!)
        creator.copyWith(
          knownCreatorId: byName[creator.name.toLowerCase().trim()],
        ),
    ]);
  }
}

/// Cuenta las publicaciones nuevas de cada creador y las va soltando.
///
/// Aparte de la lista a propósito: contar es **una petición por creador**, y con
/// cincuenta marcados hacerlas antes de enseñar nada dejaría la pantalla en
/// blanco medio minuto. La lista sale enseguida sin números y éstos van cayendo.
///
/// De [remoteCreatorCountConcurrency] en adelante no se piden más a la vez: con
/// cincuenta de golpe el sitio corta.
class CountRemoteCreatorPostsUseCase {
  final RemoteMediaRepository _remote;

  CountRemoteCreatorPostsUseCase({required RemoteMediaRepository remote})
      : _remote = remote;

  /// Va soltando cada creador con su cuenta puesta, según se sabe.
  Stream<RemoteCreator> call(
    ImportSource source,
    List<RemoteCreator> creators,
  ) async* {
    for (var from = 0;
        from < creators.length;
        from += remoteCreatorCountConcurrency) {
      final to = (from + remoteCreatorCountConcurrency).clamp(0, creators.length);
      final batch = creators.sublist(from, to);

      final counts = await Future.wait([
        for (final creator in batch) _remote.countNewPosts(source, creator),
      ]);

      for (var index = 0; index < batch.length; index++) {
        final count = counts[index];
        if (count == null) continue;

        yield batch[index].copyWith(newPosts: count);
      }
    }
  }
}
