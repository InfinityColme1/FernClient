import 'dart:async';

import 'package:Fern/core/navigation/fern_screen_layout.dart';
import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/presentation/widgets/import_view_menu.dart';
import 'package:Fern/features/media/presentation/widgets/remote_creator_card.dart';
import 'package:Fern/features/media/domain/usecases/get_remote_creators_usecase.dart';
import 'package:Fern/features/media/domain/entities/remote_creator.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/services/jobs/job.dart';
import 'package:Fern/core/services/jobs/job_queue.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/ui/ui.dart';
// Experimental: de aquí sale a dónde se manda al usuario a iniciar sesión.
import 'package:Fern/features/browser/domain/entities/browser_session_source.dart';
import 'package:Fern/features/browser/presentation/widgets/session_expired_dialog.dart';
import 'package:Fern/features/media/domain/entities/empty_source.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media_sort_order.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/media/suggestion_filter.dart';
import 'package:Fern/features/recognition/data/services/recognition_highlight.dart';
import 'package:Fern/features/recognition/domain/usecases/accept_suggestions_above_usecase.dart';
import 'package:Fern/features/media/domain/entities/media_deletion_kind.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_mode_service.dart';
import 'package:Fern/features/media/presentation/widgets/confirm_delete_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/confirm_remote_import_dialog.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/widgets/settings_dialog.dart';
import 'package:Fern/features/settings/presentation/widgets/settings_section.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/features/media/presentation/widgets/select_all_button.dart';
import 'package:Fern/features/recognition/presentation/recognition_feedback.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/service_locator.dart';

/// Cómo se llama cada fuente en la pantalla. Las plataformas se llaman igual en
/// todos los idiomas, así que sólo se traducen la del equipo y la de "todas".
extension ImportSourceLabel on ImportSource {
  String name(AppLocalizations texts) =>
      label ??
      switch (this) {
        ImportSource.all => texts.sourceAll,
        ImportSource.browser => texts.sourceBrowser,
        _ => texts.sourceLocalComputer,
      };
}

/// Cómo se nombra cada opción de la píldora del tope: un número, o el nombre de
/// las dos que no lo son.
String importLimitLabel(int limit, AppLocalizations texts) => switch (limit) {
  unlimitedImportLimit => texts.importLimitAll,
  untilLastImportLimit => texts.importLimitSinceLast,
  _ => '$limit',
};

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  @override
  void initState() {
    super.initState();
    // CARGA AUTOMÁTICA: Disparamos el evento al iniciar la pantalla
    getIt<MediaBloc>().add(const LoadScannedMediaEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MediaBloc>.value(
      value: getIt<MediaBloc>(),
      child: const _ImportView(),
    );
  }
}

class _ImportView extends StatefulWidget {
  const _ImportView();

  @override
  State<_ImportView> createState() => _ImportViewState();
}

class _ImportViewState extends State<_ImportView> {
  late final RecognitionHighlight _highlight = getIt<RecognitionHighlight>();

  /// Si hay una importación corriendo **de verdad**.
  ///
  /// Sale de la cola de trabajos y no del estado de la pantalla. El estado dice
  /// «ocupado» también mientras se relee la lista al entrar, y esa relectura
  /// termina enseguida: saliendo de la pantalla y volviendo, el indicador se
  /// apagaba aunque la importación siguiera. La cola es la que sabe.
  bool _isImporting = false;

  /// Ya se ha pedido parar y todavía no ha parado.
  bool _isStopping = false;

  StreamSubscription<List<Job>>? _jobs;

  @override
  void initState() {
    super.initState();
    _highlight.addListener(_onRecognized);

    _onJobs(getIt<JobQueue>().activeJobs);
    _jobs = getIt<JobQueue>().changes.listen(_onJobs);
  }

  @override
  void dispose() {
    _highlight.removeListener(_onRecognized);
    _jobs?.cancel();
    super.dispose();
  }

  /// Se ha movido algo en la cola de trabajos.
  ///
  /// Lo que llega por el flujo es la cola **entera**, terminados incluidos: la
  /// importación que acaba de terminar sigue ahí, en la historia, y contarla
  /// dejaba el indicador encendido para siempre. Se mira sólo lo que sigue
  /// vivo, que es lo mismo que se mira al entrar en la pantalla.
  void _onJobs(List<Job> jobs) {
    final importing = jobs.any(
      (job) => job.type == JobType.mediaImport && job.status.isActive,
    );
    if (importing == _isImporting || !mounted) return;

    setState(() {
      _isImporting = importing;

      // Ha parado: lo pedido ya está hecho, así que el botón vuelve.
      if (!importing) _isStopping = false;
    });
  }

