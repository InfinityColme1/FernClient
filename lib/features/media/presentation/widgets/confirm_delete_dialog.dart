import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/entities/media_deletion_kind.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:Fern/features/media/data/services/blocked_imports.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Borra el contenido que se está viendo, avisando cuando haga falta.
///
/// Si todavía está pendiente de revisar se descarta, y eso lo saca de la base de
/// datos: antes se avisa y se pregunta qué se hace con su fichero. Si ya es
/// definitivo sólo se marca para borrar, así que no hay nada de lo que avisar;
/// su momento llega en la pantalla de eliminados.
///
/// Devuelve si se ha llegado a pedir el borrado, que es lo que mira quien tenga
/// que cerrar el visor detrás.
Future<bool> deleteMediaWithConfirmation(
  BuildContext context,
  MediaEntity media, {
  /// Con `true`, el visor se queda en el siguiente en vez de cerrarse.
  bool goToNext = false,
}) async {
  final bloc = context.read<MediaBloc>();

  if (media.isImported) {
    bloc.add(DeleteMediaEvent(media, goToNext: goToNext));
    return true;
  }

  final decision = await showFernDialog<DeleteDecision, MediaBloc>(
    context: context,
    builder: (_) => ConfirmDeleteDialog(
      kind: MediaDeletionKind.discard,
      count: 1,
      canBlockImport: media.importSource.isRemote,
    ),
  );
  if (decision == null) return false;

  if (decision.blocksImport) await blockImportOf(context, [media.id]);
  if (!context.mounted) return true;

  bloc.add(DeleteMediaEvent(
    media,
    deleteFiles: decision.deletesFiles,
    goToNext: goToNext,
  ));
  return true;
}

/// Borra del todo el contenido que se está viendo, el que ya estaba marcado.
///
/// Es el mismo aviso que vaciar la papelera entera, con su misma casilla y su
/// mismo valor recordado: borrar desde el visor no es otra clase de borrado,
/// es el mismo sobre un solo contenido.
Future<void> purgeMediaWithConfirmation(
  BuildContext context,
  MediaEntity media,
) async {
  final bloc = context.read<MediaBloc>();

  final decision = await showFernDialog<DeleteDecision, MediaBloc>(
    context: context,
    builder: (_) => const ConfirmDeleteDialog(
      kind: MediaDeletionKind.trash,
      count: 1,
    ),
  );
  if (decision == null) return;

  bloc.add(PurgeMediaEvent(media, deleteFiles: decision.deletesFiles));
}

/// Apunta que estos contenidos no se vuelvan a importar.
///
/// Lo que se guarda es el identificador de la pieza **en su fuente**, que es lo
/// que la fuente da antes de descargar: así el bloqueo se resuelve sin bajar el
/// fichero.
Future<void> blockImportOf(BuildContext context, List<int> mediaIds) async {
  final blocked = getIt<BlockedImports>();
  final summaries = context.read<MediaBloc>().state.mediaList ?? const [];

  for (final id in mediaIds) {
    final summary = summaries.where((each) => each.id == id).firstOrNull;
    if (summary == null || !summary.importSource.isRemote) continue;

    final remoteId = remoteIdOf(summary);
    if (remoteId == null) continue;

    await blocked.block(
      source: summary.importSource.id,
      remoteId: remoteId,
      // El nombre del fichero como descripción: es lo único que el sumario sabe
      // de la pieza, y en la lista de Ajustes es más útil que el identificador
      // pelado repetido dos veces.
      description: p.basename(summary.path),
      // Y de dónde salió, para poder volver a verla desde Ajustes. Por el
      // nombre del fichero no se reconoce lo que se olvidó, y si se olvidó por
      // error no habría forma de recuperarlo.
      sourceUrl: summary.sourceUrl,
    );
  }
}

/// Con qué nombre conoce la fuente a este contenido, o `null` si no hay forma
/// de saberlo.
///
/// Lo normal es que esté guardado, y entonces no hay nada que deducir. El
/// respaldo es para **lo que entró antes de que se guardara**, que es la
/// biblioteca entera de quien ya tenía la aplicación: al descargar, el fichero
/// se guarda con el identificador por nombre (`<id>.<extensión>`, ver
/// `RemoteMediaDownloader`), y lo que está pendiente de revisar conserva ese
/// nombre porque los ficheros sólo se recolocan al darlos por definitivos.
///
/// La extensión se quita **sólo si es una de las que la aplicación descarga**:
/// cortando por el último punto, un identificador que llevara uno dentro se
/// quedaría a medias, y un bloqueo con un identificador a medias no se dispara
/// nunca ni avisa de que no lo hace.
String? remoteIdOf(MediaSummaryEntity summary) {
  if (summary.remoteId case final stored? when stored.isNotEmpty) return stored;

  final name = p.basename(summary.path);
  final extension = p.extension(name).toLowerCase();

  if (!mediaExtensions.contains(extension) &&
      !archiveExtensions.contains(extension)) {
    return name.isEmpty ? null : name;
  }

  final bare = name.substring(0, name.length - extension.length);

  return bare.isEmpty ? null : bare;
}

