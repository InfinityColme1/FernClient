import 'dart:async';

import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/features/duplicates/data/services/duplicate_details_loader.dart';
import 'package:Fern/features/duplicates/domain/repositories/duplicate_repository.dart';
import 'package:Fern/features/duplicates/domain/services/duplicate_detail.dart';
import 'package:Fern/features/duplicates/domain/usecases/apply_duplicate_group_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class DuplicatesEvent extends Equatable {
  const DuplicatesEvent();

  @override
  List<Object?> get props => const [];
}

/// Lee lo que haya guardado de escaneos anteriores.
class LoadDuplicatesEvent extends DuplicatesEvent {
  const LoadDuplicatesEvent();
}

/// Manda a buscar repetidos ahora mismo.
class ScanForDuplicatesEvent extends DuplicatesEvent {
  const ScanForDuplicatesEvent();
}

/// La cola ha cambiado: puede que el escaneo haya terminado.
class DuplicateJobsChangedEvent extends DuplicatesEvent {
  final List<Job> jobs;

  const DuplicateJobsChangedEvent(this.jobs);

  @override
  List<Object?> get props => [jobs];
}

/// Abre un grupo para compararlo.
class SelectDuplicateGroupEvent extends DuplicatesEvent {
  final int groupId;

  const SelectDuplicateGroupEvent(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

/// Cambia cuál es la copia que se conserva.
class ChooseDuplicateKeeperEvent extends DuplicatesEvent {
  final int mediaId;

  const ChooseDuplicateKeeperEvent(this.mediaId);

  @override
  List<Object?> get props => [mediaId];
}

/// Enciende o apaga la fusión de metadatos.
class ToggleDuplicateMergeEvent extends DuplicatesEvent {
  final bool merge;

  const ToggleDuplicateMergeEvent(this.merge);

  @override
  List<Object?> get props => [merge];
}

/// Conserva la copia elegida y manda las demás a la papelera.
class ApplyDuplicateGroupEvent extends DuplicatesEvent {
  const ApplyDuplicateGroupEvent();
}

/// Dice que este grupo no era de duplicados.
class DismissCurrentGroupEvent extends DuplicatesEvent {
  const DismissCurrentGroupEvent();
}

/// En qué ha quedado el escaneo que pidió el usuario.
///
/// Existe porque un escaneo que no encuentra nada es indistinguible de uno que
/// no ha corrido: la pantalla se queda exactamente igual que estaba. Lo que hay
/// que anunciar no es que ha terminado, sino en qué ha quedado.
enum DuplicateScanOutcome {
  /// Han aparecido grupos que antes no estaban.
  found,

  /// Ha mirado y no hay nada nuevo, pero queda cosa de antes por revisar.
  nothingNew,

  /// Ha mirado y la biblioteca no tiene repetidos.
  clean,

  /// Se paró antes de terminar.
  cancelled,

  /// No pudo terminar.
  failed,
}

/// Cuándo se miró la biblioteca por última vez, para poder decirlo.
typedef LastScanReader = DateTime? Function();

class DuplicatesState extends Equatable {
  final List<DuplicateGroupSummary> groups;

  /// Hay un escaneo en marcha o esperando turno.
  final bool isScanning;

  /// Ese escaneo lo pidió el usuario, no la aplicación por su cuenta.
  ///
  /// Es lo que separa los dos: el de fondo no puede quedarse con el botón ni
  /// sacar avisos, porque nadie lo ha pedido ni lo está esperando.
  final bool isUserScan;

  /// Cuántas veces se ha pulsado buscar. La pantalla avisa cuando cambia.
  ///
  /// Un contador y no un booleano: lo que hay que anunciar es la pulsación, y con
  /// un estado transitorio el aviso salía también cuando arrancaba el escaneo de
  /// fondo, que tiene que ser callado.
  final int scanRequests;

  /// Cuántos escaneos pedidos por el usuario han terminado. La pantalla dice
  /// en qué ha quedado cada vez que cambia.
  ///
  /// Va aparte de [outcome] por lo mismo que [scanRequests] es un contador:
  /// dos escaneos seguidos pueden acabar igual, y con sólo el resultado el
  /// segundo no se anunciaría.
  final int scanResults;

  /// En qué quedó el último escaneo pedido con el botón.
  final DuplicateScanOutcome? outcome;

  /// Cuántos grupos ha traído ese escaneo que no estuvieran ya.
  final int freshGroups;

  /// Por dónde va el escaneo del usuario: huellas calculadas y cuántas hay.
  ///
  /// La cola ya lo enseña en la barra de arriba, pero ahí dura lo que dure el
  /// trabajo y desaparece al acabar. Quien acaba de pulsar el botón está
  /// mirando **esta** pantalla, y es aquí donde tiene que ver que pasa algo.
  final int scanDone;
  final int scanTotal;

  /// Cuándo terminó el último escaneo, sea de quien sea, o `null` si no se ha
  /// escaneado nunca. Es lo que separa «no tienes repetidos» de «nadie ha
  /// mirado todavía».
  final DateTime? lastScan;

  /// Todavía no se ha leído nada: no es lo mismo que «no hay repetidos».
  final bool isLoading;

  /// El grupo abierto en la comparación.
  final int? selectedGroupId;

  /// Las copias del grupo abierto, con lo que hace falta para elegir.
  final List<DuplicateCopy> copies;

  /// La copia marcada para conservar.
  final int? keeperId;

  /// Si lo de las descartadas pasa a la que se queda.
  final bool mergeMetadata;

  /// Se están leyendo las copias del grupo.
  final bool isLoadingGroup;

  /// Se está resolviendo el grupo: los botones no aceptan otra pulsación.
  final bool isApplying;

  const DuplicatesState({
    this.groups = const [],
    this.isScanning = false,
    this.isUserScan = false,
    this.scanRequests = 0,
    this.scanResults = 0,
    this.outcome,
    this.freshGroups = 0,
    this.scanDone = 0,
    this.scanTotal = 0,
    this.lastScan,
    this.isLoading = true,
    this.selectedGroupId,
    this.copies = const [],
    this.keeperId,
    this.mergeMetadata = true,
    this.isLoadingGroup = false,
    this.isApplying = false,
  });

  /// El grupo abierto, si sigue en la lista.
  DuplicateGroupSummary? get selectedGroup {
    for (final group in groups) {
      if (group.id == selectedGroupId) return group;
    }

    return null;
  }

  /// Qué número de grupo es, para situarse al revisarlos en fila.
  int get selectedPosition {
    for (var index = 0; index < groups.length; index++) {
      if (groups[index].id == selectedGroupId) return index + 1;
    }

    return 0;
  }

  /// De 0 a 1 lo que lleva hecho el escaneo, o `null` mientras no se sepa
  /// cuánto hay que mirar: es la diferencia entre una barra que avanza y una
  /// que miente con un porcentaje inventado.
  double? get scanProgress {
    if (scanTotal <= 0) return null;

    return (scanDone / scanTotal).clamp(0.0, 1.0);
  }

  /// Si se puede resolver el grupo ahora mismo.
  ///
  /// Hace falta haber elegido copia: sin ella, aplicar mandaría el grupo entero
  /// a la papelera.
  bool get canApply =>
      !isApplying && !isLoadingGroup && keeperId != null && copies.length > 1;

  /// Si se puede pedir un escaneo ahora mismo.
  ///
  /// El de fondo **no** lo impide: puede tardar horas la primera vez, y dejar el
  /// botón muerto todo ese rato es dejar sin salida a quien acaba de importar y
  /// quiere mirar ya. Pedirlo cancela el de fondo y lo relanza con prisa, que no
  /// pierde nada: las huellas ya calculadas se quedan calculadas.
  bool get canScan => !isUserScan;

  DuplicatesState copyWith({
    List<DuplicateGroupSummary>? groups,
    bool? isScanning,
    bool? isUserScan,
    int? scanRequests,
    int? scanResults,
    DuplicateScanOutcome? outcome,
    int? freshGroups,
    int? scanDone,
    int? scanTotal,
    DateTime? lastScan,
    bool? isLoading,
    Object? selectedGroupId = _keep,
    List<DuplicateCopy>? copies,
    Object? keeperId = _keep,
    bool? mergeMetadata,
    bool? isLoadingGroup,
    bool? isApplying,
  }) {
    return DuplicatesState(
      groups: groups ?? this.groups,
      isScanning: isScanning ?? this.isScanning,
      isUserScan: isUserScan ?? this.isUserScan,
      scanRequests: scanRequests ?? this.scanRequests,
      scanResults: scanResults ?? this.scanResults,
      outcome: outcome ?? this.outcome,
      freshGroups: freshGroups ?? this.freshGroups,
      scanDone: scanDone ?? this.scanDone,
      scanTotal: scanTotal ?? this.scanTotal,
      lastScan: lastScan ?? this.lastScan,
      isLoading: isLoading ?? this.isLoading,
      selectedGroupId: selectedGroupId == _keep
          ? this.selectedGroupId
          : selectedGroupId as int?,
      copies: copies ?? this.copies,
      keeperId: keeperId == _keep ? this.keeperId : keeperId as int?,
      mergeMetadata: mergeMetadata ?? this.mergeMetadata,
      isLoadingGroup: isLoadingGroup ?? this.isLoadingGroup,
      isApplying: isApplying ?? this.isApplying,
    );
  }

  @override
  List<Object?> get props => [
        groups,
        isScanning,
        isUserScan,
        scanRequests,
        scanResults,
        outcome,
        freshGroups,
        scanDone,
        scanTotal,
        lastScan,
        isLoading,
        selectedGroupId,
        copies,
        keeperId,
        mergeMetadata,
        isLoadingGroup,
        isApplying,
      ];
}

/// Marca de «este campo no se toca» en [DuplicatesState.copyWith].
///
/// Hace falta porque dos de los campos son opcionales de verdad: cerrar la
/// comparación es ponerlos a `null`, y con el `??` de siempre eso es
/// indistinguible de no querer cambiarlos.
const Object _keep = Object();

/// Lo que hay de contenido repetido, el grupo abierto y qué se hace con él.
///
/// Escucha la cola porque es la única forma de que lo encontrado aparezca solo.
/// Sin eso, pulsar «buscar» dejaría al usuario mirando una pantalla vacía sin
/// saber si ha pasado algo, y habría que salir y volver para ver el resultado —y
/// un escaneo puede tardar horas la primera vez.
class DuplicatesBloc extends Bloc<DuplicatesEvent, DuplicatesState> {
  final DuplicateRepository _repository;
  final JobQueue _jobs;
  final DuplicateDetailsLoader _details;
  final ApplyDuplicateGroupUseCase _apply;
  final DismissDuplicateGroupUseCase _dismiss;
  final LastScanReader? _lastScan;

  StreamSubscription<List<Job>>? _subscription;

  /// El trabajo que encoló el botón, para saber en qué quedó.
  ///
  /// Se guarda el identificador en lugar de mirar el último escaneo terminado
  /// porque pedir uno cancela el de fondo, y el de fondo puede tardar en darse
  /// por muerto más de lo que tarda el nuevo en acabar: por ahí salía un «se ha
  /// parado la búsqueda» detrás de una búsqueda que había ido bien.
  String? _userScanId;

  DuplicatesBloc({
    required DuplicateRepository repository,
    required JobQueue jobs,
    required DuplicateDetailsLoader details,
    required ApplyDuplicateGroupUseCase apply,
    required DismissDuplicateGroupUseCase dismiss,
    LastScanReader? lastScan,
  })  : _repository = repository,
        _jobs = jobs,
        _details = details,
        _apply = apply,
        _dismiss = dismiss,
        _lastScan = lastScan,
        super(const DuplicatesState()) {
    on<LoadDuplicatesEvent>(_onLoad);
    on<ScanForDuplicatesEvent>(_onScan);
    on<DuplicateJobsChangedEvent>(_onJobsChanged);
    on<SelectDuplicateGroupEvent>(_onSelect);
    on<ChooseDuplicateKeeperEvent>(_onChooseKeeper);
    on<ToggleDuplicateMergeEvent>(_onToggleMerge);
    on<ApplyDuplicateGroupEvent>(_onApply);
    on<DismissCurrentGroupEvent>(_onDismiss);

    _subscription =
        _jobs.changes.listen((jobs) => add(DuplicateJobsChangedEvent(jobs)));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();

    return super.close();
  }

  Future<void> _onLoad(
    LoadDuplicatesEvent event,
    Emitter<DuplicatesState> emit,
  ) async {
    final groups = await _groupsToReview();

    // Al volver a la pantalla con un escaneo del usuario ya en marcha, se
    // recupera cuál era: es el que hay que seguir y del que hay que dar cuenta
    // al terminar.
    _userScanId = _userScanIn(_jobs.jobs)?.id;

    emit(state.copyWith(
      groups: groups,
      isScanning: _hasScanRunning(_jobs.jobs),
      // Al volver a la pantalla con un escaneo ya en marcha hay que saber de
      // quién era: si era el de fondo, el botón sigue disponible.
      isUserScan: _userScanId != null,
      lastScan: _lastScan?.call(),
      isLoading: false,
    ));

    await _openFirst(groups, emit);
  }

  void _onScan(ScanForDuplicatesEvent event, Emitter<DuplicatesState> emit) {
    if (!state.canScan) return;

    // El escaneo de fondo se aparta: es el mismo trabajo con menos prisa, y
    // dejarlo correr significaría esperar horas a que acabe para poder mirar. No
    // se pierde nada al cortarlo, porque las huellas se guardan una a una.
    for (final job in _jobs.activeJobs) {
      if (job.type == JobType.duplicateScan) _jobs.cancel(job.id);
    }

    // Prioridad alta: esto lo acaba de pedir el usuario y está mirando.
    _userScanId = _jobs.enqueue(
      type: JobType.duplicateScan,
      priority: JobPriority.high,
    );

    emit(state.copyWith(
      isScanning: true,
      isUserScan: true,
      scanRequests: state.scanRequests + 1,
      scanDone: 0,
      scanTotal: 0,
    ));
  }

  Future<void> _onJobsChanged(
    DuplicateJobsChangedEvent event,
    Emitter<DuplicatesState> emit,
  ) async {
    final scanning = _hasScanRunning(event.jobs);

    // Sólo al terminar: releer en cada latido de la barra sería una consulta por
    // contenido hasheado.
    if (state.isScanning && !scanning) {
      final wasUserScan = state.isUserScan;
      final before = {for (final one in state.groups) one.id};

      final groups = await _groupsToReview();

      // Nuevos son los que no estaban antes de escanear. Los que ya se
      // conocían conservan su identificador al reconciliarse, así que volver a
      // verlos no los cuenta como hallazgo.
      final fresh = groups.where((one) => !before.contains(one.id)).length;

      // El grupo que se estaba comparando puede haber desaparecido: el escaneo
      // retira lo que ya no encuentra, y bajar el listón deja fuera de golpe
      // todo lo que ya no lo cumple.
      final isOpenGone = state.selectedGroupId != null &&
          !groups.any((one) => one.id == state.selectedGroupId);

      final ended = wasUserScan ? _outcomeOf(event.jobs, groups, fresh) : null;
      _userScanId = null;

      emit(state.copyWith(
        groups: groups,
        isScanning: false,
        isUserScan: false,
        scanDone: 0,
        scanTotal: 0,
        // La marca la sella quien escanea al terminar: se relee aquí para que
        // la pantalla pueda decir cuándo se miró sin salir y volver.
        lastScan: _lastScan?.call(),
        outcome: ended,
        freshGroups: wasUserScan ? fresh : state.freshGroups,
        scanResults: wasUserScan ? state.scanResults + 1 : state.scanResults,
        selectedGroupId: isOpenGone ? null : state.selectedGroupId,
        copies: isOpenGone ? const [] : state.copies,
        keeperId: isOpenGone ? null : state.keeperId,
      ));

      // Se abre otro si no había nada abierto o si lo que había ya no está.
      // Cambiárselo a quien está comparando le haría aplicar sobre otra cosa,
      // pero dejarle la mitad derecha en blanco con la lista llena es peor: hay
      // que volver a elegir a mano un grupo que la pantalla podía abrir sola.
      if (state.selectedGroupId == null) await _openFirst(groups, emit);

      return;
    }

    // El avance sólo se sigue cuando lo pidió el usuario: es quien está
    // delante esperándolo. Repintar la pantalla por cada huella del escaneo de
    // fondo sería cobrarle a todo el mundo un trabajo que nadie ha pedido.
    final active = state.isUserScan ? _userScanIn(event.jobs) : null;
    final done = active?.done ?? 0;
    final total = active?.total ?? 0;

    if (scanning != state.isScanning ||
        done != state.scanDone ||
        total != state.scanTotal) {
      emit(state.copyWith(
        isScanning: scanning,
        scanDone: done,
        scanTotal: total,
      ));
    }
  }

  /// En qué ha quedado el escaneo que acaba de terminar.
  ///
  /// El estado del trabajo manda sobre lo encontrado: un escaneo parado a la
  /// mitad tampoco ha encontrado nada, y decir «no hay repetidos» sin haber
  /// llegado a mirar la biblioteca entera es mentir.
  DuplicateScanOutcome _outcomeOf(
    List<Job> jobs,
    List<DuplicateGroupSummary> groups,
    int fresh,
  ) {
    final job = _jobById(jobs, _userScanId);

    if (job?.status == JobStatus.failed) return DuplicateScanOutcome.failed;
    if (job?.status == JobStatus.cancelled) {
      return DuplicateScanOutcome.cancelled;
    }

    if (fresh > 0) return DuplicateScanOutcome.found;

    return groups.isEmpty
        ? DuplicateScanOutcome.clean
        : DuplicateScanOutcome.nothingNew;
  }

  Job? _jobById(List<Job> jobs, String? id) {
    if (id == null) return null;

    for (final job in jobs) {
      if (job.id == id) return job;
    }

    return null;
  }

  /// El escaneo vivo que pidió el usuario, si lo hay.
  ///
  /// Se reconoce por la prioridad: el de fondo va en baja, y es la única forma
  /// de distinguirlos al volver a la pantalla con uno ya en marcha.
  Job? _userScanIn(List<Job> jobs) {
    for (final job in jobs) {
      if (job.type == JobType.duplicateScan &&
          job.status.isActive &&
          job.priority != JobPriority.low) {
        return job;
      }
    }

    return null;
  }

  Future<void> _onSelect(
    SelectDuplicateGroupEvent event,
    Emitter<DuplicatesState> emit,
  ) async {
    if (state.selectedGroupId == event.groupId) return;

    await _open(event.groupId, emit);
  }

  void _onChooseKeeper(
    ChooseDuplicateKeeperEvent event,
    Emitter<DuplicatesState> emit,
  ) {
    emit(state.copyWith(keeperId: event.mediaId));
  }

  void _onToggleMerge(
    ToggleDuplicateMergeEvent event,
    Emitter<DuplicatesState> emit,
  ) {
    emit(state.copyWith(mergeMetadata: event.merge));
  }

  Future<void> _onApply(
    ApplyDuplicateGroupEvent event,
    Emitter<DuplicatesState> emit,
  ) async {
    final group = state.selectedGroup;
    final keeperId = state.keeperId;
    if (group == null || keeperId == null || !state.canApply) return;

    final keeper = _copyOf(keeperId);
    if (keeper == null) return;

    emit(state.copyWith(isApplying: true));

    final result = await _apply(
      params: ApplyDuplicateGroupParams(
        groupId: group.id,
        keeper: keeper.media,
        discarded: discardedOf(state.copies, keeperId),
        mergeMetadata: state.mergeMetadata,
      ),
    );

    if (result is! DataSuccess) {
      emit(state.copyWith(isApplying: false));

      return;
    }

    await _advancePast(group.id, emit);
  }

  Future<void> _onDismiss(
    DismissCurrentGroupEvent event,
    Emitter<DuplicatesState> emit,
  ) async {
    final group = state.selectedGroup;
    if (group == null || state.isApplying) return;

    emit(state.copyWith(isApplying: true));

    final result = await _dismiss(params: group.id);
    if (result is! DataSuccess) {
      emit(state.copyWith(isApplying: false));

      return;
    }

    await _advancePast(group.id, emit);
  }

  /// Saca el grupo de la lista y abre el que ocupa su sitio.
  ///
  /// Sin releer la base: el grupo resuelto ya no vuelve, y volver a consultar
  /// cuarenta veces seguidas mientras se revisa en fila hace que cada pulsación
  /// se note.
  Future<void> _advancePast(int groupId, Emitter<DuplicatesState> emit) async {
    final rest = [
      for (final one in state.groups)
        if (one.id != groupId) one,
    ];

    final next = nextGroupId([for (final one in state.groups) one.id], groupId);

    emit(state.copyWith(
      groups: rest,
      isApplying: false,
      selectedGroupId: null,
      copies: const [],
      keeperId: null,
    ));

    if (next != null) await _open(next, emit);
  }

  /// Abre un grupo: lee sus copias y marca la que propone la heurística.
  Future<void> _open(int groupId, Emitter<DuplicatesState> emit) async {
    final group = _groupOf(groupId);
    if (group == null) return;

    emit(state.copyWith(
      selectedGroupId: groupId,
      copies: const [],
      keeperId: null,
      isLoadingGroup: true,
    ));

    final copies = await _details.load(group.mediaIds);

    // Puede haber cambiado de grupo mientras se leía: pintar lo que ya no se
    // está mirando pondría delante copias de otro grupo con el botón de aplicar
    // debajo.
    if (state.selectedGroupId != groupId) return;

    emit(state.copyWith(
      copies: copies,
      keeperId: preselectedKeeper(copies),
      isLoadingGroup: false,
    ));
  }

  Future<void> _openFirst(
    List<DuplicateGroupSummary> groups,
    Emitter<DuplicatesState> emit,
  ) async {
    if (groups.isEmpty) return;

    await _open(groups.first.id, emit);
  }

  DuplicateGroupSummary? _groupOf(int groupId) {
    for (final one in state.groups) {
      if (one.id == groupId) return one;
    }

    return null;
  }

  DuplicateCopy? _copyOf(int mediaId) {
    for (final copy in state.copies) {
      if (copy.mediaId == mediaId) return copy;
    }

    return null;
  }

  Future<List<DuplicateGroupSummary>> _groupsToReview() async {
    final found = await _repository.getGroupsToReview();

    return found is DataSuccess ? found.data ?? const [] : const [];
  }

  bool _hasScanRunning(List<Job> jobs) => jobs.any(
        (job) => job.type == JobType.duplicateScan && job.status.isActive,
      );
}