  /// Parar la importación.
  ///
  /// **No es inmediato y no puede serlo**: la señal se mira entre un contenido y
  /// el siguiente, así que lo que se esté descargando termina de llegar antes de
  /// que el recorrido pueda mirarla. Se dice, entonces: el botón se apaga y un
  /// aviso cuenta que está parando. Sin eso, pulsar parar no hacía nada visible
  /// durante varios segundos y se volvía a pulsar.
  void _stop(BuildContext context) {
    context.read<MediaBloc>().add(const StopImportEvent());

    setState(() => _isStopping = true);
    showFernToast(context, AppLocalizations.of(context).importStopping);
  }

  /// Un reconocimiento ha terminado sobre esta pantalla.
  ///
  /// Sin esto, el aviso salta pero la rejilla sigue siendo la de antes: los
  /// distintivos no aparecen hasta que el usuario sale y vuelve, que es
  /// exactamente lo que el aviso le estaba pidiendo que no hiciera falta.
  void _onRecognized() {
    if (!mounted) return;

    final bloc = context.read<MediaBloc>();

    if (!shouldReloadOnRecognition(
      highlighted: _highlight.route,
      screen: importRoute,
      hasSelection: bloc.state.selectedIds.isNotEmpty,
      isViewingMedia: bloc.state is DetailedMedia,
    )) {
      return;
    }

    bloc.add(const LoadScannedMediaEvent());
  }

  /// Tope de contenidos nuevos que se trae el próximo escaneo.
  ///
  /// Es de la pantalla y no del bloc: no cambia lo que se está viendo, sólo
  /// cuánto se pide la próxima vez. De partida no hay tope, que es traerse todo
  /// lo que haya.
  /// Hasta dónde llega el escaneo. Se arranca con lo último que se eligió.
  late int _limit = getIt<PreferencesService>().getImportLimit();

  /// En qué orden se pinta lo pendiente de revisar.
  ///
  /// El suyo y no el de la biblioteca: una tanda recién traída se repasa
  /// agrupada por tipo o puesta por nombre, y eso no tiene por qué ser cómo se
  /// quiere ver la biblioteca después.
  late MediaSortOrder _sortOrder = getIt<PreferencesService>()
      .getImportSortOrder();

  /// Si se está enseñando la lista de creadores en vez del contenido.
  ///
  /// Empieza encendida en las fuentes que la ofrecen —es lo que el ajuste
  /// pedía—, y se puede apagar desde el menú de la cabecera: la lista tapa la
  /// rejilla, así que tiene que haber forma de quitarla de en medio.
  bool _showCreators = true;

  List<RemoteCreator> _creators = const [];
  Set<String> _selectedCreators = {};
  bool _loadingCreators = false;

  /// Para poder descartar una lista que ya no es de la fuente que se está
  /// mirando: cambiar de fuente mientras se cuentan las publicaciones dejaría
  /// las tarjetas de la anterior con los números de la nueva.
  ImportSource? _creatorsOf;

  /// Trae la lista de creadores de la fuente, y luego sus cuentas.
  ///
  /// En dos pasos a propósito: contar es una petición por creador, y con
  /// cincuenta marcados hacerlas antes de enseñar nada dejaría la pantalla en
  /// blanco medio minuto.
  Future<void> _loadCreators(ImportSource source) async {
    setState(() {
      _loadingCreators = true;
      _creators = const [];
      _selectedCreators = {};
      _creatorsOf = source;
    });

    final found = await getIt<GetRemoteCreatorsUseCase>()(params: source);
    if (!mounted || _creatorsOf != source) return;

    final creators = found is DataSuccess
        ? found.data ?? const <RemoteCreator>[]
        : const <RemoteCreator>[];

    setState(() {
      _creators = creators;
      _loadingCreators = false;
    });

    await for (final counted in getIt<CountRemoteCreatorPostsUseCase>()(
      source,
      creators,
    )) {
      if (!mounted || _creatorsOf != source) return;

      setState(() {
        _creators = [
          for (final creator in _creators)
            if (creator.id == counted.id) counted else creator,
        ];
      });
    }
  }

  /// Si esta fuente ofrece elegir por creadores.
  ///
  /// Dos condiciones, y las dos importan. **Pawchive** porque es la única cuyo
  /// camino de red para esto se ha visto funcionar; las demás lo tendrán cuando
  /// se compruebe el suyo con una sesión de verdad. Y **su ajuste puesto**
  /// porque esta vista es lo que aquella casilla hacía: quien la tenga apagada
  /// está pidiendo sus guardados, no los de la gente que sigue.
  bool _offersCreators(ImportSource source) {
    if (source != ImportSource.pawchive) return false;

    return getIt<SettingsBloc>().state.settings.pawchive.byFavoriteCreators;
  }

