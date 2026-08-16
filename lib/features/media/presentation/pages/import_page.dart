import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
// Experimental: de aquí sale a dónde se manda al usuario a iniciar sesión.
import 'package:Fern/features/browser/domain/entities/browser_session_source.dart';
import 'package:Fern/features/browser/presentation/widgets/session_expired_dialog.dart';
import 'package:Fern/features/media/domain/entities/empty_source.dart';
import 'package:Fern/features/media/domain/entities/import_source.dart';
import 'package:Fern/features/media/domain/entities/media_deletion_kind.dart';
import 'package:Fern/features/media/presentation/widgets/confirm_delete_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/confirm_remote_import_dialog.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/features/settings/presentation/widgets/settings_dialog.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_states.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
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
  /// Tope de contenidos nuevos que se trae el próximo escaneo.
  ///
  /// Es de la pantalla y no del bloc: no cambia lo que se está viendo, sólo
  /// cuánto se pide la próxima vez. De partida no hay tope, que es traerse todo
  /// lo que haya.
  int _limit = unlimitedImportLimit;

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
      return texts.lastImportMinutes(elapsed.isNegative ? 0 : elapsed.inMinutes);
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
  ({String label, String hint, IconData icon, VoidCallback? onTap})? _sourceNote(
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
          icon: Icons.login,
          onTap: () => context.go(browserRouteWithUrl(login.loginUrl)),
        );
      }

      return (
        label: texts.sourceNotConfigured,
        hint: texts.sourceNotConfiguredHint,
        icon: Icons.info_outline,
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
        icon: Icons.travel_explore_outlined,
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
      icon: Icons.history,
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
    final color = isLink ? AppColors.terciary : AppColors.gray;

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
        builder: (_) => ConfirmRemoteImportDialog(
          sources: remote,
          limit: _limit,
        ),
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
      builder: (_) => const SettingsDialog(
        initialSection: SettingsSection.remoteSources,
      ),
    );
  }

  /// Descarta la selección, avisando antes de que va a salir de la aplicación y
  /// preguntando qué se hace con sus ficheros. Si se cancela no se toca nada.
  Future<void> _discardSelection(BuildContext context, int count) async {
    final bloc = context.read<MediaBloc>();

    final deleteFiles = await showFernDialog<bool, MediaBloc>(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        kind: MediaDeletionKind.discard,
        count: count,
      ),
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
        final hasMedia = state.mediaList != null && state.mediaList!.isNotEmpty;
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

        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.l, left: AppSpacing.l),
          child: Column(
            children: [
              // HEADER ROW DINÁMICA
              Padding(
                padding: const EdgeInsets.only(
                  right: AppSpacing.xl,
                  bottom: AppSpacing.l,
                ),
                child: BlocBuilder<SettingsBloc, SettingsState>(
                  bloc: getIt<SettingsBloc>(),
                  builder: (context, settings) {
                    final isConfigured = _isConfigured(source, settings);

                    return Row(
                      children: [
                        FernDropdownPill<ImportSource>(
                          value: source,
                          items: const [ImportSource.all, ...ImportSource.listed],
                          labelBuilder: (source) => source.name(texts),
                          onChanged: (source) {
                            if (source == null) return;
                            context
                                .read<MediaBloc>()
                                .add(ImportSourceChangedEvent(source));
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
                        if (hasMedia) ...[
                          if (hasSelection) ...[
                            Text(
                              texts.selectedCount(selectedCount),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.terciary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.l),
                          ],
                          Text(
                            texts.mediaFetched(state.mediaList!.length),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                        ],

                        // RIGHT: Actions
                        //
                        // Cuántos contenidos nuevos se trae el escaneo como
                        // mucho. Vale para cualquier fuente que se escanee: es un
                        // tope de lo que se descarga, no una cosa de las remotas.
                        // De la que no se escanea no se enseña, que ahí no hay
                        // nada que topar.
                        if (canScan) ...[
                          Tooltip(
                            // Lo que hace cada opción no cabe en la píldora, así
                            // que se explica aquí la que esté puesta.
                            message: _limit == untilLastImportLimit
                                ? texts.importLimitSinceLastTooltip
                                : texts.importLimitTooltip,
                            child: FernDropdownPill<int>(
                              value: _limit,
                              items: importLimitOptions,
                              labelBuilder: (limit) =>
                                  importLimitLabel(limit, texts),
                              onChanged: (limit) {
                                if (limit == null) return;
                                setState(() => _limit = limit);
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                        ],
                        // Buscar contenido en la fuente es siempre lo mismo,
                        // pero el icono dice qué va a pasar: con la rejilla
                        // vacía todavía no ha llegado nada de esta fuente y lo
                        // que se hace es traerlo; con contenido a la vista, lo
                        // que se hace es actualizarlo.
                        IconButton(
                          tooltip: hasMedia
                              ? texts.actionRefresh
                              : texts.actionImport,
                          onPressed: isConfigured && canScan
                              ? () => _scan(context, source)
                              : null,
                          icon: Icon(
                            hasMedia ? Icons.refresh : Icons.download_outlined,
                          ),
                        ),
                        IconButton(
                          tooltip: texts.actionSelectFolder,
                          onPressed: canPickFolder
                              ? () => context
                                  .read<MediaBloc>()
                                  .add(SelectAndScanDirectoryEvent(limit: _limit))
                              : null,
                          icon: const Icon(Icons.folder_open_outlined),
                        ),
                        if (hasMedia) ...[
                          const SizedBox(width: AppSpacing.s),
                          FernPillButton(
                            label: texts.actionDelete,
                            icon: Icons.delete_outline,
                            backgroundColor: AppColors.terciary,
                            foregroundColor: AppColors.white,
                            onPressed: hasSelection
                                ? () => _discardSelection(context, selectedCount)
                                : null,
                          ),
                          const SizedBox(width: AppSpacing.s),
                          FernPillButton(
                            label: texts.actionConfirm,
                            icon: Icons.check,
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.black,
                            onPressed: hasSelection
                                ? () => context
                                    .read<MediaBloc>()
                                    .add(const ConfirmSelectedMediaEvent())
                                : null,
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),

              // GRID
              Expanded(
                child: MediaGrid(
                  mediaList: state.mediaList ?? [],
                  columns: 4,
                  isLoading: state.isBusy,
                  // Una importación puede durar mucho, así que se puede parar
                  // desde donde se está mirando cómo va. Lo ya traído se queda.
                  onStop: () =>
                      context.read<MediaBloc>().add(const StopImportEvent()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
