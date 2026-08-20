import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/ui/display/fern_avatar.dart';
import 'package:flutter/material.dart';

/// [FernAvatar] pulsable que muestra una capa oscura con un icono de edición
/// mientras el puntero está encima.
class FernEditableAvatar extends StatefulWidget {
  final String? imagePath;
  final IconData fallbackIcon;

  /// Icono de reserva en forma de imagen del paquete. Manda sobre
  /// [fallbackIcon] cuando viene.
  final String? fallbackAsset;

  final double radius;
  final double? iconSize;
  final VoidCallback? onTap;
  final IconData overlayIcon;
  final double overlayIconSize;
  /// Sin decir nada, los colores de la paleta que esté puesta.
  final Color? backgroundColor;
  final Color? iconColor;

  const FernEditableAvatar({
    super.key,
    this.imagePath,
    required this.fallbackIcon,
    this.fallbackAsset,
    required this.radius,
    this.iconSize,
    this.onTap,
    this.overlayIcon = Icons.edit,
    this.overlayIconSize = AppSizes.iconLarge,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<FernEditableAvatar> createState() => _FernEditableAvatarState();
}

class _FernEditableAvatarState extends State<FernEditableAvatar> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final diameter = widget.radius * 2;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FernAvatar(
              imagePath: widget.imagePath,
              fallbackIcon: widget.fallbackIcon,
              fallbackAsset: widget.fallbackAsset,
              radius: widget.radius,
              iconSize: widget.iconSize,
              backgroundColor: widget.backgroundColor,
              iconColor: widget.iconColor,
            ),
            if (_isHovering)
              Container(
                width: diameter,
                height: diameter,
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.overlayIcon,
                  color: Colors.white,
                  size: widget.overlayIconSize,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
