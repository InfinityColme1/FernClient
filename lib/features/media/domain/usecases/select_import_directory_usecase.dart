import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:file_picker/file_picker.dart';

/// Elige otra carpeta del equipo y la deja puesta como la de la próxima vez.
///
/// **No escanea.** Antes lo hacía, y por eso era el único camino de importación
/// que corría fuera de la cola de trabajos: sin salir en el panel de tareas, sin
/// poder pararse desde ahí y con su propia copia de la cuenta del tope. Ahora
/// esto sólo hace lo que tiene que hacer en el hilo de la pantalla —abrir el
/// diálogo del sistema— y quien escanea es el mismo trabajo de importación que
/// para todo lo demás, sobre la carpeta que se acaba de elegir.
///
/// Devuelve la carpeta elegida, o `null` si el usuario cerró el diálogo sin
/// elegir ninguna.
class SelectImportDirectoryUsecase extends UseCase<DataState<String?>, void> {
  final PreferencesService _preferencesService;

  SelectImportDirectoryUsecase({required PreferencesService preferencesService})
      : _preferencesService = preferencesService;

  @override
  Future<DataState<String?>> call({void params}) async {
    final selected = await FilePicker.getDirectoryPath();
    if (selected == null) return const DataSuccess(null);

    // Se recuerda antes de escanear: el escaneo local va sobre la última carpeta
    // elegida, así que dejarla puesta es lo que hace que el trabajo mire donde
    // el usuario acaba de decir.
    await _preferencesService.setRootPath(selected);

    return DataSuccess(selected);
  }
}
