import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/ui/dialogs/fern_dialog.dart';
import 'package:Fern/core/ui/display/fern_empty_state.dart';
import 'package:flutter/material.dart';

/// Diálogo de una sola columna con ilustración y mensaje, sin más acción que
/// cerrarlo. Para avisos sueltos, como una función que todavía no existe.
class FernMessageDialog extends StatelessWidget {
  final String imageAsset;
  final String message;
  final double maxWidth;

  const FernMessageDialog({
    super.key,
    required this.imageAsset,
    required this.message,
    this.maxWidth = AppSizes.dialogMaxWidth / 2,
  });

  @override
  Widget build(BuildContext context) {
    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: maxWidth,
      leftContent: FernEmptyState(
        imageAsset: imageAsset,
        message: message,
      ),
    );
  }
}
