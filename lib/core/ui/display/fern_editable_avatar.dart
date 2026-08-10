import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/ui/display/fern_avatar.dart';
import 'package:flutter/material.dart';

/// [FernAvatar] pulsable que muestra una capa oscura con un icono de edición
/// mientras el puntero está encima.
class FernEditableAvatar extends StatefulWidget {
  final String? imagePath;
  final IconData fallbackIcon;
  final double radius;
  final double? iconSize;
  final VoidCallback? onTap;
  final IconData overlayIcon;
  final double overlayIconSize;
  final Color backgroundColor;
  final Color iconColor;

  const FernEditableAvatar({
    super.key,
    this.imagePath,
    required this.fallbackIcon,
    required this.radius,
    this.iconSize,
    this.onTap,
    this.overlayIcon = Icons.edit,
    this.overlayIconSize = AppSizes.iconLarge,
    this.backgroundColor = AppColors.secondary,
    this.iconColor = AppColors.primary,
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
                  color: AppColors.white,
                  size: widget.overlayIconSize,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
