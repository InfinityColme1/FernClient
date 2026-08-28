import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/core/ui/display/fern_surface_color.dart';
import 'package:flutter/material.dart';


/// Un bloque de color redondeado: la base sobre la que se apoya casi todo.
///
/// **Por qué lleva un trazo y no una sombra.** Una superficie tiene que
/// distinguirse de lo que tiene detrás, y hay dos maneras. La sombra cuesta una
/// capa de pintado por cada una y en una rejilla de mil elementos eso se nota;
/// el trazo de un píxel no cuesta nada y dice lo mismo. Es lo que hace que dos
/// superficies pegadas no se lean como una sola mancha de color.
///
/// [FernSurface.raised] es la de encima de otra superficie: un menú abierto sobre
/// una ficha, un diálogo sobre la pantalla. En el tema oscuro se aclara un punto;
/// en el claro no hay hacia dónde ir desde el blanco, y ahí el escalón lo da
/// entero el trazo.
class FernSurface extends StatelessWidget {
  final double radius;
  final Widget? child;
  final Color? color;
  final Clip clipBehavior;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  /// Si lleva el trazo que la separa de lo que tiene detrás.
  ///
  /// Puesto por defecto: una superficie que no se despega de su fondo es el
  /// problema, no la excepción. Se quita en las pocas que van pegadas a otra a
  /// propósito, donde el trazo dibujaría una costura que no existe.
  final bool bordered;

  /// Si es la superficie que se levanta **sobre otra**.
  final bool isRaised;

  const FernSurface({
    super.key,
    this.radius = AppSizes.radiusSurface,
    this.child,
    this.color,
    this.clipBehavior = Clip.none,
    this.width,
    this.height,
    this.padding,
    this.bordered = true,
  }) : isRaised = false;

  const FernSurface.raised({
    super.key,
    this.radius = AppSizes.radiusDialog,
    this.child,
    this.color,
    this.clipBehavior = Clip.none,
    this.width,
    this.height,
    this.padding,
    this.bordered = true,
  }) : isRaised = true;

  @override
  Widget build(BuildContext context) {
    final surface = color ??
        (isRaised
            ? context.colors.surfaceRaised
            : Theme.of(context).secondaryHeaderColor);

    return Container(
      width: width,
      height: height,
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius),
        border: bordered
            ? Border.all(
                color: context.colors.outline,
                width: AppSizes.borderHairline,
              )
            : null,
      ),
      // Lo que se pinte encima puede necesitar saber de qué color es esto: la
      // etiqueta flotante de un campo tapa el borde con el color de su fondo, y
      // un widget no puede averiguarlo por su cuenta.
      // El hijo es opcional: una superficie sin nada dentro es un hueco, y ahí
      // no hay a quién decirle nada.
      child: child == null
          ? null
          : FernSurfaceColor(color: surface, child: child!),
    );
  }
}
