import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/utils/file_size.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/settings/domain/usecases/sweep_unused_files_usecase.dart';
import 'package:Fern/features/settings/presentation/widgets/cleanup_confirm_dialog.dart';
import 'package:Fern/features/settings/data/services/leftover_files.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/tags_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/tags_events.dart';
import 'package:Fern/features/settings/presentation/widgets/wipe_database_dialog.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/data/models/blocked_import_model.dart';
import 'package:Fern/features/media/data/services/blocked_imports.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_symbols_icons/symbols.dart';

/// La base de datos: por ahora, vaciarla.
///
/// Es la única sección de los ajustes que no cambia cómo se comporta la
/// aplicación sino que **destruye** algo, así que va al final de la lista y con
/// el botón del color de lo que no se puede deshacer.
class DatabaseSettingsSection extends StatefulWidget {
  const DatabaseSettingsSection({super.key});

  @override
  State<DatabaseSettingsSection> createState() =>
      _DatabaseSettingsSectionState();
}

class _DatabaseSettingsSectionState extends State<DatabaseSettingsSection> {
  final _blocked = getIt<BlockedImports>();

  List<BlockedImportModel> _rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await _blocked.all();
    if (!mounted) return;

    setState(() => _rows = rows);
  }

  Future<void> _unblock(int id) async {
    await _blocked.unblock(id);
    await _load();
  }

  Future<void> _unblockAll() async {
    await _blocked.clear();
    await _load();
  }

  /// Si la limpieza está en marcha. Barrer una carpeta con miles de ficheros
  /// tarda, y sin esto el botón se puede pulsar tres veces seguidas.
  bool _isSweeping = false;

  /// Se lleva los ficheros de la carpeta de trabajo que ya no usa nadie.
  ///
  /// **Mira primero y pregunta.** Con los avatares no hacía falta —son copias
  /// nuestras— pero aquí se van también descargas cuya fila ya no está, y ésas
  /// se pueden querer rescatar antes. Un fichero borrado no vuelve.
  Future<void> _sweep(BuildContext context) async {
    if (_isSweeping) return;

    setState(() => _isSweeping = true);

    final usecase = getIt<SweepUnusedFilesUseCase>();
    final found = await usecase.find();

    if (!mounted) return;
    setState(() => _isSweeping = false);
    if (!context.mounted) return;

    final texts = AppLocalizations.of(context);

    if (found is! DataSuccess || found.data == null) {
      showFernToast(context, texts.databaseCleanupFailed, icon: Symbols.error);
      return;
    }

    final plan = found.data!;

    // Nada suelto: se dice y se acaba, sin abrir un aviso para no hacer nada.
    if (plan.isEmpty) {
      showFernToast(
        context,
        texts.databaseCleanupDone(0, formatFileWeight(0)),
        icon: Symbols.mop,
      );
      return;
    }

    final confirmed = await showFernDialog<bool, MediaBloc>(
      context: context,
      builder: (_) => CleanupConfirmDialog(plan: plan),
    );

    if (confirmed != true || !context.mounted) return;

    final swept = await usecase.sweep(plan);
    if (!context.mounted) return;

    if (swept case DataSuccess(:final data?)) {
      showFernToast(
        context,
        texts.databaseCleanupDone(data.files, formatFileWeight(data.bytes)),
        icon: Symbols.mop,
      );
      return;
    }

    showFernToast(context, texts.databaseCleanupFailed, icon: Symbols.error);
  }

  /// Dos diálogos, no uno: primero qué hace esto, y sólo después la frase.
  ///
  /// El primero puede cerrarse sin más; del segundo sólo se sale escribiendo la
  /// frase entera o cerrándolo.
  Future<void> _wipe(BuildContext context) async {
    final understood = await showFernDialog<bool, MediaBloc>(
      context: context,
      builder: (_) => const WipeDatabaseWarningDialog(),
    );

    if (understood != true || !context.mounted) return;

    final wiped = await showFernDialog<bool, MediaBloc>(
      context: context,
      builder: (_) => const WipeDatabaseConfirmDialog(),
    );

    if (wiped != true || !context.mounted) return;

    // Lo que estuviera pintado habla de una base de datos que ya no existe. Sin
    // releer, la rejilla y el menú siguen enseñando etiquetas y contenidos que
    // no están, y el primer clic sobre cualquiera de ellos falla.
    getIt<TagsBloc>().add(const LoadTagsEvent());
    getIt<MediaBloc>().add(const ReloadCurrentMediaEvent());

    // La lista de bloqueos es de esta misma pantalla y también se ha ido con el
    // vaciado: sin releerla se quedarían pintadas filas que ya no existen, y su
    // aspa iría a borrar algo que no está.
    await _load();

    if (!context.mounted) return;

    showFernToast(context, AppLocalizations.of(context).databaseWipeDone);
  }

  /// Lo que se ha dicho que no se vuelva a importar, con su aspa para deshacerlo.
  ///
  /// Un bloqueo que no se puede ver ni deshacer es una trampa: si el usuario se
  /// arrepiente no hay forma de volver a importar eso nunca. Va aquí porque es
  /// mantenimiento de la base, que es de lo que trata esta sección.
  Widget _blockedList(BuildContext context, AppLocalizations texts) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(texts.blockedImportsTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.s),
        Text(
          texts.blockedImportsNote,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.colors.gray,
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        if (_rows.isEmpty)
          Text(
            texts.blockedImportsNone,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.colors.unremarked,
            ),
          )
        else ...[
          // Con tope y desplazamiento propio: doscientos bloqueos no pueden
          // empujar el botón de vaciar fuera del diálogo.
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: blockedListMaxHeight),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _rows.length,
              itemBuilder: (context, index) =>
                  _blockedRow(context, _rows[index]),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Align(
            alignment: Alignment.centerLeft,
            child: FernPillButton(
              label: texts.blockedImportsClear,
              icon: Symbols.restart_alt,
              backgroundColor: context.colors.secondary,
              foregroundColor: context.colors.black,
              onPressed: _unblockAll,
            ),
          ),
        ],
      ],
    );
  }

  /// La limpieza de lo que sobra en el disco.
  ///
  /// Va aquí y no en la sección de ficheros porque lo que decide qué sobra es la
  /// base de datos: un avatar está de más cuando no lo apunta ninguna ficha.
  Widget _cleanup(BuildContext context, AppLocalizations texts) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(texts.databaseCleanupTitle, style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.s),
        Text(
          texts.databaseCleanupNote,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.colors.gray,
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        Align(
          alignment: Alignment.centerLeft,
          child: FernPillButton(
            label: texts.databaseCleanupAction,
            icon: Symbols.mop,
            backgroundColor: context.colors.secondary,
            foregroundColor: context.colors.black,
            // Apagado mientras barre: la carpeta puede tener miles de ficheros,
            // y sin esto el botón se pulsa tres veces seguidas.
            onPressed: _isSweeping ? null : () => _sweep(context),
          ),
        ),
      ],
    );
  }

  /// Abre la página de la que salió, en el navegador del sistema.
  ///
  /// Se le pone `https://` a lo que no traiga protocolo, como el resto de
  /// enlaces de la aplicación: sin él el sistema no sabe a qué aplicación
  /// dárselo.
  Future<void> _open(String link) async {
    final value = link.trim();
    if (value.isEmpty) return;

    final uri = Uri.tryParse(value.contains('://') ? value : 'https://$value');
    if (uri == null) return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _blockedRow(BuildContext context, BlockedImportModel row) {
    final theme = Theme.of(context);

    // Se puede volver a ver lo que se olvidó, si se guardó de dónde salía. Por
    // el nombre del fichero no se reconoce nada, y si se olvidó por error hacía
    // falta poder mirarlo antes de decidir si se recupera.
    //
    // Lo bloqueado antes de que esto se guardara no lleva dirección: esa fila se
    // queda como estaba, sin pulsar. Prometer un enlace que no lleva a ninguna
    // parte sería peor.
    final url = row.sourceUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: url == null
                ? Text(
                    '${row.source} · ${row.description ?? row.remoteId}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  )
                : Tooltip(
                    message: texts(context).blockedImportsOpen,
                    child: InkWell(
                      onTap: () => _open(url),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusSmall),
                      child: Text(
                        // De dónde era y qué era: el identificador a secas no le
                        // dice nada a nadie.
                        '${row.source} · ${row.description ?? row.remoteId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.colors.primary,
                          decoration: TextDecoration.underline,
                          decorationColor: context.colors.primary,
                        ),
                      ),
                    ),
                  ),
          ),
          IconButton(
            icon: const Icon(Symbols.close, size: AppSizes.iconCompact),
            tooltip: texts(context).blockedImportsUnblock,
            visualDensity: VisualDensity.compact,
            onPressed: () => _unblock(row.id),
          ),
        ],
      ),
    );
  }

  AppLocalizations texts(BuildContext context) => AppLocalizations.of(context);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(texts.databaseSectionTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Text(
            texts.databaseSectionNote,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.colors.gray,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(texts.databaseWipeTitle, style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.s),
          Text(
            texts.databaseWipeSectionNote,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.colors.gray,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          // No ocupa el ancho entero: un botón de borrarlo todo del tamaño del de
          // guardar se pulsa por costumbre.
          Align(
            alignment: Alignment.centerLeft,
            child: FernPillButton(
              label: texts.databaseWipeAction,
              icon: Symbols.delete_forever,
              backgroundColor: context.colors.error,
              foregroundColor: context.colors.white,
              onPressed: () => _wipe(context),
            ),
          ),
            const SizedBox(height: AppSpacing.xxl),
          _cleanup(context, texts),
          const SizedBox(height: AppSpacing.xxl),
          _blockedList(context, texts),
        ],
      ),
    );
  }
}
