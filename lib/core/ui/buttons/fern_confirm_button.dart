import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/core/ui/display/fern_progress_indicator.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Botón de confirmación de los diálogos.
///
/// Sin [label] pone "Confirmar" en el idioma de la aplicación, que es lo que
/// dice en casi todos los diálogos.
class FernConfirmButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;

  /// Lo que se ha confirmado se está guardando: el botón pasa a ser el indicador
  /// de espera y deja de responder, que ya está guardándose lo que se le pidió.
  final bool isBusy;

  const FernConfirmButton({
    super.key,
    this.onPressed,
    this.label,
    this.icon = Symbols.check,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(label ?? AppLocalizations.of(context).actionConfirm);

    if (isBusy) {
      // El indicador ocupa el sitio del icono y el texto se queda donde estaba:
      // el botón mantiene su tamaño, así que empezar a guardar no recoloca nada.
      // Y conserva su color, que sigue siendo el botón de confirmar aunque de
      // momento no atienda.
      return ElevatedButton.icon(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: context.colors.primary,
          disabledForegroundColor: context.colors.black,
        ),
        icon: FernProgressIndicator.small(color: context.colors.black),
        label: text,
      );
    }

    if (icon == null) {
      return ElevatedButton(
        onPressed: onPressed,
        child: text,
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: text,
    );
  }
}
