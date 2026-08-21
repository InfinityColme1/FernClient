import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/recognition_model_entity.dart';
import 'package:Fern/features/recognition/domain/usecases/save_model_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/import_model_weights_usecase.dart';
import 'package:Fern/features/recognition/domain/usecases/search_fernies_usecase.dart';
import 'package:Fern/features/recognition/presentation/blocs/models_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/models_events.dart';
import 'package:Fern/features/recognition/presentation/blocs/models_states.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/features/recognition/data/services/recognition_engine.dart';
import 'package:Fern/features/recognition/data/services/training_job_runner.dart';
import 'package:Fern/features/recognition/presentation/widgets/fernie_split_row.dart';
import 'package:Fern/features/recognition/presentation/widgets/metrics_panel.dart';
import 'package:Fern/features/recognition/presentation/widgets/run_images_dialog.dart';
import 'package:Fern/features/recognition/presentation/widgets/training_panel.dart';
import 'package:Fern/features/settings/data/services/avatar_storage_service.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Un modelo por dentro: quién es, con qué aprende, cómo se reparte y cómo se
/// entrena.
///
/// **Paneles apilados a lo ancho y una sola barra de desplazamiento**, en el
/// orden en que se usan: quién es, cómo se entrena, con qué, y qué tal salió.
///
/// Antes iba en dos columnas repartiéndose el alto de la ventana, y eso dejaba
/// cada panel con su propio desplazamiento interno: para ver el tercer fernie
/// había que desplazar dentro de una lista de tres filas de alto, y para elegir
/// un preset, dentro de otra. Dos cosas que se hacen a menudo, ambas incómodas,
/// mientras el bloque de resultados se llevaba media pantalla diciendo
/// «todavía sin entrenar».
///
/// Ahora cada panel ocupa **lo que necesita** y es la página la que se desplaza.
/// Con el ancho entero, los tres presets caben en fila y los fernies se ven de
/// dos en dos en cuanto hay sitio.
class ModelDetailPage extends StatefulWidget {
  final int modelId;

  const ModelDetailPage({super.key, required this.modelId});

  @override
  State<ModelDetailPage> createState() => _ModelDetailPageState();
}

class _ModelDetailPageState extends State<ModelDetailPage> {
  final _bloc = getIt<ModelsBloc>();
  final _saveModel = getIt<SaveModelUseCase>();
  final _searchFernies = getIt<SearchFerniesUseCase>();
  final _avatarStorage = getIt<AvatarStorageService>();
  final _jobs = getIt<JobQueue>();
  final _engine = getIt<RecognitionEngine>();
  final _importWeights = getIt<ImportModelWeightsUseCase>();

  /// Se están trayendo unos pesos de fuera.
  ///
  /// Cargar un `.pt` para leer qué trae dentro tarda unos segundos: sin decirlo,
  /// el botón parece que no ha hecho nada y se pulsa otra vez.
  bool _isImporting = false;

  final _nameController = TextEditingController();

  /// Lo que se está editando de la identidad, hasta que se guarda.
  ///
  /// Se lleva aparte del modelo del bloc porque escribir es un estado a medias:
  /// mandar cada pulsación a la base de datos haría parpadear la rejilla de
  /// detrás con cada letra.
  String? _picturePath;
  ModelFunction? _function;
  bool _isSaving = false;

  /// El modelo que se cargó en los campos, para no pisarlos al releer.
  int? _loadedFor;

  /// El trabajo de entrenamiento de este modelo, si hay alguno vivo.
  ///
  /// Sale de la cola y no del bloc: la cola es la que sabe por dónde va, y
  /// duplicar ese estado en otro sitio es duplicar la forma de que se
  /// desincronice.
  Job? _job;
  StreamSubscription<List<Job>>? _jobsSubscription;

  @override
  void initState() {
    super.initState();
    _bloc.add(ModelSelectedEvent(widget.modelId));

    _syncJob(_jobs.jobs);
    _jobsSubscription = _jobs.changes.listen(_syncJob);
  }

  /// Se queda con el trabajo de este modelo, si lo hay.
  void _syncJob(List<Job> jobs) {
    Job? mine;

    for (final job in jobs) {
      final isMine = job.type == JobType.training &&
          job.payload[TrainingJobRunner.modelIdKey] == widget.modelId;

      if (isMine && job.status.isActive) mine = job;
    }

    if (!mounted || mine == _job) return;

    // Al arrancar se relee también: el fallo de la vez anterior se borra al
    // ponerse a entrenar, y el mensaje tiene que irse de la pantalla con él.
    final hasStarted = _job == null && mine != null;

    // Al terminar hay pesos nuevos y métricas nuevas: se relee para que la
    // pantalla deje de decir «sin entrenar».
    final hasFinished = _job != null && mine == null;

    setState(() => _job = mine);
    if (hasFinished || hasStarted) _bloc.add(ModelSelectedEvent(widget.modelId));
  }

