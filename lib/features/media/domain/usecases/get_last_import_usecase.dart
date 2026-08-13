import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';

/// Cuándo se importó por última vez de una fuente, o `null` si nunca.
///
/// Con [ImportSource.all] no se devuelve nada: "todas" no es una fuente, y un
/// único momento no diría de cuál de ellas habla.
class GetLastImportUseCase extends UseCase<DateTime?, ImportSource> {
  final PreferencesService _preferencesService;

  GetLastImportUseCase(this._preferencesService);

  @override
  Future<DateTime?> call({ImportSource? params}) async {
    final source = params ?? ImportSource.local;
    if (source == ImportSource.all) return null;

    return _preferencesService.getLastImport(source);
  }
}
