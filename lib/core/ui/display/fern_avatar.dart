import 'dart:io';

import 'package:Fern/config/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Avatar circular que muestra la imagen de un fichero local y, cuando no hay
/// imagen, un icono de reserva.
///
/// Centraliza el patrón `CircleAvatar` + `FileImage` + icono que estaba
/// repetido en los diálogos y en el panel de información.
class FernAvatar extends StatelessWidget {
  /// Ruta a la imagen en disco. Si es `null` se muestra [fallbackIcon].
  final String? imagePath;
  final IconData fallbackIcon;

  /// Icono de reserva en forma de imagen del paquete, para lo que no tiene
  /// glifo propio. Manda sobre [fallbackIcon] cuando viene.
  final double radius;

  /// Tamaño del icono de reserva. Por defecto igual al radio.
  final double? iconSize;
  /// Sin decir nada, los colores de la paleta que esté puesta.
  final Color? backgroundColor;
  final Color? iconColor;

  const FernAvatar({
    super.key,
    this.imagePath,
    required this.fallbackIcon,
    required this.radius,
    this.iconSize,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null;

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? context.colors.secondary,
      backgroundImage: hasImage ? FileImage(File(imagePath!)) : null,
      child: hasImage
          ? null
          : Icon(
              fallbackIcon,
              size: iconSize ?? radius,
              color: iconColor ?? context.colors.primary,
            ),
    );
  }
}