  void _train() => unawaited(_startTraining());

  Future<void> _startTraining() async {
    final model = _bloc.state.selected;

    // El fallo de la vez anterior deja de ser noticia en cuanto se vuelve a
    // intentar, y se quita **al pulsar**: esperar a que el trabajo arranque deja
    // el mensaje puesto mientras hay otro por delante en la cola, y quien lo lee
    // no sabe si es de antes o de ahora.
    //
    // El repositorio lo limpia también al marcar «entrenando», que es lo que
    // cubre los entrenamientos lanzados desde otro sitio.
    if (model?.lastError != null) {
      await _saveModel(params: model!.copyWith(lastError: null));
      if (!mounted) return;

      _bloc.add(ModelSelectedEvent(widget.modelId));
    }

    _jobs.enqueue(
      type: JobType.training,
      priority: JobPriority.high,
      payload: {
        TrainingJobRunner.modelIdKey: widget.modelId,
        // El nombre viaja con el trabajo en vez de leerse al pintar la lista:
        // ésta se redibuja con cada época, y es además el nombre que tenía al
        // mandarlo a entrenar, que es el que el usuario recuerda.
        Job.nameKey: model?.name,
      },
    );
  }

  void _cancelTraining() {
    final job = _job;
    if (job != null) _jobs.cancel(job.id);
  }

  @override
  void dispose() {
    _jobsSubscription?.cancel();
    _nameController.dispose();
    _bloc.add(const ModelDeselectedEvent());
    super.dispose();
  }

  /// Rellena los campos con lo que hay guardado, una sola vez por modelo.
  ///
  /// Releer pasa a menudo —meter un fernie relee el modelo entero— y volver a
  /// poner el nombre en cada relectura borraría lo que se estuviera escribiendo.
  void _loadInto(RecognitionModelEntity model) {
    if (_loadedFor == model.id) return;

    _loadedFor = model.id;
    _nameController.text = model.name;
    _picturePath = model.picturePath;
    _function = model.function;
  }

  bool _hasChanges(RecognitionModelEntity model) {
    return _nameController.text.trim() != model.name ||
        _picturePath != model.picturePath ||
        _function != model.function;
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path == null || !mounted) return;

    final stored = await _avatarStorage.store(path);
    if (!mounted) return;

