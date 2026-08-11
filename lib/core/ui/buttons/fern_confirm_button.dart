import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Botón de confirmación de los diálogos.
///
/// Sin [label] pone "Confirmar" en el idioma de la aplicación, que es lo que
/// dice en casi todos los diálogos.
class FernConfirmButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;
  final IconData? icon;

  const FernConfirmButton({
    super.key,
    this.onPressed,
    this.label,
    this.icon = Icons.check,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(label ?? AppLocalizations.of(context).actionConfirm);

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
