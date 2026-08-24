import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/usecases/usecase.dart';
import 'package:Fern/features/duplicates/domain/repositories/duplicate_repository.dart';

/// Vuelve a calcular las huellas de toda la biblioteca desde cero.
///
/// Es la salida para cuando el escaneo agrupa mal y no se sabe por qué: huellas
/// calculadas por una versión anterior, ficheros que cambiaron por debajo, un
/// decodificador que entonces no entendía un formato. Borrar lo calculado es lo
/// único que garantiza que el escaneo siguiente empieza limpio.
///
/// No toca los grupos. Los que el usuario descartó son decisión suya, y
/// borrarlos aquí haría reaparecer en el escaneo siguiente todo lo que ya había
/// contestado una vez.
///
/// Sí borra **la fecha del último escaneo**. Sin eso queda una biblioteca sin una
/// sola huella y una marca diciendo que se miró hace un momento: la búsqueda
/// automática no volvería hasta que pasara el periodo entero, y quien pulsó esto
/// se quedaría sin detección de repetidos durante meses sin que nada lo dijera.
class RehashLibraryUseCase extends UseCase<DataState<int>, void> {
  final DuplicateRepository _duplicates;
  final Future<void> Function() _forgetLastScan;

  RehashLibraryUseCase(
    this._duplicates, {
    required Future<void> Function() forgetLastScan,
  }) : _forgetLastScan = forgetLastScan;

  @override
  Future<DataState<int>> call({void params}) async {
    final cleared = await _duplicates.clearHashes();
    if (cleared is! DataSuccess) return cleared;

    // Después de borrar, no antes: si el borrado falla, las huellas siguen ahí y
    // la fecha del último escaneo sigue siendo verdad.
    await _forgetLastScan();

    return cleared;
  }
}
