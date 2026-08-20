import 'dart:io';

import 'package:Fern/config/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// El icono de reserva de un avatar o de una cabecera: el glifo de siempre, o
/// una imagen del paquete cuando lo que hay que pintar no tiene glifo.
///
/// Se tiñe igual en los dos casos, así que la imagen tiene que ser una silueta
/// de un solo color, como cualquier icono.
Widget fernFallbackIcon(
  BuildContext context, {
  required IconData icon,
  required double size,
  String? asset,
  Color? color,
}) {
  if (asset == null) return Icon(icon, size: size, color: color);

  // Va con `Image` y no con `ImageIcon` por la calidad del filtro: aquél no deja
  // elegirla y se queda con la de por defecto, que en una imagen que hay que
  // reducir a la mitad o menos se nota en el borde.
  return Image.asset(
    asset,
    width: size,
    height: size,
    fit: BoxFit.contain,
    color: color,
    filterQuality: FilterQuality.high,
    isAntiAlias: true,
  );
}

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
  final String? fallbackAsset;
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
    this.fallbackAsset,
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
          : fernFallbackIcon(
              context,
              icon: fallbackIcon,
              asset: fallbackAsset,
              size: iconSize ?? radius,
              color: iconColor ?? context.colors.primary,
            ),
    );
  }
}
