import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Cómo se coloca la etiqueta respecto al círculo, y con qué peso.
enum _AddButtonLayout { stacked, inline, compact }

/// Botón circular con un "+" y una etiqueta, en tres variantes:
///
/// * la de por defecto, con la etiqueta debajo del círculo, para las rejillas de
///   avatares (añadir una etiqueta, un creador, un fernie);
/// * [FernAddButton.inline], con la etiqueta al lado, para que encaje en un
///   listado vertical de filas con avatar (las etiquetas del panel de
///   información, por ejemplo);
/// * [FernAddButton.compact], la misma fila pero menuda, para añadir campos
///   dentro de un formulario, donde el círculo grande pesaría demasiado.
///
/// Las tres son el mismo botón porque son la misma acción: antes la variante
/// menuda era un componente aparte y acabaron divergiendo dos veces.
///
/// La de por defecto mide lo mismo que un [FernAvatarTile] (de ahí que su
/// [radius] arranque en [AppSizes.avatarLarge]): en una fila de avatares, el "+"
/// es un elemento más de la fila y no puede ser el hermano pequeño.
class FernAddButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData icon;

  /// Radio del círculo en la variante de por defecto.
  ///
  /// Arranca en el de un avatar de rejilla para que el botón case con las caras
  /// que tiene al lado. Las variantes [FernAddButton.inline] y
  /// [FernAddButton.compact] no lo miran: van dentro de una fila de texto y su
  /// tamaño lo pone la línea.
  final double radius;

  final _AddButtonLayout _layout;

  const FernAddButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon = Symbols.add,
    this.radius = AppSizes.avatarLarge,
  }) : _layout = _AddButtonLayout.stacked;

  const FernAddButton.inline({
    super.key,
    required this.label,
    this.onTap,
    this.icon = Symbols.add,
  })  : radius = AppSizes.addButtonRadius,
        _layout = _AddButtonLayout.inline;

  const FernAddButton.compact({
    super.key,
    required this.label,
    this.onTap,
    this.icon = Symbols.add,
  })  : radius = AppSizes.addButtonRadius,
        _layout = _AddButtonLayout.compact;

  @override
  State<FernAddButton> createState() => _FernAddButtonState();
}

class _FernAddButtonState extends State<FernAddButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _isCompact => widget._layout == _AddButtonLayout.compact;

  bool get _isEnabled => widget.onTap != null;

  void _setHovered(bool value) {
    if (!_isEnabled || _isHovered == value) return;
    setState(() => _isHovered = value);
  }

  void _setPressed(bool value) {
    if (!_isEnabled || _isPressed == value) return;
    setState(() => _isPressed = value);
  }

  /// Cómo se ve el círculo según lo que esté haciendo el ratón.
  ///
  /// Un solo color de realce, no uno por estado: dos tonos distintos para «te
  /// estoy viendo» y «te he pulsado» se leen como dos botones y no como uno. Lo
  /// que distingue la pulsación es el encogido.
  ///
  /// En reposo se apaga con **ese mismo color a cero**, no con
  /// `Colors.transparent`. Aquél es negro invisible, y el desvanecido interpola
  /// todos los canales a la vez: yendo de negro al color de realce, el círculo
  /// pasa por un gris a media opacidad antes de llegar al tono de verdad, y lo
  /// que se ve es un parpadeo de dos colores. Con el mismo color a cero, lo
  /// único que cambia por el camino es la opacidad.
  Color get _background {
    final highlight = context.colors.secondary;

    return _isEnabled && (_isHovered || _isPressed)
        ? highlight
        : highlight.withValues(alpha: 0);
  }

  Color get _foreground => _isEnabled
      ? context.colors.black
      : context.colors.black.withValues(alpha: pillButtonDisabledOpacity);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isStacked = widget._layout == _AddButtonLayout.stacked;

    final decoration = BoxDecoration(
      shape: BoxShape.circle,
      color: _background,
      border: Border.all(
        color: _foreground,
        width: _isCompact ? AppSizes.borderThin : AppSizes.borderRegular,
      ),
    );

    // En la variante de rejilla el círculo va a un tamaño fijo, el del avatar
    // que tiene al lado. En las otras dos lo pone su contenido, que es lo que
    // las mantiene a la altura de la línea de texto en la que viven.
    final circle = isStacked
        ? AnimatedContainer(
            duration: hoverAnimationDuration,
            curve: Curves.easeOut,
            width: widget.radius * 2,
            height: widget.radius * 2,
            decoration: decoration,
            child: Icon(
              widget.icon,
              size: widget.radius,
              color: _foreground,
            ),
          )
        : AnimatedContainer(
            duration: hoverAnimationDuration,
            curve: Curves.easeOut,
            padding: EdgeInsets.all(_isCompact ? AppSpacing.xxs : AppSpacing.s),
            decoration: decoration,
            child: Icon(
              widget.icon,
              size: _isCompact ? AppSizes.iconSmall : AppSizes.iconLarge,
              color: _foreground,
            ),
          );

    return MouseRegion(
      cursor: _isEnabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        // Al pulsar, todo el botón se encoge un poco: es la señal que dice que
        // la pulsación ha entrado, y la misma que usan las celdas de la rejilla.
        child: AnimatedScale(
          scale: _isPressed ? addButtonPressedScale : 1.0,
          duration: hoverAnimationDuration,
          curve: Curves.easeOut,
          child: switch (widget._layout) {
            _AddButtonLayout.stacked => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                circle,
                // La misma separación y el mismo estilo de rótulo que
                // `FernAvatarTile`: en una fila mezclada, los textos de debajo
                // tienen que caer a la misma altura.
                const SizedBox(height: AppSpacing.s),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _foreground,
                  ),
                ),
              ],
            ),
            _AddButtonLayout.inline => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                circle,
                const SizedBox(width: AppSpacing.m),
                Text(
                  widget.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _foreground,
                  ),
                ),
              ],
            ),
            // La menuda lleva su propio relleno porque va suelta entre campos de
            // un formulario y necesita algo de aire alrededor.
            _AddButtonLayout.compact => Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  circle,
                  const SizedBox(width: AppSpacing.s),
                  Text(
                    widget.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _foreground,
                    ),
                  ),
                ],
              ),
            ),
          },
        ),
      ),
    );
  }
}
