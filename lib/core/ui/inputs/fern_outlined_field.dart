import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/inputs/fern_field_label.dart';
import 'package:flutter/material.dart';

/// Marco de campo con su rótulo encima, para lo que no es un campo de texto:
/// buscadores con desplegable, selectores de carpeta, y lo que venga.
///
/// **Se ve igual que un campo de texto normal, y ésa es toda su razón de ser.**
/// El marco no se pinta con colores propios sino con los del tema de los campos
/// de texto, así que un buscador y un campo de nombre puestos uno debajo del
/// otro son la misma caja con cosas distintas dentro. Antes este marco llevaba
/// un contorno grueso del color del texto y el rótulo colgado del borde: en un
/// diálogo con los dos, éste se llevaba toda la atención sin merecerla más que
/// el otro.
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
    // El marco se copia del tema de los campos de texto en vez de repetir sus
    // colores aquí: es lo que hace que los dos se vean iguales hoy y que sigan
    // viéndose iguales cuando alguien toque el tema.
    final input = Theme.of(context).inputDecorationTheme;
    final border = input.border;

    final side = border is OutlineInputBorder
        ? border.borderSide
        : BorderSide(
            color: context.colors.outline,
            width: AppSizes.borderHairline,
          );

    final radius = border is OutlineInputBorder
        ? border.borderRadius
        : BorderRadius.circular(AppSizes.radiusMedium);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sin rótulo no se deja el hueco: hay campos que ya vienen explicados
        // por lo que tienen al lado.
        if (label.isNotEmpty) ...[
          FernFieldLabel(text: label),
          const SizedBox(height: AppSpacing.s),
        ],
        // **El fondo y el borde se pintan aquí y sólo aquí.** Lo que va dentro
        // no pinta ninguno de los dos: dos rellenos superpuestos no se notan en
        // los lados rectos —son del mismo color— pero en las esquinas el de
        // dentro, que es recto, se come la curva del de fuera.
        //
        // Un `Container` y no un `DecoratedBox` por una razón sola: aquél mete
        // el contenido **por dentro** del trazo, así que lo que se escriba no se
        // apoya en el borde.
        Container(
          decoration: BoxDecoration(
            color: input.filled ? input.fillColor : null,
            border: Border.fromBorderSide(side),
            borderRadius: radius,
          ),
          child: child,
        ),
      ],
    );
  }
}
