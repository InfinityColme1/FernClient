import 'package:flutter/material.dart';

/// Botón de confirmación de los diálogos.
class FernConfirmButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;

  const FernConfirmButton({
    super.key,
    this.onPressed,
    this.label = "Confirm",
    this.icon = Icons.check,
  });

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
