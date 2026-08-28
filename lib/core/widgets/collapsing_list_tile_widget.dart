import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/display/fern_avatar.dart';
import 'package:Fern/core/ui/display/fern_badge.dart';
import 'package:Fern/core/ui/display/nsfw_tag_mark.dart';
import 'package:Fern/core/ui/display/fern_motion.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'dart:math' as math;

class CollapsingListTile extends StatefulWidget {
  final String title;
  final IconData icon;

  /// Icono en forma de imagen del paquete. Manda sobre [icon] cuando viene.

  /// Imagen con la que se pinta el botón en lugar del icono. Es lo que deja
  /// reconocer una etiqueta con el menú plegado, cuando el icono es el único que
  /// se ve y es igual para todas.
  final String? avatarPath;

  final AnimationController animationController;
  final bool isSelected;

  /// Si el menú está abierto del todo. Lo decide el menú, no el botón, para que
  /// todo lo que sólo cabe estando abierto (el título y la sangría) aparezca a
  /// la vez.
  final bool isExpanded;

  final VoidCallback ? onTap;
  final double iconSize;

  /// Nivel del botón en la jerarquía de etiquetas: cuanto más honda, más
  /// adentro empieza.
  final int depth;

  /// Cuántos avisos hay pendientes en la pantalla a la que lleva.
  final int badgeCount;

  final TextStyle textStyle;

  final Color selectedColor;
  final Color textSelectedColor;
  final Color unselectedColor;

  /// La etiqueta esconde contenido tras el filtro NSFW: la fila lleva su
  /// distintivo al final, donde no tapa el avatar.
  final bool isNsfw;
  final Color textUnselectedColor;

  const CollapsingListTile({
    super.key,
    required this.title,
    required this.icon,
    this.avatarPath,
    required this.animationController,
    this.isSelected = false,
    this.isExpanded = true,
    this.onTap,
    this.depth = 0,
    this.badgeCount = 0,
    required this.iconSize,
    required this.textStyle,
    required this.selectedColor,
    required this.textSelectedColor,
    required this.unselectedColor,
    this.isNsfw = false,
    required this.textUnselectedColor
  });

  @override
  State<StatefulWidget> createState() => _CollapsingListTileState();
}

