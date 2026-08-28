import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/inputs/fern_outlined_field.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Selector de carpeta: la ruta elegida a la izquierda y un botón para abrir el
/// explorador a la derecha, dentro del marco con etiqueta flotante del resto de
/// campos.
///
/// Mientras no haya ruta se enseña [hintText] (o el aviso traducido de que no
/// hay carpeta elegida) en tono apagado, igual que un campo de texto vacío.
class FernDirectoryField extends StatelessWidget {
  final String label;
  final String? path;
  final String? hintText;
  final VoidCallback? onPressed;

  const FernDirectoryField({
    super.key,
    required this.label,
    this.path,
    this.hintText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);
    final hasPath = path != null && path!.isNotEmpty;

    return Opacity(
      opacity: onPressed == null ? disabledOptionOpacity : 1.0,
      child: FernOutlinedField(
        label: label,
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.l,
            top: AppSpacing.s,
            bottom: AppSpacing.s,
            right: AppSpacing.s,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasPath ? path! : (hintText ?? texts.noFolderSelected),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: hasPath ? context.colors.black : context.colors.lightgray,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              IconButton(
                onPressed: onPressed,
                tooltip: texts.chooseFolder,
                icon: const Icon(
                  Symbols.folder_open,
                  size: AppSizes.iconMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
