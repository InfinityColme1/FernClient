import 'dart:async';

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Aviso breve que aparece abajo, dice lo que acaba de pasar y se va solo.
///
/// Va por encima de todo (en la capa raíz), así que sirve igual en una pantalla
/// normal, sobre un diálogo o con la aplicación a pantalla completa. Sólo hay
/// uno a la vez: si llega otro, sustituye al que hubiera, que es lo que se
/// espera cuando se repite una acción varias veces seguidas.
void showFernToast(
  BuildContext context,
  String message, {
  IconData? icon,
  VoidCallback? onTap,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  _FernToastHost.show(overlay, message: message, icon: icon, onTap: onTap);
}

class _FernToastHost {
  static OverlayEntry? _current;

  static void show(
    OverlayState overlay, {
    required String message,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    _current?.remove();
    _current = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _FernToast(
        message: message,
        icon: icon,
        onTap: onTap,
        onDismissed: () {
          if (!identical(_current, entry)) return;
          entry.remove();
          _current = null;
        },
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }
}

class _FernToast extends StatefulWidget {
  final String message;
  final IconData? icon;
  final VoidCallback onDismissed;

  /// Qué pasa al pulsarlo, si es de los que llevan a algún sitio.
  ///
  /// Sin esto el aviso no atiende a las pulsaciones —lo que hay debajo es la
  /// pantalla, y un mensaje que se va solo no puede quedarse con los clics que
  /// van a ella—. Con esto sí, y además se queda hasta que se pulsa o se cierra:
  /// un aviso que lleva a un sitio y se desvanece en tres segundos es una puerta
  /// que se cierra en las narices.
  final VoidCallback? onTap;

  const _FernToast({
    required this.message,
    required this.icon,
    required this.onDismissed,
    this.onTap,
  });

  @override
  State<_FernToast> createState() => _FernToastState();
}

class _FernToastState extends State<_FernToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: toastFadeDuration,
  );

  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller.forward();

    // El que lleva a algún sitio no se va solo: darle tres segundos a alguien
    // para que lea el mensaje **y** decida pulsarlo es no dárselos.
    if (widget.onTap == null) {
      _dismissTimer = Timer(toastDuration, _dismiss);
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    if (!mounted) return;
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    return Positioned(
      left: 0,
      right: 0,
      bottom: AppSpacing.xxl,
      child: IgnorePointer(
        // El que lleva a algún sitio sí atiende a las pulsaciones; el resto no,
        // porque lo que hay debajo es la pantalla.
        ignoring: widget.onTap == null,
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(
            // Entra subiendo un poco desde abajo, lo justo para que se note de
            // dónde sale sin que parezca que cruza la pantalla.
            position: Tween<Offset>(
              begin: const Offset(0, toastSlideOffset),
              end: Offset.zero,
            ).animate(animation),
            child: Center(
              child: widget.onTap == null
                  ? _buildBubble(context)
                  : _tappable(context),
            ),
          ),
        ),
      ),
    );
  }

  /// La misma burbuja, pero que se puede pulsar y cerrar.
  Widget _tappable(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.onTap?.call();
          _dismiss();
        },
        child: _buildBubble(context),
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        decoration: BoxDecoration(
          color: context.colors.scrim.withValues(alpha: toastOpacity),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: Colors.white,
                size: AppSizes.iconMedium,
              ),
              const SizedBox(width: AppSpacing.s),
            ],
            Text(
              widget.message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
