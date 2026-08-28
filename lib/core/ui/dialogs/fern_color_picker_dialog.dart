import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/buttons/fern_action_button.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Pide un color y devuelve el elegido, o `null` si se cierra sin elegir.
Future<Color?> showFernColorPicker(
  BuildContext context, {
  required Color initialColor,
}) {
  return showDialog<Color>(
    context: context,
    builder: (_) => FernColorPickerDialog(initialColor: initialColor),
  );
}

/// Selector de color.
///
/// Se elige por tono, saturación y brillo (la mancha de color de arriba y la
/// barra de matices de debajo) o escribiendo el código hexadecimal, que es como
/// se traen los colores de fuera. Las dos formas son la misma: lo que se toca en
/// una se ve en la otra al momento.
///
/// El color siempre sale opaco: la aplicación pinta con él superficies y textos,
/// y un color a medio poner sólo daría problemas de legibilidad.
class FernColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const FernColorPickerDialog({super.key, required this.initialColor});

  @override
  State<FernColorPickerDialog> createState() => _FernColorPickerDialogState();
}

class _FernColorPickerDialogState extends State<FernColorPickerDialog> {
  late HSVColor _color = HSVColor.fromColor(widget.initialColor);
  late final TextEditingController _hexController =
      TextEditingController(text: _hex(widget.initialColor));

  /// El código de un color, tal y como se escribe y se lee fuera de aquí.
  static String _hex(Color color) =>
      (color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();

  Color get _selected => _color.toColor();

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  /// Cambia el color desde la mancha o desde la barra. El campo del código
  /// acompaña, que es la otra forma de ver lo mismo.
  void _pick(HSVColor color) {
    setState(() => _color = color);
    _hexController.text = _hex(color.toColor());
  }

  /// Cambia el color desde el código escrito.
  ///
  /// Mientras lo escrito no sean seis cifras hexadecimales no hay color que
  /// enseñar, así que no se toca nada: el campo se queda a medias sin que la
  /// muestra vaya dando tumbos con cada tecla.
  void _pickFromHex(String value) {
    if (value.length != 6) return;

    final rgb = int.tryParse(value, radix: 16);
    if (rgb == null) return;

    setState(() => _color = HSVColor.fromColor(Color(0xFF000000 | rgb)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);
    final colors = context.colors;

    return Dialog(
      backgroundColor: colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusDialog),
      ),
      child: SizedBox(
        width: AppSizes.colorPickerWidth,
        child: Padding(
          padding: AppSpacing.dialogPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      texts.colorPickerTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: AppLocalizations.of(context).actionClose,
                    icon: const Icon(Symbols.close, size: AppSizes.iconLarge),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              _SaturationValueArea(color: _color, onChanged: _pick),
              const SizedBox(height: AppSpacing.m),
              _HueBar(color: _color, onChanged: _pick),
              const SizedBox(height: AppSpacing.l),
              Row(
                children: [
                  // La muestra: el color tal y como va a quedar, que es lo que
                  // ni la mancha ni el código enseñan por sí solos.
                  Container(
                    width: AppSizes.colorSwatch,
                    height: AppSizes.colorSwatch,
                    decoration: BoxDecoration(
                      color: _selected,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusSmall),
                      border: Border.all(color: colors.lightgray),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: TextField(
                      controller: _hexController,
                      style: theme.textTheme.bodyMedium,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(6),
                        FilteringTextInputFormatter.allow(
                          RegExp('[0-9a-fA-F]'),
                        ),
                        // Lo que se escriba se ve como se escribe fuera: en
                        // mayúsculas, que es como se copia de cualquier sitio.
                        TextInputFormatter.withFunction(
                          (_, next) => next.copyWith(
                            text: next.text.toUpperCase(),
                          ),
                        ),
                      ],
                      decoration: InputDecoration(
                        prefixText: '#',
                        labelText: texts.colorPickerHex,
                      ),
                      onChanged: _pickFromHex,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              FernActionButton(
                label: texts.actionConfirm,
                onPressed: () => Navigator.of(context).pop(_selected),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// La mancha de color: a lo ancho se satura y a lo alto se apaga.
class _SaturationValueArea extends StatelessWidget {
  final HSVColor color;
  final ValueChanged<HSVColor> onChanged;

  const _SaturationValueArea({required this.color, required this.onChanged});

  void _update(Offset position, Size size) {
    onChanged(color.withSaturation(
      (position.dx / size.width).clamp(0.0, 1.0),
    ).withValue(
      (1 - position.dy / size.height).clamp(0.0, 1.0),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth,
          AppSizes.colorPickerAreaHeight,
        );

        return GestureDetector(
          onPanDown: (details) => _update(details.localPosition, size),
          onPanUpdate: (details) => _update(details.localPosition, size),
          child: MouseRegion(
            cursor: SystemMouseCursors.precise,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              child: SizedBox.fromSize(
                size: size,
                child: Stack(
                  children: [
                    // El tono puro, y encima los dos degradados que lo llevan
                    // al blanco (hacia la izquierda) y al negro (hacia abajo).
                    Positioned.fill(
                      child: ColoredBox(
                        color: HSVColor.fromAHSV(1, color.hue, 1, 1).toColor(),
                      ),
                    ),
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: color.saturation * size.width,
                      top: (1 - color.value) * size.height,
                      child: const _PickerHandle(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// La barra de matices: todos los tonos, de rojo a rojo.
class _HueBar extends StatelessWidget {
  final HSVColor color;
  final ValueChanged<HSVColor> onChanged;

  const _HueBar({required this.color, required this.onChanged});

  /// Los tonos con los que se pinta la barra, uno cada sesenta grados. Con
  /// menos, el degradado se aparta de los colores que representa.
  static final _hues = [
    for (var hue = 0; hue <= 360; hue += 60)
      HSVColor.fromAHSV(1, hue.toDouble() % 360, 1, 1).toColor(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        void update(Offset position) {
          onChanged(color.withHue(
            ((position.dx / width) * 360).clamp(0.0, 360.0),
          ));
        }

        return GestureDetector(
          onPanDown: (details) => update(details.localPosition),
          onPanUpdate: (details) => update(details.localPosition),
          child: MouseRegion(
            cursor: SystemMouseCursors.precise,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              child: SizedBox(
                width: width,
                height: AppSizes.colorPickerHueHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: _hues),
                        ),
                      ),
                    ),
                    Positioned(
                      left: (color.hue / 360) * width,
                      top: AppSizes.colorPickerHueHeight / 2,
                      child: const _PickerHandle(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// El círculo que señala dónde se ha pulsado.
///
/// Va con dos bordes, uno blanco y otro oscuro, para que se vea igual sobre un
/// color claro que sobre uno oscuro. Se centra él solo en el punto que marca.
class _PickerHandle extends StatelessWidget {
  const _PickerHandle();

  static const _diameter = 14.0;

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
      translation: const Offset(-0.5, -0.5),
      child: IgnorePointer(
        child: Container(
          width: _diameter,
          height: _diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black38, blurRadius: 2),
            ],
          ),
        ),
      ),
    );
  }
}
