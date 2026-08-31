import 'dart:async';

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/services/media_preview_service.dart';
import 'package:Fern/core/ui/display/fern_region_selection_layer.dart';
import 'package:Fern/core/ui/display/region_painter.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/presentation/widgets/media_viewer.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// El rectángulo que ocupa la imagen entera. Es lo que devuelve el botón de
/// quedarse con todo, y lo que hacía el botón antes de que hubiera recorte.
const wholeImageRect = Rect.fromLTWH(0, 0, 1, 1);

/// Elige **qué trozo** de la imagen se queda como avatar.
///
/// Antes, crear una etiqueta desde el visor cogía el contenido entero: en una
/// ilustración apaisada con cuatro personajes, el avatar de uno de ellos salía
/// siendo la escena completa reducida a un círculo.
///
/// Devuelve el rectángulo normalizado, o `null` si se cierra sin elegir. **No
/// escribe nada**: quien lo abre es quien guarda, y así cerrar esto no deja un
/// recorte tirado en la carpeta de avatares.
///
/// La selección es **cuadrada forzosa** ([FernRegionSelectionLayer.squareSelection]):
/// el avatar es redondo, así que lo que se marca es exactamente lo que se va a
/// ver. Con selección libre habría que decidir qué hacer con un rectángulo
/// alargado, y las dos salidas —deformarlo o volver a recortarlo por dentro— dan
/// un avatar distinto del que se eligió.
///
/// Sólo para imágenes quietas. De un GIF o un vídeo se sigue cogiendo el
/// fotograma entero sin abrir nada, que es lo que ya hacía.
class AvatarCropDialog extends StatefulWidget {
  final String path;

  /// Cuánto mide la imagen, en píxeles.
  ///
  /// Normalmente llega `null` y se mide al abrir: sin la medida no hay forma de
  /// saber a qué parte del fichero corresponde un punto de la pantalla, así que
  /// la capa no deja marcar hasta que se sepa. Se puede dar hecha desde fuera,
  /// que es lo que hacen las pruebas para no depender del disco.
  final Size? contentSize;

  const AvatarCropDialog({super.key, required this.path, this.contentSize});

  @override
  State<AvatarCropDialog> createState() => _AvatarCropDialogState();
}

class _AvatarCropDialogState extends State<AvatarCropDialog> {
  final _transformation = TransformationController();

  /// Lo marcado hasta ahora, normalizado. `null` mientras no se haya marcado
  /// nada: sin cuadrado no hay nada que confirmar.
  Rect? _selection;

  late Size? _contentSize = widget.contentSize;

  @override
  void initState() {
    super.initState();

    if (_contentSize == null) unawaited(_measure());
  }

  Future<void> _measure() async {
    final preview = await MediaPreviewService.instance.load(widget.path);
    final width = preview?.width;
    final height = preview?.height;
    if (!mounted || width == null || height == null) return;
    if (width <= 0 || height <= 0) return;

    setState(() =>
        _contentSize = Size(width.toDouble(), height.toDouble()));
  }

  @override
  void dispose() {
    _transformation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final selection = _selection;

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      leftContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(texts.avatarCropTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s),
          Text(
            texts.avatarCropHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.colors.gray,
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          // Flexible y no de alto fijo: en una ventana baja, un lienzo que pide
          // su medida y no cede desborda el diálogo y esconde los botones. Lo
          // que se pinta con `contain` se encoge sin deformarse.
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: AppSizes.avatarCropCanvasHeight,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                child: ColoredBox(
                  color: context.colors.black,
                  child: FernRegionSelectionLayer(
                  enabled: true,
                  squareSelection: true,
                  contentSize: _contentSize,
                  controller: _transformation,
                  minRegionFraction: fernieMinRegionFraction,
                  minScale: viewerMinZoomScale,
                  maxScale: fernieMaxZoomScale,
                  regions: [
                    if (selection != null) RegionVisual(rect: selection),
                  ],
                  // Cada arrastre sustituye al anterior: aquí no se marcan
                  // regiones, se elige **una** cosa, y volver a arrastrar es
                  // corregir la elección.
                  onRegionDrawn: (rect, _) =>
                      setState(() => _selection = rect),
                  child: MediaViewer(
                    path: widget.path,
                    controller: _transformation,
                    // Los gestos los reparte la capa: es la que distingue un
                    // arrastre que recorta de uno que desplaza.
                    interactive: false,
                  ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          FernPillButton(
            label: texts.avatarCropWholeImage,
            icon: Symbols.crop_free,
            backgroundColor: context.colors.secondary,
            foregroundColor: context.colors.black,
            onPressed: () => Navigator.of(context).pop(wholeImageRect),
          ),
        ],
      ),
      actionButton: FernConfirmButton(
        // Sin nada marcado no hay recorte que confirmar. Para quedarse con la
        // imagen entera está su propio botón, que dice lo que hace.
        onPressed:
            selection == null ? null : () => Navigator.of(context).pop(selection),
      ),
    );
  }
}
