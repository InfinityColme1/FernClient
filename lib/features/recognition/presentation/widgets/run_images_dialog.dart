import 'dart:io';
import 'dart:math' as math;

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/presentation/widgets/metrics_panel.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

/// Los ficheros que deja ultralytics en la carpeta de la run, por si sirven.
///
/// Son los nombres de la versión actual y **puede que no estén todos**: cambian
/// entre versiones y dependen de lo que se entrene. Por eso esto es una lista de
/// candidatos y no una promesa: se enseña lo que exista.
const _confusionFiles = [
  'confusion_matrix_normalized.png',
  'confusion_matrix.png',
];

const _curveFiles = [
  'results.png',
  'PR_curve.png',
  'P_curve.png',
  'R_curve.png',
  'F1_curve.png',
  'labels.jpg',
];

/// Las imágenes que dejó el entrenamiento.
///
/// No se redibujan: ultralytics ya las genera en PNG y enseñar las suyas es más
/// fiel que reconstruirlas —y son exactamente las mismas que se verían abriendo
/// la carpeta a mano—. Lo único que hace falta aquí es encontrarlas y aguantar
/// que no estén.
class RunImagesDialog extends StatelessWidget {
  final String directory;
  final RunImageKind kind;

  /// Abrir la carpeta en el explorador del sistema.
  final ValueChanged<String>? onOpenFolder;

  const RunImagesDialog({
    super.key,
    required this.directory,
    required this.kind,
    this.onOpenFolder,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final images = findRunImages(directory: directory, kind: kind);

    return FernDialog(
      onClose: () => Navigator.of(context).pop(),
      maxWidth: AppSizes.runImagesDialogWidth,
      leftContent: SizedBox(
        // Lo que se pida, pero nunca más de lo que queda de ventana. Con alto
        // fijo, en una pantalla baja el diálogo desbordaba por abajo y las
        // últimas curvas quedaban debajo del borde, sin forma de llegar a ellas.
        height: math.min(
          AppSizes.runImagesDialogHeight,
          MediaQuery.sizeOf(context).height - AppSizes.dialogChromeHeight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kind == RunImageKind.confusion
                  ? texts.metricsConfusionMatrix
                  : texts.metricsCurves,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.m),
            Expanded(
              child: images.isEmpty
                  ? _missing(context, texts)
                  : ListView.separated(
                      itemCount: images.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.l),
                      itemBuilder: (_, index) =>
                          _image(context, images[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image(BuildContext context, String path) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          p.basenameWithoutExtension(path),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: context.colors.unremarked),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Sobre blanco: ultralytics las dibuja con fondo blanco y ejes negros,
        // y en tema oscuro los bordes de la imagen se comerían el papel.
        ColoredBox(
          color: Colors.white,
          child: Image.file(
            File(path),
            fit: BoxFit.contain,
            // Un fichero que se borró entre listarlo y pintarlo no puede tumbar
            // el diálogo entero.
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  /// La carpeta ya no está, o no tiene lo que se buscaba.
  ///
  /// Pasa más de lo que parece: la carpeta de runs es de las primeras que se
  /// borran para hacer sitio, y el modelo sigue funcionando sin ella porque los
  /// pesos son lo único que hace falta para reconocer.
  Widget _missing(BuildContext context, AppLocalizations texts) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(texts.metricsRunImagesMissing),
        const SizedBox(height: AppSpacing.s),
        Text(
          directory,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: context.colors.unremarked),
        ),
        if (onOpenFolder != null) ...[
          const SizedBox(height: AppSpacing.m),
          FernPillButton(
            backgroundColor: context.colors.secondary,
            foregroundColor: context.colors.black,
            label: texts.metricsOpenRunFolder,
            icon: Icons.folder_open,
            onPressed: () => onOpenFolder!(directory),
          ),
        ],
      ],
    );
  }
}

/// Qué imágenes de esa clase hay de verdad en la carpeta.
///
/// Separada del widget para poder probarla: es la parte que puede fallar —una
/// carpeta que ya no existe, una versión de ultralytics que renombró un
/// fichero— y la que decide si el diálogo tiene algo que enseñar.
///
/// Devuelve rutas absolutas y **sólo de lo que existe**, en el orden en que se
/// quieren ver: la matriz normalizada antes que la cruda, y el resumen antes que
/// las curvas sueltas.
List<String> findRunImages({
  required String directory,
  required RunImageKind kind,
}) {
  final candidates =
      kind == RunImageKind.confusion ? _confusionFiles : _curveFiles;

  final found = <String>[];

  for (final name in candidates) {
    final path = p.join(directory, name);

    try {
      if (File(path).existsSync()) found.add(path);
    } on FileSystemException {
      // Una unidad de red caída o un permiso denegado: se sigue con el resto.
      continue;
    }
  }

  return found;
}
