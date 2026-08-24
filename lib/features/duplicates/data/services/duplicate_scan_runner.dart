import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/job_runner.dart';
import 'package:Fern/features/duplicates/data/services/duplicate_scanner.dart';
import 'package:Fern/features/duplicates/domain/repositories/duplicate_repository.dart';
import 'package:Fern/features/duplicates/domain/services/duplicate_grouping.dart';
import 'package:Fern/features/duplicates/domain/services/group_reconciliation.dart';
import 'package:Fern/features/duplicates/domain/services/hashing_plan.dart';
import 'package:flutter/foundation.dart';

/// Con qué listón se agrupa, leído en el momento de escanear.
typedef ThresholdSetting = int Function();

/// Si hay que mirar también lo que se mueve: vídeos y GIF.
typedef MovingSetting = bool Function();

/// A quién avisar de que han aparecido grupos nuevos.
typedef DuplicatesNotifier = Future<void> Function(int freshGroups);

/// Dónde queda anotado que se acaba de escanear.
typedef ScanStamp = Future<void> Function();

/// Quién agrupa, para poder probar el runner sin levantar otro hilo.
typedef Grouper = Future<List<DuplicateGroup>> Function(GroupingRequest request);

/// Busca contenido repetido: hashea lo que falta y agrupa lo que se parece.
///
/// Las dos mitades van en el mismo trabajo porque son inseparables desde fuera:
/// el usuario pide «buscar repetidos» y lo que espera es la lista, no que se le
/// diga que ya están las huellas calculadas. Por dentro sí lo son —hashear cuesta
/// horas la primera vez y agrupar es un momento—, y por eso el avance cuenta el
/// hasheo, que es lo que de verdad tarda.
class DuplicateScanRunner {
  final DuplicateRepository _repository;
  final DuplicateScanner _scanner;
  final ThresholdSetting _threshold;
  final MovingSetting _includesMoving;
  final DuplicatesNotifier? _notify;
  final ScanStamp? _stamp;
  final Grouper _groupOffThread;

  DuplicateScanRunner({
    required DuplicateRepository repository,
    required DuplicateScanner scanner,
    ThresholdSetting? threshold,
    MovingSetting? includesMoving,
    DuplicatesNotifier? notify,
    ScanStamp? stamp,
    Grouper? grouper,
  })  : _repository = repository,
        _scanner = scanner,
        _threshold = threshold ?? _defaultThreshold,
        _includesMoving = includesMoving ?? _alwaysIncludesMoving,
        _notify = notify,
        _stamp = stamp,
        _groupOffThread = grouper ?? groupInIsolate;

  static int _defaultThreshold() => defaultDuplicateThreshold;

  static bool _alwaysIncludesMoving() => true;

  /// Lo que la cola llama.
  Future<void> call(JobContext context) => run(context);

  Future<void> run(JobContext context) async {
    // El listón se lee una vez por escaneo. Cambiarlo a media faena dejaría medio
    // catálogo agrupado con un criterio y medio con otro.
    final threshold = _threshold();

    final hashable = await _repository.getHashable();
    if (hashable is! DataSuccess || hashable.data == null) {
      debugPrint('No se pudo leer la biblioteca: ${hashable.exception}');
      return;
    }

    // Y lo mismo con lo que se mueve: se decide al empezar. Lo que ya tenga
    // huella la conserva y se sigue comparando; esto sólo dice qué se mira
    // ahora.
    final wanted = _includesMoving()
        ? hashable.data!
        : withoutMoving(hashable.data!);

    await _scanner.hashPending(
      wanted,
      token: context.token,
      onProgress: (done, total) => context.report(done, total: total),
    );

    context.token.throwIfCancelled();

    final grouped = await _group(threshold);
    if (grouped == null) return;

    // Se retiran los grupos que este escaneo ya no ha visto, pero sólo si había
    // huellas que comparar: sin ninguna, «no he encontrado nada» no dice que no
    // haya nada, y tirar lo pendiente por eso borraría trabajo por hacer.
    final fresh = await _repository.saveGroups(
      grouped.groups,
      retireUnseen: grouped.compared,
    );
    final count = fresh is DataSuccess ? fresh.data ?? 0 : 0;

    // Se sella aquí y no en quien encoló el trabajo: lo que cuenta para no
    // repetirlo es cuándo se miró de verdad, y un escaneo cancelado a la mitad
    // no ha mirado nada. Lo hace también el escaneo a mano, porque desde el
    // punto de vista de «cuándo toca» los dos son el mismo trabajo.
    await _stampScan();

    // Sólo si hay algo nuevo. Avisar de que «ya está» cuando no ha aparecido
    // ningún grupo manda al usuario a una pantalla donde no hay nada que hacer, y
    // un aviso que no lleva a ninguna parte deja de mirarse.
    if (count > 0) await _notifyFound(count);
  }

  /// Agrupa lo hasheado y lo cruza con lo que ya se sabía.
  ///
  /// Agrupar va en **otro hilo**: comparar cada contenido con todos los demás
  /// crece con el cuadrado de la biblioteca, y hacerlo aquí deja la aplicación
  /// congelada seis segundos con veinte mil contenidos y medio minuto con
  /// cincuenta mil. Justo lo que el escaneo de fondo promete que no va a pasar.
  Future<({List<ReconciledGroup> groups, bool compared})?> _group(
    int threshold,
  ) async {
    final hashed = await _repository.getHashed();
    if (hashed is! DataSuccess || hashed.data == null) {
      debugPrint('No se pudieron leer las huellas: ${hashed.exception}');
      return null;
    }

    final known = await _repository.getKnownGroups();

    final found = await _groupOffThread(
      GroupingRequest(media: hashed.data!, threshold: threshold),
    );

    return (
      groups: reconcileGroups(
        found,
        known is DataSuccess ? known.data ?? const [] : const [],
      ),
      compared: hashed.data!.isNotEmpty,
    );
  }

  /// Que la marca falle no puede tirar abajo un escaneo ya guardado: lo peor
  /// que pasa entonces es que se vuelva a escanear antes de tiempo.
  Future<void> _stampScan() async {
    try {
      await _stamp?.call();
    } on Object catch (error) {
      debugPrint('No se pudo anotar la fecha del escaneo: $error');
    }
  }

  /// Que el aviso falle no puede tirar abajo un escaneo ya guardado.
  Future<void> _notifyFound(int count) async {
    try {
      await _notify?.call(count);
    } on Object catch (error) {
      debugPrint('No se pudo avisar del contenido repetido: $error');
    }
  }
}
