import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/utils/file_size.dart';
import 'package:Fern/features/settings/data/services/leftover_files.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Qué se va a borrar de la carpeta de trabajo, antes de borrarlo.
///
/// Se pregunta —a diferencia de lo que se hacía sólo con los avatares— porque
/// aquí se van también **descargas** cuya fila ya no está en la base, y ésas se
/// pueden querer rescatar. Un fichero borrado no vuelve.
///
/// Se desglosa por clase y no como un solo número: cien avatares son unos megas
/// y cien descargas pueden ser gigas, así que el total a secas no basta para
/// decidir.
class CleanupConfirmDialog extends StatelessWidget {
  final LeftoverPlan plan;

  const CleanupConfirmDialog({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(false),
      maxWidth: AppSizes.dialogMaxWidth / 2,
      leftContent: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              texts.databaseCleanupFound(
                plan.files,
                formatFileWeight(plan.bytes),
              ),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.l),

            _line(context, texts.databaseCleanupAvatars, plan.avatars),
            _line(context, texts.databaseCleanupDownloads, plan.downloads),
            _line(context, texts.databaseCleanupWeights, plan.weights),

            const SizedBox(height: AppSpacing.l),
            Text(
              // Lo que no se toca, dicho a las claras: es lo que evita la duda
              // de si esto se lleva por delante el reconocimiento.
              texts.databaseCleanupKeeps,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.colors.gray,
              ),
            ),
          ],
        ),
      ),
      actionButton: FernPillButton(
        label: texts.databaseCleanupAction,
        icon: Symbols.mop,
        backgroundColor: context.colors.error,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }

  /// Una clase de fichero, con cuántos y cuánto ocupan.
  ///
  /// Las que no tienen nada no se pintan: una línea con un cero es ruido.
  Widget _line(BuildContext context, String label, List<Leftover> files) {
    if (files.isEmpty) return const SizedBox.shrink();

    final bytes = files.fold<int>(0, (sum, each) => sum + each.bytes);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: AppSpacing.m),
          Text(
            '${files.length} · ${formatFileWeight(bytes)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.colors.unremarked,
                ),
          ),
        ],
      ),
    );
  }
}