    setState(() => _picturePath = stored);
  }

  Future<void> _save(RecognitionModelEntity model) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);

    final result = await _saveModel(
      params: model.copyWith(
        name: name,
        picturePath: _picturePath,
        function: _function,
        // Guardar la identidad no borra lo que se sabe del último
        // entrenamiento: no se ha reentrenado nada.
        lastError: model.lastError,
      ),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result is! DataSuccess) return;

    _bloc.add(ModelSelectedEvent(model.id));
    _bloc.add(const LoadModelsEvent());

    showFernToast(context, AppLocalizations.of(context).modelSaved,
        icon: Icons.check);
  }

  /// Guarda los mandos del entrenamiento.
  ///
  /// Estos sí van directos, sin botón: elegir un preset **es** la decisión, y
  /// pedir además que se guarde sería un paso de más para algo que no se
  /// escribe a medias.
  Future<void> _saveSettings(RecognitionModelEntity changed) async {
    final result = await _saveModel(params: changed);
    if (!mounted || result is! DataSuccess) return;

    _bloc.add(ModelSelectedEvent(changed.id));
  }

  /// Mientras entrena no se añaden fernies: el dataset ya está montado.
  Future<List<FernieEntity>> _noSearch(String query) async => const [];

  Future<List<FernieEntity>> _searchAvailable(String query) async {
    final result = await _searchFernies(params: query);
    if (result is! DataSuccess) return const [];

    final taken = _bloc.assignedFernieIds;

    // Los que ya están dentro no se ofrecen: un fernie no puede ser dos clases
    // del mismo modelo.
    return [
      for (final fernie in result.data ?? const <FernieEntity>[])
        if (!taken.contains(fernie.id)) fernie,
    ];
  }

  /// Le pone a todos el reparto de uno.
  ///
  /// Lo normal es querer el mismo en todos: se ajusta uno y se copia, en vez de
  /// repetir el mismo arrastre por cada fernie.
  void _applyToAll(List<ModelFernieEntity> fernies, DatasetSplit split) {
    for (final assignment in fernies) {
      if (assignment.split == split) continue;

      _bloc.add(SplitChangedEvent(assignmentId: assignment.id, split: split));
    }
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return BlocProvider<ModelsBloc>.value(
      value: _bloc,
      child: BlocBuilder<ModelsBloc, ModelsState>(
        bloc: _bloc,
        builder: (context, state) {
          final model = state.selected;

          if (model == null) {
            return const Center(child: FernProgressIndicator());
          }

          _loadInto(model);

          return SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _identity(context, texts, model),
                const SizedBox(height: AppSpacing.l),
                // Primero cómo se entrena y luego con qué: elegir el esmero es
                // una decisión de una vez, y el botón tiene que estar donde se
                // ve sin buscarlo.
                TrainingPanel(
                  model: model,
                  fernies: state.fernies,
                  isEngineReady: _engine.isReady,
                  job: _job,
                  onSettingsChanged: _saveSettings,
                  onTrain: _train,
                  onCancel: _cancelTraining,
                ),
                const SizedBox(height: AppSpacing.l),
                _fernies(context, texts, state, model),
                const SizedBox(height: AppSpacing.l),
                MetricsPanel(
                  model: model,
                  onOpenFolder: _openFolder,
                  onShowImages: _showRunImages,
                  // Reintentar es entrenar otra vez: es el mismo botón de
                  // arriba, puesto donde se lee el fallo.
                  onRetry: _job == null ? _train : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Abre en el explorador del sistema.
  ///
  /// Que la carpeta ya no esté no es raro —la de runs es de las primeras que se
  /// borran para hacer sitio—, así que se comprueba antes en vez de dejar que el
  /// sistema conteste con un error suyo.
  Future<void> _openFolder(String path) async {
    if (!await Directory(path).exists()) {
      if (!mounted) return;

      showFernToast(
        context,
        AppLocalizations.of(context).metricsRunFolderMissing,
      );
      return;
    }

    await launchUrl(Uri.file(path));
  }

  void _showRunImages(String directory, RunImageKind kind) {
    showFernDialog<void, ModelsBloc>(
      context: context,
      builder: (_) => RunImagesDialog(
        directory: directory,
        kind: kind,
        onOpenFolder: _openFolder,
      ),
    );
  }

  /// Trae unos pesos entrenados en otro sitio.
  ///
  /// El plan B del doc 02: sin tarjeta gráfica no se puede entrenar aquí, y sin
  /// esto todo el trabajo de marcar fernies no serviría de nada en ese equipo.
  Future<void> _importExternalWeights() async {
    // Sólo `.pt`: es lo que el sidecar sabe cargar, y dejar elegir cualquier
    // fichero sólo lleva a un error dos pasos más tarde.
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pt'],
    );

    final path = picked?.files.singleOrNull?.path;
    if (path == null || !mounted) return;

    setState(() => _isImporting = true);

    final result = await _importWeights(
      params: ImportModelWeightsParams(modelId: widget.modelId, sourcePath: path),
    );

    if (!mounted) return;

    setState(() => _isImporting = false);
    final texts = AppLocalizations.of(context);

    if (result is! DataSuccess || result.data == null) {
      showFernToast(
        context,
        texts.modelImportWeightsInvalid('${result.exception}'),
      );
      return;
    }

    // Se dicen las clases que trae: es lo único que revela si el `.pt` es el que
    // el usuario creía, y emparejarlas con sus fernies es cosa suya.
    showFernToast(
      context,
      texts.modelImportWeightsDone(result.data!.classes.join(', ')),
    );

    _bloc.add(ModelSelectedEvent(widget.modelId));
  }

  // ---------------------------------------------------------------------------
  // Identidad
  // ---------------------------------------------------------------------------

  Widget _identity(
    BuildContext context,
    AppLocalizations texts,
    RecognitionModelEntity model,
  ) {
    return FernSurface(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                tooltip: texts.viewerBack,
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: AppSpacing.s),
              FernEditableAvatar(
                imagePath: _picturePath,
                fallbackIcon: Icons.hub_outlined,
                radius: AppSizes.avatarXLarge,
                iconSize: AppSizes.iconExtraLarge,
                onTap: _pickImage,
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FernLabeledTextField(
                      label: texts.modelNameLabel,
                      hintText: texts.enterNameHint,
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _functionField(context, texts, model),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.l),
              IconButton(
                tooltip: texts.modelImportWeightsHint,
                onPressed: _isImporting || _job != null
                    ? null
                    : _importExternalWeights,
                icon: _isImporting
                    ? const SizedBox.square(
                        dimension: AppSizes.iconMedium,
                        child: FernProgressIndicator(),
                      )
                    : const Icon(Icons.file_download_outlined),
              ),
              const SizedBox(width: AppSpacing.s),
              FernConfirmButton(
                icon: null,
                isBusy: _isSaving,
                onPressed: _hasChanges(model) ? () => _save(model) : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            '${texts.modelFernieCount(model.fernieCount)} · '
            '${texts.modelRegionCount(model.regionCount)}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.colors.unremarked),
          ),
          if (model.isImportedWeights) ...[
            const SizedBox(height: AppSpacing.s),
            _notice(context, texts.modelImportedBadge),
          ],
          if (model.isDegraded) ...[
            const SizedBox(height: AppSpacing.s),
            _notice(context, texts.modelDegradedNotice),
          ],
          if (model.isUsable) ...[
            const SizedBox(height: AppSpacing.s),
            _notice(context, texts.modelRetrainNotice),
          ],
        ],
      ),
    );
  }

  Widget _functionField(
    BuildContext context,
    AppLocalizations texts,
    RecognitionModelEntity model,
  ) {
    return Row(
      children: [
        for (final function in ModelFunction.values) ...[
          FernPillButton(
            label: switch (function) {
              ModelFunction.boolean => texts.modelFunctionBoolean,
              ModelFunction.classification => texts.modelFunctionClassification,
            },
            // La elegida va marcada y con el icono; la otra, apagada. Es un
            // interruptor de dos, no dos botones que hacen cosas distintas.
            icon: _function == function
                ? Icons.check_circle_outline
                : Icons.circle_outlined,
            backgroundColor: _function == function
                ? context.colors.primary
                : context.colors.secondary,
            foregroundColor: context.colors.black,
            onPressed: () => setState(() => _function = function),
          ),
          const SizedBox(width: AppSpacing.s),
        ],
      ],
    );
  }

  /// Un aviso de los que no bloquean nada pero hay que decir.
  Widget _notice(BuildContext context, String message) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline,
          size: AppSizes.iconSmall,
          color: context.colors.unremarked,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: context.colors.unremarked),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Fernies asignados
  // ---------------------------------------------------------------------------

  Widget _fernies(
    BuildContext context,
    AppLocalizations texts,
    ModelsState state,
    RecognitionModelEntity model,
  ) {
    return FernSurface(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                texts.modelAssignedFernies,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (state.fernies.length > 1)
                TextButton(
                  onPressed: _job != null
                      ? null
                      : () =>
                          _applyToAll(state.fernies, state.fernies.first.split),
                  child: Text(texts.modelApplySplitToAll),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          SizedBox(
            width: AppSizes.tagListWidth,
            child: FernEntitySearchField<FernieEntity>(
              label: texts.modelAddFernie,
              hintText: texts.searchEllipsisHint,
              search: _job != null ? _noSearch : _searchAvailable,
              labelOf: (fernie) => fernie.name,
              onSelected: (fernie) => _bloc.add(AssignFernieEvent(fernie.id)),
              debounce: searchDebounceDuration,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          _fernieList(context, texts, state),
        ],
      ),
    );
  }

  Widget _fernieList(
    BuildContext context,
    AppLocalizations texts,
    ModelsState state,
  ) {
    if (state.fernies.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Text(
            texts.modelNoFernies,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.colors.unremarked),
          ),
        ),
      );
    }

    // Sin desplazamiento propio: la lista ocupa lo que ocupe y la que se
    // desplaza es la página. Desplazar dentro de una caja de tres filas de alto
    // para ver el tercer fernie era lo peor de la pantalla anterior.
    //
    // De dos en dos en cuanto hay sitio: una fila de fernie es alta —nombre,
    // recuentos, aviso y barra de reparto— y a lo ancho de una ventana grande
    // sobraba la mitad del papel.
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >= fernieRowsTwoColumnsWidth ? 2 : 1;

        return Wrap(
          spacing: AppSpacing.xl,
          runSpacing: AppSpacing.s,
          children: [
            for (final assignment in state.fernies)
              SizedBox(
                width: (constraints.maxWidth -
                        AppSpacing.xl * (columns - 1)) /
                    columns,
                child: _splitRow(assignment),
              ),
          ],
        );
      },
    );
  }

  Widget _splitRow(ModelFernieEntity assignment) {
    // Con el entrenamiento en marcha, el reparto y los fernies quedan fijos. El
    // dataset ya está montado con lo que había: cambiarlo ahora no cambiaría
    // nada de lo que está corriendo, pero lo parecería, y al terminar los pesos
    // no se corresponderían con lo que enseña la pantalla.
    final isLocked = _job != null;

    return FernieSplitRow(
      key: ValueKey(assignment.id),
      assignment: assignment,
      onSplitChanged: isLocked
          ? null
          : (split) => _bloc.add(
                SplitChangedEvent(assignmentId: assignment.id, split: split),
              ),
      onRemove:
          isLocked ? null : () => _bloc.add(RemoveFernieEvent(assignment.id)),
    );
  }
}