/// Lo que se ha decidido en el aviso de borrado.
///
/// Dos decisiones **independientes**: se puede no volver a importar algo y
/// conservar su fichero, y se puede borrar el fichero sin bloquear nada.
class DeleteDecision {
  /// Los ficheros del disco se van con las filas.
  final bool deletesFiles;

  /// No volver a ofrecer esto en las próximas importaciones.
  final bool blocksImport;

  const DeleteDecision({
    required this.deletesFiles,
    this.blocksImport = false,
  });
}

/// Aviso previo a sacar contenido de la base de datos.
///
/// Se cierra de dos maneras y quien lo abre las distingue: con `null` cuando se
/// cancela (el aspa, la tecla de escape, pulsar fuera) y con una [DeleteDecision]
/// cuando se confirma.
///
/// Las casillas arrancan como quedaron la última vez y su valor se recuerda al
/// confirmar, así que quien siempre borra igual las marca una sola vez. No se
/// recuerda al cancelar: lo que no se ha llegado a hacer no dice nada de lo que
/// se quiere hacer la próxima vez.
class ConfirmDeleteDialog extends StatefulWidget {
  final MediaDeletionKind kind;

  /// Cuántos contenidos se van a borrar, para que el aviso diga a qué se está
  /// diciendo que sí.
  final int count;

  /// Si se ofrece no volver a importarlo.
  ///
  /// Sólo tiene sentido descartando algo que ha venido de una fuente remota: es
  /// la fuente la que lo tiene guardado y lo vuelve a ofrecer en cada
  /// importación. Un contenido local no tiene dirección que bloquear, y ahí la
  /// casilla no aparece en vez de salir apagada sin explicar por qué.
  final bool canBlockImport;

  const ConfirmDeleteDialog({
    super.key,
    required this.kind,
    required this.count,
    this.canBlockImport = false,
  });

  @override
  State<ConfirmDeleteDialog> createState() => _ConfirmDeleteDialogState();
}

class _ConfirmDeleteDialogState extends State<ConfirmDeleteDialog> {
  final _preferences = getIt<PreferencesService>();

  late bool _deleteFiles = _preferences.getDeleteFiles(widget.kind);
  late bool _blocksImport = _preferences.getBlocksImportOnDiscard();

  void _confirm(BuildContext context) {
    _preferences.setDeleteFiles(widget.kind, _deleteFiles);
    if (widget.canBlockImport) {
      _preferences.setBlocksImportOnDiscard(_blocksImport);
    }

    Navigator.of(context).pop(DeleteDecision(
      deletesFiles: _deleteFiles,
      blocksImport: widget.canBlockImport && _blocksImport,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      // Desplazable: el diálogo le da a su contenido la altura que sobra, y con
      // la segunda casilla puesta son dos explicaciones más el aviso. En una
      // ventana baja lo que no quepa se desplaza en vez de desbordarse.
      leftContent: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              switch (widget.kind) {
                MediaDeletionKind.trash =>
                  texts.deleteTrashWarning(widget.count),
                MediaDeletionKind.discard =>
                  texts.deleteDiscardWarning(widget.count),
              },
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.l),
            FernCheckboxTile(
              label: texts.deleteFilesFromDisk,
              description: texts.deleteFilesFromDiskDescription,
              value: _deleteFiles,
              onChanged: (value) => setState(() => _deleteFiles = value),
            ),
            // Independiente de la de arriba a propósito: no volver a querer algo
            // y querer su fichero fuera del disco son dos decisiones distintas,
            // y atarlas obligaría a tomar una para tomar la otra.
            if (widget.canBlockImport) ...[
              const SizedBox(height: AppSpacing.m),
              FernCheckboxTile(
                label: texts.blockImportAgain,
                description: texts.blockImportAgainDescription,
                value: _blocksImport,
                onChanged: (value) => setState(() => _blocksImport = value),
              ),
            ],
          ],
        ),
      ),
      actionButton: FernPillButton(
        label: texts.actionDelete,
        icon: Symbols.delete,
        backgroundColor: context.colors.error,
        foregroundColor: Colors.white,
        onPressed: () => _confirm(context),
      ),
    );
  }
}
