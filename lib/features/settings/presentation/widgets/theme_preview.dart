import 'package:Fern/config/theme/app_palette.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// La aplicación en pequeño, pintada con [palette].
///
/// No es una captura ni un dibujo suelto: es la propia pantalla reducida a lo
/// que se reconoce de un vistazo (el menú lateral con su etiqueta marcada, el
/// buscador de la cabecera y la rejilla de contenido), que es lo que permite
/// saber cómo va a quedar la aplicación antes de cambiarla.
class ThemePreview extends StatelessWidget {
  final AppPalette palette;

  const ThemePreview({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: palette.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sidebar(),
          Expanded(child: _content()),
        ],
      ),
    );
  }

  /// El menú lateral: su fondo suave y tres etiquetas, la primera marcada.
  Widget _sidebar() {
    return Container(
      width: AppSizes.themePreviewWidth / 4,
      color: palette.secondary,
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _bar(palette.primary, height: 8),
          const SizedBox(height: AppSpacing.xs),
          _bar(palette.lightgray, height: 4),
          const SizedBox(height: AppSpacing.xs),
          _bar(palette.lightgray, height: 4),
        ],
      ),
    );
  }

  /// La pantalla: el buscador de la cabecera y cuatro contenidos, uno de ellos
  /// marcado como favorito con el color del acento.
  Widget _content() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _bar(palette.secondary, height: 10)),
              const SizedBox(width: AppSpacing.xs),
              _dot(palette.black, size: 6),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _tile(isFavorite: true)),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: _tile()),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: _tile()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile({bool isFavorite = false}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.white,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        border: Border.all(color: palette.lightgray, width: 0.5),
      ),
      child: isFavorite
          ? Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: _dot(palette.terciary, size: 6),
              ),
            )
          : null,
    );
  }

  Widget _bar(Color color, {required double height}) {
    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }

  Widget _dot(Color color, {required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Las dos paletas de fábrica en la misma previsualización, partidas en
/// diagonal: es lo que hace el tema del sistema, que será una o la otra según
/// cómo esté el escritorio.
class SystemThemePreview extends StatelessWidget {
  final AppPalette light;
  final AppPalette dark;

  const SystemThemePreview({
    super.key,
    required this.light,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ThemePreview(palette: light),
        ClipPath(
          clipper: const _DiagonalClipper(),
          child: ThemePreview(palette: dark),
        ),
      ],
    );
  }
}

/// El triángulo de la mitad de abajo a la derecha, que es por donde asoma el
/// tema oscuro.
class _DiagonalClipper extends CustomClipper<Path> {
  const _DiagonalClipper();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width, 0)
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