class _CollapsingListTileState extends State<CollapsingListTile> {
  late Animation<double> widthAnimation, sizedBoxAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    widthAnimation =
        Tween<double>(begin: sidebarTileExpandedWidth, end: sidebarTileCollapsedWidth)
            .animate(widget.animationController);
    sizedBoxAnimation =
        Tween<double>(begin: sidebarTileGap, end: 0)
            .animate(widget.animationController);
  }

  /// Fondo del botón: el del elemento seleccionado y, mientras el ratón está
  /// encima, un velo oscuro por encima.
  ///
  /// El velo va aquí y no en el `hoverColor` del `InkWell` porque la tinta se
  /// pinta por debajo del `Container`, que es quien lleva el fondo.
  Color _backgroundColor(BuildContext context) {
    final background = widget.isSelected
        ? Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: sidebarSelectedOpacity)
        : Colors.transparent;

    if (!_isHovered) return background;

    return Color.alphaBlend(
      context.colors.black.withValues(alpha: sidebarHoverOverlayOpacity),
      background,
    );
  }

  /// Cuánto entra el botón por colgar de otro. Deja de crecer en
  /// [sidebarMaxIndentDepth]: más adentro no quedaría sitio para el título.
  double get _indent {
    if (!widget.isExpanded) return 0;

    return sidebarDepthIndent *
        math.min(widget.depth, sidebarMaxIndentDepth);
  }

  /// Lo que queda por debajo del último nivel con sangría se marca con una
  /// flecha: la jerarquía se sigue viendo aunque el botón ya no entre más.
  bool get _showsDepthMark =>
      widget.isExpanded && widget.depth > sidebarMaxIndentDepth;

  /// La imagen del botón, o su icono si no tiene ninguna.
  ///
  /// El avatar ocupa lo mismo que el icono al que sustituye: los botones con
  /// imagen y sin ella se alinean igual y la lista no se descuadra.
  ///
  /// El contador de avisos va encima del icono y no al final de la fila: con el
  /// menú plegado el título no se ve, y ahí es justo cuando más falta hace saber
  /// que ese botón tiene algo pendiente.
  Widget _leading() {
    final avatarPath = widget.avatarPath;

    final leading = avatarPath == null
        ? Icon(
            widget.icon,
            size: widget.iconSize,
            color: context.colors.black,
          )
        : FernAvatar(
            imagePath: avatarPath,
            fallbackIcon: widget.icon,
            radius: widget.iconSize / 2,
            iconSize: widget.iconSize,
          );

    return FernBadge(
      count: widget.badgeCount,
      maxCount: notificationBadgeMaxCount,
      child: leading,
    );
  }

  /// La barrita que dice en qué fila se está.
  ///
  /// **Vive en el carril de la izquierda, fuera de la píldora.** Dentro no
  /// funcionaba por dos motivos a la vez: iba del mismo color que el teñido del
  /// fondo de la fila elegida —así que se pisaban y ninguna de las dos se leía
  /// bien— y quedaba pegada al icono, sin aire que la separase de él.
  ///
  /// Fuera no compite con nada. El teñido dice «esto está puesto» y la barra dice
  /// «estás aquí», que son dos cosas distintas y ahora se ven como tales.
  ///
  /// Es más corta que la fila: de borde a borde se leería como un separador entre
  /// filas en vez de como una marca. Y crece de nada a su alto al elegir la fila
  /// y se recoge al dejarla, así que de una a otra se lee como que se ha movido.
  Widget _selectionMark(double rowHeight) {
    final alto = rowHeight * AppSizes.sidebarMarkHeightFactor;

    return AnimatedContainer(
      duration: context.motion(motionStandard),
      curve: motionEnterCurve,
      width: AppSizes.sidebarMarkWidth,
      height: widget.isSelected ? alto : 0,
      decoration: BoxDecoration(
        color: context.colors.primary,
        // Redondeada sólo por fuera: nace del borde del menú y se mete hacia
        // dentro.
        borderRadius: const BorderRadius.horizontal(
          right: Radius.circular(AppSizes.sidebarMarkWidth),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        mouseCursor: WidgetStateMouseCursor.clickable,
        child: _withMark(AnimatedContainer(
          // El fondo entra y sale en vez de encenderse de golpe: cambiar de
          // sección era un parpadeo de color, y ahora la marca se traslada de una
          // fila a otra.
          duration: context.motion(motionFast),
          curve: motionEnterCurve,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            color: _backgroundColor(context),
          ),
          width: widthAnimation.value,
          margin: EdgeInsets.only(left: _indent, right: AppSpacing.s),
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Row(
            children: <Widget>[
              if (_showsDepthMark) ...[
                Icon(
                  Symbols.subdirectory_arrow_right,
                  color: context.colors.unremarked,
                  size: AppSizes.iconSmall,
                ),
                SizedBox(width: sizedBoxAnimation.value),
              ],
              _leading(),
              SizedBox(width: sizedBoxAnimation.value),
              if (widget.isExpanded)
                Expanded(
                  child: Text(widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: widget.textStyle.copyWith(
                        color: widget.isSelected
                            ? widget.textSelectedColor
                            : widget.textUnselectedColor
                      )),
                ),
              // Sólo con el menú desplegado: plegado no hay ni sitio ni título
              // al que acompañar, y encogido no se leería.
              if (widget.isNsfw && widget.isExpanded) ...[
                SizedBox(width: sizedBoxAnimation.value),
                const NsfwTagMark(),
              ],
            ],
          ),
        )),
      ),
    );
  }

  /// La píldora con su carril a la izquierda, y la marca dentro del carril.
  ///
  /// El carril se reserva **siempre**, elegida la fila o no: si apareciera al
  /// elegirla, la fila entera se correría unos píxeles al pulsarla.
  ///
  /// La píldora pierde por la izquierda lo que gana el carril, así que el menú
  /// mide lo mismo que antes y el contenido de la fila no se estrecha.
  Widget _withMark(Widget pill) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSizes.sidebarMarkGutter),
          child: pill,
        ),
        // Centrada en el alto de la fila, midiéndolo del propio hueco: la fila
        // crece con lo que lleve dentro y una altura escrita a mano se quedaría
        // corta o larga en cuanto alguien la toque.
        Positioned(
          left: _indent,
          top: 0,
          bottom: 0,
          width: AppSizes.sidebarMarkWidth,
          child: LayoutBuilder(
            builder: (context, constraints) => Center(
              child: _selectionMark(constraints.maxHeight),
            ),
          ),
        ),
      ],
    );
  }
}
