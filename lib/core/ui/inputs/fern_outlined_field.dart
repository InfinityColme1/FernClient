import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/ui/inputs/fern_field_label.dart';
import 'package:flutter/material.dart';

/// Marco con contorno y etiqueta flotante que envuelve cualquier campo de
/// entrada (texto, buscador, desplegable...).
class FernOutlinedField extends StatelessWidget {
  final String label;
  final Widget child;

  const FernOutlinedField({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.black, width: 2),
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: child,
        ),
        Positioned(
          top: -10,
          left: 12,
          child: FernFieldLabel(text: label),
        ),
      ],
    );
  }
}
