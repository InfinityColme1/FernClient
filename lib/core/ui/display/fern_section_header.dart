import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Cabecera de sección: icono + título en color atenuado.
///
/// El icono es opcional, y lo es por sitio: en una columna estrecha con un botón
/// al lado del título, los treinta puntos que ocupa son la diferencia entre que
/// el rótulo del botón quepa entero o salga con puntos suspensivos. Donde hay
/// ancho, se pone; donde no, el título dice lo mismo con palabras.
class FernSectionHeader extends StatelessWidget {
  final IconData? icon;

  /// Icono en forma de imagen del paquete, para lo que no tiene glifo propio.
  /// Manda sobre [icon] cuando viene.

  final String title;
  final Widget? trailing;

  const FernSectionHeader({
    super.key,
    this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: AppSizes.iconMedium, color: context.colors.gray),
          const SizedBox(width: AppSpacing.s),
        ],
        // Con el hueco que quede y recortando si no llega, en vez de con el
        // ancho que pida: la cabecera vive en columnas estrechas y desde que
        // puede llevar un botón al lado, un título largo (en francés lo son
        // todos) la desbordaba por la derecha.
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: context.colors.gray),
          ),
        ),
        // Con aire entre el título y lo que lleve al lado: pegados, un título
        // largo y un botón se leen como una sola cosa.
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.s),
          trailing!,
        ],
      ],
    );
  }
}
