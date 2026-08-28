// El escaneo de repetidos que la aplicación lanza sola al arrancar.
//
// Lo que se comprueba es lo que decide encolar: que respete el interruptor y el
// periodo, que entre con la prioridad baja —no la del botón, que es lo que el
// usuario está mirando— y que no encole un segundo trabajo si ya hay uno, que
// sería hashear la biblioteca entera dos veces.

import 'dart:async';

import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/features/duplicates/data/services/automatic_duplicate_scan.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 8, 24, 12);

  late JobQueue jobs;

  setUp(() {
    jobs = JobQueue();
    // Sin nadie que sepa hacerlo, la cola cerraría el trabajo como fallido en
    // cuanto le tocara el turno y la lista de activos quedaría vacía. Con un
    // ejecutor que no termina nunca, lo encolado se queda donde se puede mirar.
    jobs.register(JobType.duplicateScan, (context) => Completer<void>().future);
  });

  tearDown(() => jobs.dispose());

  AutomaticDuplicateScan scanner({
    bool enabled = true,
    DuplicateScanPeriod period = DuplicateScanPeriod.quarterly,
    DateTime? lastScan,
  }) {
    return AutomaticDuplicateScan(
      jobs: jobs,
      settings: () => AppSettingsEntity(
        avatarsPath: '/avatars',
        recognitionPath: '/recognition',
        automaticDuplicateScan: enabled,
        duplicateScanPeriod: period,
      ),
      lastScan: () => lastScan,
      now: () => now,
    );
  }

  List<Job> duplicateJobs() =>
      jobs.jobs.where((job) => job.type == JobType.duplicateScan).toList();

  test('apagado no encola nada', () {
    expect(scanner(enabled: false).runIfDue(), isFalse);
    expect(duplicateJobs(), isEmpty);
  });

  test('no encola si no se ha cumplido el periodo', () {
    final recent = now.subtract(const Duration(days: 10));

    expect(scanner(lastScan: recent).runIfDue(), isFalse);
    expect(duplicateJobs(), isEmpty);
  });

  test('encola cuando toca', () {
    final old = now.subtract(const Duration(days: 200));

    expect(scanner(lastScan: old).runIfDue(), isTrue);
    expect(duplicateJobs(), hasLength(1));
  });

  // Lo que separa el escaneo automático del botón: no puede estorbar. Con
  // prioridad normal se pondría por delante de lo que el usuario haya pedido.
  test('entra con prioridad baja, no con la del botón', () {
    scanner().runIfDue();

    expect(duplicateJobs().single.priority, JobPriority.low);
  });

  test('no encola un segundo si ya hay uno esperando', () {
    final automatic = scanner();

    expect(automatic.runIfDue(), isTrue);
    expect(automatic.runIfDue(), isFalse);
    expect(duplicateJobs(), hasLength(1));
  });
}
