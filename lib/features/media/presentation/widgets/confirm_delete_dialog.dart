import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/core/services/preferences_service.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media_deletion_kind.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/l10n/app_localizations.dart';
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
  MediaEntity media,
) async {
  final bloc = context.read<MediaBloc>();

  if (media.isImported) {
    bloc.add(DeleteMediaEvent(media));
    return true;
  }

  final deleteFiles = await showFernDialog<bool, MediaBloc>(
    context: context,
    builder: (_) => const ConfirmDeleteDialog(
      kind: MediaDeletionKind.discard,
      count: 1,
    ),
  );
  if (deleteFiles == null) return false;

  bloc.add(DeleteMediaEvent(media, deleteFiles: deleteFiles));
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

  final deleteFiles = await showFernDialog<bool, MediaBloc>(
    context: context,
    builder: (_) => const ConfirmDeleteDialog(
      kind: MediaDeletionKind.trash,
      count: 1,
    ),
  );
  if (deleteFiles == null) return;

  bloc.add(PurgeMediaEvent(media, deleteFiles: deleteFiles));
}

/// Aviso previo a sacar contenido de la base de datos.
///
/// Se cierra de dos maneras y quien lo abre las distingue: con `null` cuando se
/// cancela (el aspa, la tecla de escape, pulsar fuera) y con un booleano cuando
/// se confirma, que dice si los ficheros del disco se van con las filas.
///
/// La casilla arranca como quedó la última vez y su valor se recuerda al
/// confirmar, así que quien siempre borra igual la marca una sola vez. No se
/// recuerda al cancelar: lo que no se ha llegado a hacer no dice nada de lo que
/// se quiere hacer la próxima vez.
class ConfirmDeleteDialog extends StatefulWidget {
  final MediaDeletionKind kind;

  /// Cuántos contenidos se van a borrar, para que el aviso diga a qué se está
  /// diciendo que sí.
  final int count;

  const ConfirmDeleteDialog({
    super.key,
    required this.kind,
    required this.count,
  });

  @override
  State<ConfirmDeleteDialog> createState() => _ConfirmDeleteDialogState();
}

class _ConfirmDeleteDialogState extends State<ConfirmDeleteDialog> {
  final _preferences = getIt<PreferencesService>();

  late bool _deleteFiles = _preferences.getDeleteFiles(widget.kind);

  void _confirm(BuildContext context) {
    _preferences.setDeleteFiles(widget.kind, _deleteFiles);
    Navigator.of(context).pop(_deleteFiles);
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      leftContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            switch (widget.kind) {
              MediaDeletionKind.trash => texts.deleteTrashWarning(widget.count),
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
        ],
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