  /// Si lo que se está enseñando ahora mismo es la lista de creadores.
  bool _showsCreatorsMode(ImportSource source) =>
      _offersCreators(source) && _showCreators;

  /// La rejilla de creadores: una tarjeta por cada uno.
  ///
  /// Pulsar una se trae lo suyo al momento; marcarla con el botón derecho la
  /// junta con las demás para traérselas de una vez. Son dos gestos porque son
  /// dos cosas: casi siempre se quiere uno, y de vez en cuando cinco.
  Widget _creatorsGrid(AppLocalizations texts) {
    if (_loadingCreators) {
      return const Center(child: FernProgressIndicator());
    }

    if (_creators.isEmpty) {
      return FernEmptyState(
        imageAsset: fernEmptyImage,
        message: texts.remoteCreatorsEmpty,
      );
    }

    return FernSurface(
      // Recortando: sin esto las celdas de arriba se salen por encima del borde
      // redondeado al desplazarse, que es lo que se veía.
      clipBehavior: Clip.antiAlias,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.gridInset),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: remoteCreatorCardWidth,
          mainAxisSpacing: AppSpacing.s,
          crossAxisSpacing: AppSpacing.s,
          // Alto fijo y no una proporción: lo que mide una tarjeta lo deciden
          // su avatar y sus tres líneas de texto, no lo ancha que sea la
          // ventana. Con una proporción, una columna estrecha dejaba las
          // tarjetas más bajas que su contenido y éste se salía.
          mainAxisExtent: remoteCreatorCardHeight,
        ),
        itemCount: _creators.length,
        itemBuilder: (context, index) {
          final creator = _creators[index];

          return RemoteCreatorCard(
            creator: creator,
            isSelected: _selectedCreators.contains(creator.id),
            onTap: () {
              _importCreators({creator.id});

              // Se dice que ha arrancado. Lo que pasa después ocurre en la cola
              // y en otra pestaña de la rejilla: sin esto, pulsar una tarjeta no
              // parecía haber hecho nada.
              showFernToast(
                context,
                texts.remoteCreatorImporting(creator.name),
                icon: Symbols.download,
              );
            },
            onSelectionToggled: () => setState(() {
              _selectedCreators = {
                for (final id in _selectedCreators)
                  if (id != creator.id) id,
                if (!_selectedCreators.contains(creator.id)) creator.id,
              };
            }),
          );
        },
      ),
    );
  }

  /// Pide la lista de creadores si toca y todavía no se ha pedido.
  ///
  /// Se dispara desde el pintado porque es cuando se sabe qué fuente hay puesta
  /// —la elige el bloc, no esta pantalla—, y con el guardia de [_creatorsOf] se
  /// pide **una vez** por fuente: sin él, cada repintado lanzaría otra tanda de
  /// peticiones.
  void _loadCreatorsIfNeeded(ImportSource source) {
    if (!_showsCreatorsMode(source)) return;
    if (_creatorsOf == source || _loadingCreators) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_loadCreators(source));
    });
  }

  /// Trae lo de estos creadores.
  void _importCreators(Set<String> creators) {
    if (creators.isEmpty) return;

    getIt<MediaBloc>().add(
      ScanCreatorsEvent(limit: _limit, creators: creators),
    );

    setState(() => _selectedCreators = {});
  }

  /// Con qué parte de lo pendiente se está trabajando.
  ///
  /// Vive en la pantalla y no en el bloc: es cómo se está mirando la lista, no
  /// qué lista es. Cambiar de fuente no lo toca, que es lo que se quiere: quien
  /// está despachando sugerencias sigue despachándolas al cambiar de fuente.
  SuggestionFilter _filter = SuggestionFilter.all;

  /// Acepta de golpe lo que los modelos ven con más seguridad en la selección.
  ///
  /// El listón es el mismo con el que el panel pinta una sugerencia como fiable:
  /// si el color prometiera «bueno» por debajo de donde este botón acepta,
  /// estaría prometiendo algo que el botón no hace.
  Future<void> _acceptAbove(BuildContext context, MediaStates state) async {
    final result = await getIt<AcceptSuggestionsAboveUseCase>()(
      params: AcceptAboveParams(
        mediaIds: state.selectedIds.toList(),
        threshold: suggestionHighConfidence,
      ),
    );

    if (!context.mounted) return;

    showFernToast(
      context,
      AppLocalizations.of(context).acceptAboveDone(result.data?.accepted ?? 0),
      icon: Symbols.info,
    );

    // Las celdas dejan de llevar el distintivo en cuanto no les queda nada sin
    // contestar, y eso vive en el sumario: hay que releer. Releer, no volver a
    // escanear la fuente: lo que ha cambiado está en la base de datos.
    if (context.mounted) {
      context.read<MediaBloc>().add(const LoadScannedMediaEvent());
    }
  }

  /// Si la fuente elegida se puede usar tal y como está configurada.
  ///
  /// Una fuente remota necesita sus credenciales; sin ellas, la importación no
  /// puede ni empezar y la pantalla lo avisa antes de que se intente. La opción
  /// de todas no se bloquea: si una fuente no está lista, se importa de las
  /// demás.
  bool _isConfigured(ImportSource source, SettingsState settings) {
    return switch (source) {
      ImportSource.reddit => settings.settings.reddit.isComplete,
      ImportSource.pixiv => settings.settings.pixiv.isComplete,
      ImportSource.danbooru => settings.settings.danbooru.isComplete,
      ImportSource.gelbooru => settings.settings.gelbooru.isComplete,
      ImportSource.pinterest => settings.settings.pinterest.isComplete,
      ImportSource.pawchive => settings.settings.pawchive.isComplete,
      _ => true,
    };
  }

  /// Cuánto hace que se importó de la fuente, en la unidad que toque.
  ///
  /// Se cuenta desde el momento sellado al terminar el último escaneo, así que
  /// lo que dice es cuánto lleva la rejilla sin mirar la fuente.
  String _lastImportLabel(AppLocalizations texts, DateTime at) {
    final elapsed = DateTime.now().difference(at);
    if (elapsed.isNegative || elapsed.inHours < 1) {
      return texts.lastImportMinutes(
        elapsed.isNegative ? 0 : elapsed.inMinutes,
      );
    }
    if (elapsed.inDays < 1) return texts.lastImportHours(elapsed.inHours);

    return texts.lastImportDays(elapsed.inDays);
  }

  /// Lo que se dice de la fuente elegida junto a su nombre, o `null` si no hay
  /// nada que decir (la opción de todas las fuentes, que no tiene un único
  /// momento de última importación).
  ///
  /// Son dos textos: el corto, que es el que se pinta y cabe entero en la
  /// cabecera, y el largo del globo de ayuda, que es donde caben los matices.
  /// Lo que no está configurado manda: de nada sirve contar cuánto hace que no
  /// se importa de una fuente que todavía no se puede usar.
  ///
  /// Cuando lo que le falta a la fuente es que el usuario entre en su cuenta, la
  /// nota lleva además a dónde se hace ([onTap]): decir que falta algo y no
  /// decir por dónde se arregla es dejar el trabajo a medias.
  ({String label, String hint, IconData icon, VoidCallback? onTap})?
  _sourceNote(
    BuildContext context,
    AppLocalizations texts,
    MediaStates state,
    bool isConfigured,
  ) {
    if (!isConfigured) {
      // Las plataformas en las que se entra desde el navegador de la
      // aplicación mandan ahí, a su página de inicio de sesión.
      final login = browserSessionFor(state.importSource);
      if (login != null && login.isSessionRequired) {
        return (
          label: texts.sourceLogIn(state.importSource.name(texts)),
          hint: texts.sourceLogInHint(state.importSource.name(texts)),
          icon: Symbols.login,
          onTap: () => context.go(browserRouteWithUrl(login.loginUrl)),
        );
      }

      return (
        label: texts.sourceNotConfigured,
        hint: texts.sourceNotConfiguredHint,
        icon: Symbols.info,
        onTap: null,
      );
    }

    // Del navegador no se importa desde aquí: lo que hay es lo que el usuario
    // se haya traído desde su pantalla, así que se dice en lugar de contar
    // cuánto hace de una importación que nunca se hizo.
    if (state.importSource == ImportSource.browser) {
      return (
        label: texts.sourceBrowserNote,
        hint: texts.sourceBrowserHint,
        icon: Symbols.travel_explore,
        onTap: () => context.go(browserRoute),
      );
    }

    if (state.importSource == ImportSource.all) return null;

    final lastImportAt = state.lastImportAt;

    return (
      label: lastImportAt == null
          ? texts.lastImportNever
          : _lastImportLabel(texts, lastImportAt),
      hint: texts.lastImportHint,
      icon: Symbols.history,
      onTap: null,
    );
  }

  /// La nota que va junto al nombre de la fuente.
  ///
  /// La que lleva a alguna parte se pinta como lo que es, un enlace: en color y
  /// subrayada. Las demás son sólo un apunte y van en gris, sin invitar a
  /// pulsarlas.
  ///
  /// El texto se recorta antes que desbordar la cabecera: lo que dice cabe de
  /// sobra en una ventana normal, pero es la parte de la fila que crece con el
  /// idioma y no puede ser ella la que rompa la cabecera.
  Widget _note(
    BuildContext context,
    ({String label, String hint, IconData icon, VoidCallback? onTap}) note,
  ) {
    final theme = Theme.of(context);
    final isLink = note.onTap != null;
    final color = isLink ? context.colors.terciary : context.colors.gray;

    return Tooltip(
      message: note.hint,
      child: InkWell(
        onTap: note.onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(note.icon, size: AppSizes.iconCompact, color: color),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  note.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: isLink ? FontWeight.w600 : null,
                    decoration: isLink ? TextDecoration.underline : null,
                    decorationColor: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Busca contenido en la fuente elegida.
  ///
  /// Si hay alguna plataforma de por medio se avisa antes: eso sale a internet
  /// con las credenciales del usuario y descarga ficheros a su equipo, así que
  /// no puede pasar por un clic de más. Escanear una carpeta del propio equipo
  /// no tiene nada de eso y arranca sin preguntar.
  Future<void> _scan(BuildContext context, ImportSource source) async {
    final bloc = context.read<MediaBloc>();

    final remote = [
      for (final each in source.sources)
        if (each.isRemote) each,
    ];

    if (remote.isNotEmpty) {
      final confirmed = await showFernDialog<bool, MediaBloc>(
        context: context,
        builder: (_) =>
            ConfirmRemoteImportDialog(sources: remote, limit: _limit),
      );
      if (confirmed != true) return;
    }

    bloc.add(ScanSourceEvent(limit: _limit));
  }

  /// Avisa de que [source] no ha aceptado lo que se le daba para entrar y, si
  /// el usuario quiere, le lleva a donde se arregla.
  ///
  /// Y ese sitio no es el mismo en todas: las plataformas en las que se entra
  /// desde el navegador de la aplicación mandan ahí, a volver a iniciar sesión;
  /// las que se configuran con una clave de API mandan a sus ajustes, que es
  /// donde está lo que hay que repasar.
  Future<void> _onSessionExpired(
    BuildContext context,
    ImportSource source,
  ) async {
    final login = browserSessionFor(source);

    final goToFix = await showFernDialog<bool, MediaBloc>(
      context: context,
      builder: (_) => SessionExpiredDialog(source: source),
    );
    if (goToFix != true || !context.mounted) return;

    if (login != null) {
      context.go(browserRouteWithUrl(login.loginUrl));
      return;
    }

    await showFernDialog<void, MediaBloc>(
      context: context,
      builder: (_) =>
          const SettingsDialog(initialSection: SettingsSection.remoteSources),
    );
  }

  /// Descarta la selección, avisando antes de que va a salir de la aplicación y
  /// preguntando qué se hace con sus ficheros. Si se cancela no se toca nada.
  Future<void> _discardSelection(BuildContext context, int count) async {
    final bloc = context.read<MediaBloc>();

    final deleteFiles = await showFernDialog<bool, MediaBloc>(
      context: context,
      builder: (_) =>
          ConfirmDeleteDialog(kind: MediaDeletionKind.discard, count: count),
    );
    if (deleteFiles == null) return;

    bloc.add(DeleteSelectedMediaEvent(deleteFiles: deleteFiles));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    return BlocConsumer<MediaBloc, MediaStates>(
      listenWhen: (previous, current) =>
          (previous is! DetailedMedia && current is DetailedMedia) ||
          current.expiredSession != null ||
          current.importError != null ||
          current.emptySource != null,
      listener: (context, state) {
        if (state is DetailedMedia) {
          // El contenido escaneado se abre con la información desplegada: es
          // la pantalla donde se revisa antes de darlo por definitivo.
          context.push(viewerRouteWithInfo(true));
          return;
        }

        // La importación ha acabado porque la plataforma ya no reconoce la
        // sesión: se dice, y se ofrece ir a donde se arregla.
        if (state.expiredSession case final source?) {
          _onSessionExpired(context, source);
          return;
        }

        // La fuente no tenía nada. No es un fallo, pero decirlo evita que una
        // importación vacía se confunda con una rota.
        if (state.emptySource case final source?) {
          showFernDialog<void, MediaBloc>(
            context: context,
            builder: (_) => FernMessageDialog(
              imageAsset: fernEmptyImage,
              message: switch (state.emptyHint) {
                EmptySourceHint.pawchiveHasCreatorsInstead =>
                  texts.emptySourcePawchiveCreators,
                null => texts.emptySource(source.name(texts)),
              },
            ),
          );
          return;
        }

        // Cualquier otro fallo de la fuente: no se puede arreglar desde aquí,
        // pero callarlo deja la pantalla igual que si no hubiera nada nuevo.
        if (state.importError case final error?) {
          showFernDialog<void, MediaBloc>(
            context: context,
            builder: (_) => FernMessageDialog(
              imageAsset: fernEmptyImage,
              message: texts.importFailed(error),
            ),
          );
        }
      },
      builder: (context, state) {
        // Lo que hay, y lo que el filtro deja ver. La rejilla y el recuento van
        // sobre lo segundo: enseñar un número que no cuadra con lo que se está
        // viendo es peor que no enseñarlo.
        final all = state.mediaList ?? const <MediaSummaryEntity>[];
        final visible = [
          for (final one in all)
            if (_filter.matches(one)) one,
        ];

        final hasMedia = all.isNotEmpty;
        // Los botones masivos actúan sobre la selección de la rejilla, así que
        // sin selección no hay nada que borrar ni que confirmar.
        final selectedCount = state.selectedIds.length;
        final hasSelection = selectedCount > 0;

        final source = state.importSource;
        // De una plataforma remota no hay carpeta que elegir: lo que se importa
        // es lo que el usuario tenga guardado en su cuenta. Del navegador
        // tampoco: lo que trae lo trae él.
        final canPickFolder =
            !source.isRemote && source != ImportSource.browser;
        // Y al navegador no se le puede pedir nada desde aquí: no es una fuente
        // que se recorra, es lo que el usuario haya ido eligiendo página a
        // página en su pantalla.
        final canScan = source != ImportSource.browser;

        // Entrar en una fuente que ofrece creadores los pide sola: es lo que se
        // va a enseñar, así que esperar a que el usuario pulse algo sería
        // enseñarle una pantalla vacía y pedirle que la llene.
        _loadCreatorsIfNeeded(source);

        return FernGridScreen(
          // HEADER ROW DINÁMICA
          header: BlocBuilder<SettingsBloc, SettingsState>(
            bloc: getIt<SettingsBloc>(),
            builder: (context, settings) {
              final isConfigured = _isConfigured(source, settings);

              // Seleccionar cambia a qué se está jugando: ya no se trata
              // de traer contenido sino de decidir sobre lo que hay. La
              // fila se sustituye entera en vez de encender tres botones
              // más, que es lo que la reventaba justo cuando más falta
              // hacía que se entendiera.
              if (hasSelection) {
                return _SelectionBar(
                  selected: selectedCount,
                  total: visible.length,
                  onAcceptAbove: () => _acceptAbove(context, state),
                  onDelete: () => _discardSelection(context, selectedCount),
                  onRecognize: () => requestRecognition(
                    context,
                    state.selectedIds.toList(),
                    name: texts.recognizeJobSelection,
                  ),
                  selectAll: SelectAllButton(
                    visible: visible,
                    selectedIds: state.selectedIds,
                    onSelectAll: (ids) =>
                        context.read<MediaBloc>().add(SelectAllMediaEvent(ids)),
                  ),
                );
              }

              return Row(
                children: [
                  FernDropdownPill<ImportSource>(
                    value: source,
                    items: const [ImportSource.all, ...ImportSource.listed],
                    labelBuilder: (source) => source.name(texts),
                    onChanged: (source) {
                      if (source == null) return;
                      context.read<MediaBloc>().add(
                        ImportSourceChangedEvent(source),
                      );
                    },
                  ),
                  // Al lado de la fuente, cómo está: si todavía no se
                  // puede usar se dice aquí (que es donde se ha elegido)
                  // en lugar de dejar que la importación no haga nada sin
                  // explicar por qué, y si ya se ha usado, cuánto hace de
                  // la última vez.
                  if (_sourceNote(context, texts, state, isConfigured)
                      case final note?) ...[
                    const SizedBox(width: AppSpacing.m),
                    Flexible(child: _note(context, note)),
                  ],
                  const Spacer(),
                  // CENTER: Stats
                  //
                  // Con selección se dice una sola cosa —«3 de 332
                  // seleccionados»— y no dos. Dos textos ocupan el ancho
                  // que necesitan los botones de la derecha, y la cuenta
                  // total sin la selección al lado tampoco decía gran
                  // cosa.
                  if (hasMedia) ...[
                    // Entero, sin recortar: es un numero, y un numero a
                    // medias con puntos suspensivos no dice nada.
                    Text(
                      texts.mediaFetched(visible.length),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const Spacer(),

                  // RIGHT: Actions
                  //
                  // Cuántos contenidos nuevos se trae el escaneo como
                  // mucho. Vale para cualquier fuente que se escanee: es un
                  // tope de lo que se descarga, no una cosa de las remotas.
                  // De la que no se escanea no se enseña, que ahí no hay
                  // nada que topar.
                  if (canScan) ...[
                    // **El rótulo va dentro de la píldora, no encima.**
                    //
                    // Encima hacía este control más alto que todos los demás
                    // de la fila, y por eso la cabecera entera tenía que
                    // alinearse por la base en vez de por el centro: un solo
                    // control torcía la maquetación de los otros seis. Dentro
                    // dice lo mismo y la fila vuelve a estar a una altura.
                    Tooltip(
                      // Lo que hace cada opción no cabe en la píldora, así que
                      // se explica aquí la que esté puesta.
                      message: _limit == untilLastImportLimit
                          ? texts.importLimitSinceLastTooltip
                          : texts.importLimitTooltip,
                      child: FernDropdownPill<int>(
                        value: _limit,
                        items: importLimitOptions,
                        labelBuilder: (limit) =>
                            '${texts.importFetchLabel} '
                            '${importLimitLabel(limit, texts)}',
                        onChanged: (limit) {
                          if (limit == null) return;

                          setState(() => _limit = limit);
                          getIt<PreferencesService>().setImportLimit(limit);
                        },
                      ),
                    ),
                  ],
                  // Con qué parte de lo pendiente se trabaja y en qué
                  // orden: las dos en un solo botón. Son dos preguntas
                  // distintas, pero se contestan juntas, se cambian poco, y
                  // dos desplegables más eran los que dejaban la cabecera
                  // sin sitio.
                  //
                  // Con aire de sobra: son dos controles distintos y
                  // pegados parecían uno partido en dos.
                  const SizedBox(width: AppSpacing.l),
                  ImportViewMenu(
                    filter: _filter,
                    order: _sortOrder,
                    hasMedia: hasMedia,
                    hasCreators: _offersCreators(source),
                    showsCreators: _showCreators,
                    onShowsCreatorsChanged: (creators) =>
                        setState(() => _showCreators = creators),
                    onFilterChanged: (filter) =>
                        setState(() => _filter = filter),
                    onOrderChanged: (order) {
                      setState(() => _sortOrder = order);
                      context.read<MediaBloc>().add(
                        MediaSortOrderChangedEvent(order),
                      );
                    },
                  ),
                  const SizedBox(width: AppSpacing.s),
                  // Buscar contenido en la fuente es siempre lo mismo,
                  // pero el icono dice qué va a pasar: con la rejilla
                  // vacía todavía no ha llegado nada de esta fuente y lo
                  // que se hace es traerlo; con contenido a la vista, lo
                  // que se hace es actualizarlo.
                  IconButton(
                    // En la vista de creadores el botón trae **lo que esté
                    // marcado**, y sin nada marcado, lo de todos: es lo
                    // que hacía la casilla de los ajustes a la que esta
                    // vista sustituye.
                    tooltip: _selectedCreators.isNotEmpty
                        ? texts.remoteCreatorsImport(_selectedCreators.length)
                        : hasMedia
                        ? texts.actionRefresh
                        : texts.actionImport,
                    onPressed: isConfigured && canScan
                        ? () => _selectedCreators.isEmpty
                              ? _scan(context, source)
                              : _importCreators(Set.of(_selectedCreators))
                        : null,
                    icon: Icon(
                      _selectedCreators.isNotEmpty
                          ? Symbols.download
                          : hasMedia
                          ? Symbols.refresh
                          : Symbols.download,
                    ),
                  ),
                  SelectAllButton(
                    visible: visible,
                    selectedIds: state.selectedIds,
                    onSelectAll: (ids) =>
                        context.read<MediaBloc>().add(SelectAllMediaEvent(ids)),
                  ),
                  IconButton(
                    tooltip: texts.actionSelectFolder,
                    onPressed: canPickFolder
                        ? () => context.read<MediaBloc>().add(
                            SelectAndScanDirectoryEvent(limit: _limit),
                          )
                        : null,
                    icon: const Icon(Symbols.folder_open),
                  ),
                ],
              );
            },
          ),

          // GRID
          body: _showsCreatorsMode(source)
              ? _creatorsGrid(texts)
              : MediaGrid(
                  mediaList: visible,
                  columns: mediaGridColumns,
                  isLoading: state.isBusy || _isImporting,
                  // Lo que hay en marcha aquí es traerse contenido: no tapa
                  // nada, así que se puede seguir mirando y tocando lo que ya
                  // ha llegado mientras llega el resto.
                  isImporting: true,
                  returnsToViewed: true,
                  isStopping: _isStopping,
                  // Una importación puede durar mucho, así que se puede parar
                  // desde donde se está mirando cómo va. Lo ya traído se queda.
                  onStop: () => _stop(context),
                ),
        );
      },
    );
  }
}

/// Lo que se puede hacer con lo que está marcado.
///
/// Sustituye a la barra de la pantalla en cuanto hay algo seleccionado, en vez
/// de sumarse a ella. Son dos momentos distintos —traer contenido y decidir
/// sobre el que ya está— y meterlos en la misma fila obligaba a elegir entre
/// que no cupieran o quitar opciones que sí hacen falta.
class _SelectionBar extends StatelessWidget {
  final int selected;
  final int total;
  final VoidCallback onAcceptAbove;
  final VoidCallback onDelete;

  /// El botón de marcarlo todo, que la pantalla arma con lo que hay a la vista.
  final Widget selectAll;

  /// Mandar la selección a los modelos.
  ///
  /// Es el sitio donde más falta hace y donde no estaba: aquí es donde se
  /// revisa lo que acaba de llegar, y lo primero que se quiere de una tanda
  /// recién importada es que los modelos la miren.
  final VoidCallback onRecognize;

  const _SelectionBar({
    required this.selected,
    required this.total,
    required this.onAcceptAbove,
    required this.onDelete,
    required this.selectAll,
    required this.onRecognize,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Row(
      children: [
        // Salir de la selección tiene que estar a mano: es la forma de volver a
        // la barra de antes, y si no se ve, la pantalla parece haberse quedado
        // en otro sitio.
        IconButton(
          tooltip: texts.actionClearSelection,
          onPressed: () =>
              context.read<MediaBloc>().add(const ClearMediaSelectionEvent()),
          icon: const Icon(Symbols.close),
        ),
        selectAll,
        const SizedBox(width: AppSpacing.s),
        Flexible(
          child: Text(
            texts.selectedOfCount(selected, total),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.terciary,
            ),
          ),
        ),
        const Spacer(),
        // Esconder lo marcado detrás del filtro NSFW, igual que en la
        // biblioteca. Aquí hace más falta que allí: es lo primero que se ve de
        // una tanda recién traída, y obligar a confirmarla antes para poder
        // marcarla es obligar a pasarla por la biblioteca sin esconder.
        //
        // Marca, no interruptor: la selección puede mezclar marcado y sin
        // marcar. Para quitarla está el visor, que sabe cómo está cada uno.
        if (getIt<NsfwModeService>().isConfigured) ...[
          IconButton(
            tooltip: texts.mediaNsfwMark,
            onPressed: () => context.read<MediaBloc>().add(
              const SetSelectedMediaNsfwEvent(isNsfw: true),
            ),
            icon: const Icon(Symbols.visibility_off),
          ),
          const SizedBox(width: AppSpacing.s),
        ],
        // Antes que «aceptar los seguros»: para que haya sugerencias que aceptar
        // primero tiene que haber pasado esto.
        FernPillButton(
          label: texts.recognizeSelectedTooltip,
          icon: Symbols.auto_awesome,
          backgroundColor: context.colors.secondary,
          foregroundColor: context.colors.black,
          onPressed: onRecognize,
        ),
        const SizedBox(width: AppSpacing.s),
        // Despachar de golpe lo que los modelos ven con más seguridad. Es lo que
        // hace usable revisar trescientos: decir que sí trescientas veces a lo
        // evidente es lo que hace que nadie revise nada.
        Tooltip(
          message: texts.acceptAboveTooltip(
            (suggestionHighConfidence * 100).round(),
          ),
          child: FernPillButton(
            label: texts.acceptAboveLabel(
              (suggestionHighConfidence * 100).round(),
            ),
            icon: Symbols.done_all,
            backgroundColor: context.colors.secondary,
            foregroundColor: context.colors.black,
            onPressed: onAcceptAbove,
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        FernPillButton(
          label: texts.actionDelete,
          icon: Symbols.delete,
          backgroundColor: context.colors.error,
          foregroundColor: Colors.white,
          onPressed: onDelete,
        ),
        const SizedBox(width: AppSpacing.s),
        FernPillButton(
          label: texts.actionConfirm,
          icon: Symbols.check,
          backgroundColor: context.colors.primary,
          foregroundColor: context.colors.black,
          onPressed: () =>
              context.read<MediaBloc>().add(const ConfirmSelectedMediaEvent()),
        ),
      ],
    );
  }
}

/// Un control con un rótulo encima que dice qué es.
///
/// Dos desplegables uno al lado del otro no se distinguen por su contenido:
/// «Todo» y «Todos» se leen igual, y hay que abrirlos para saber cuál es cuál.
/// El rótulo es lo que evita esa apertura a ciegas.
