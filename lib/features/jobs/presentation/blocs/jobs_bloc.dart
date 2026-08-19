import 'dart:async';

import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class JobsEvents extends Equatable {
  const JobsEvents();

  @override
  List<Object?> get props => [];
}

/// La cola ha cambiado. Lo emite el propio bloc al escucharla, no la interfaz.
class JobsUpdatedEvent extends JobsEvents {
  final List<Job> jobs;

  const JobsUpdatedEvent(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

class CancelJobEvent extends JobsEvents {
  final String id;

  const CancelJobEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// El usuario da por vistos los trabajos terminados.
class ClearFinishedJobsEvent extends JobsEvents {
  const ClearFinishedJobsEvent();
}

class JobsState extends Equatable {
  final List<Job> jobs;

  const JobsState({this.jobs = const []});

  List<Job> get active =>
      jobs.where((job) => job.status.isActive).toList(growable: false);

  List<Job> get failed =>
      jobs.where((job) => job.status == JobStatus.failed).toList(growable: false);

  /// Hay algo que enseñar en la barra superior.
  bool get hasSomethingToShow => active.isNotEmpty || failed.isNotEmpty;

  @override
  List<Object?> get props => [jobs];
}

/// Lo que la interfaz sabe de los trabajos en segundo plano.
///
/// Es único y vive en el localizador de servicios por lo mismo que el de
/// ajustes: el indicador cuelga de la barra superior de la aplicación, no de una
/// pantalla, así que no puede morir al cambiar de pantalla.
class JobsBloc extends Bloc<JobsEvents, JobsState> {
  final JobQueue _queue;
  StreamSubscription<List<Job>>? _subscription;

  JobsBloc({required JobQueue queue})
      : _queue = queue,
        super(JobsState(jobs: queue.jobs)) {
    on<JobsUpdatedEvent>((event, emit) => emit(JobsState(jobs: event.jobs)));
    on<CancelJobEvent>((event, emit) => _queue.cancel(event.id));
    on<ClearFinishedJobsEvent>((event, emit) => _queue.clearFinished());

    _subscription = _queue.changes.listen((jobs) => add(JobsUpdatedEvent(jobs)));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();

    return super.close();
  }
}
