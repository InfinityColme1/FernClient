import 'dart:io';

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/services/media_preview_service.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/utils/file_size.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/features/duplicates/domain/services/duplicate_detail.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Las copias de un grupo, una al lado de otra, con la que se conserva marcada.
///
/// Van en fila y con desplazamiento horizontal porque un grupo puede tener tres
/// o cuatro copias: apilarlas obligaría a subir y bajar para comparar dos
/// números que sólo sirven puestos uno al lado del otro.
class DuplicateComparison extends StatelessWidget {
  final List<DuplicateCopy> copies;
  final int? keeperId;
  final ValueChanged<int>? onKeep;

  /// Abrir esta copia a pantalla completa.
  ///
  /// Hace falta de verdad: dos copias de la misma cosa se distinguen mirándolas
  /// de cerca, y en una tarjeta de trescientos píxeles no se ve si el recorte de
  /// una se come un borde o si la otra tiene una marca de agua. Sin esto, la
  /// única salida era salir de la pantalla y buscarlas en la rejilla.
  final ValueChanged<DuplicateCopy>? onOpen;

  const DuplicateComparison({
    super.key,
    required this.copies,
    required this.keeperId,
    this.onKeep,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Dos caben siempre; a partir de ahí se estrechan hasta un mínimo y
        // luego se desplazan. Encogerlas sin fondo dejaría cuatro columnas
        // ilegibles en las que no se distingue nada.
        final width = (constraints.maxWidth - AppSpacing.m) / 2;
        final cardWidth = width.clamp(duplicateCardMinWidth, double.infinity);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final copy in copies) ...[
                SizedBox(
                  width: cardWidth,
                  child: _CopyCard(
                    copy: copy,
                    isKeeper: copy.mediaId == keeperId,
                    onKeep: onKeep,
                    onOpen: onOpen,
                  ),
                ),
                if (copy != copies.last) const SizedBox(width: AppSpacing.m),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Lo mínimo que puede medir una columna sin dejar de ser comparable.
const double duplicateCardMinWidth = 260;

class _CopyCard extends StatelessWidget {
  final DuplicateCopy copy;
  final bool isKeeper;
  final ValueChanged<int>? onKeep;
  final ValueChanged<DuplicateCopy>? onOpen;

  const _CopyCard({
    required this.copy,
    required this.isKeeper,
    this.onKeep,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.colors;

    return FernSurface(
      padding: const EdgeInsets.all(AppSpacing.m),
      // La que se conserva se tiñe entera y no sólo marca su círculo: el radio
      // está al pie de la tarjeta, y con dos columnas altas hay que bajar la
      // vista para ver cuál está marcada.
      color: isKeeper ? colors.primary.withValues(alpha: 0.12) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: MouseRegion(
              cursor: onOpen == null
                  ? MouseCursor.defer
                  : SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onOpen == null ? null : () => onOpen!(copy),
                child: Tooltip(
                  message: onOpen == null ? '' : texts.duplicatesOpenViewer,
                  child: _CopyPreview(path: copy.media.path),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            copy.hasSize
                ? '${copy.width} × ${copy.height}'
                : texts.duplicatesUnknownSize,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _Line(
            icon: Icons.save_outlined,
            text: formatFileWeight(copy.sizeInBytes),
          ),
          _Line(
            icon: Icons.event_outlined,
            text: DateFormat.yMMMd(
              Localizations.localeOf(context).languageCode,
            ).format(copy.media.downloaded),
          ),
          _Line(
            icon: Icons.person_outline,
            text: _creatorOf(context),
          ),
          _Line(
            icon: Icons.sell_outlined,
            text: texts.duplicatesTagCount(copy.tagCount),
          ),
          if (copy.media.isFavorite)
            _Line(
              icon: Icons.favorite,
              text: texts.duplicatesFavorite,
              color: colors.terciary,
            ),
          const SizedBox(height: AppSpacing.s),
          FernRadioTile<int>(
            value: copy.mediaId,
            groupValue: isKeeper ? copy.mediaId : null,
            label: texts.duplicatesKeepThis,
            onChanged: onKeep,
          ),
        ],
      ),
    );
  }

  String _creatorOf(BuildContext context) {
    final name = copy.media.creator.name;

    return name == unknownCreator.name
        ? AppLocalizations.of(context).duplicatesNoCreator
        : name;
  }
}

/// Una línea de ficha: icono pequeño y texto.
class _Line extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _Line({required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final tone = color ?? context.colors.unremarked;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconSmall, color: tone),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: tone),
            ),
          ),
        ],
      ),
    );
  }
}

/// La imagen de una copia, o el fotograma si es un vídeo.
class _CopyPreview extends StatefulWidget {
  final String path;

  const _CopyPreview({required this.path});

  @override
  State<_CopyPreview> createState() => _CopyPreviewState();
}

class _CopyPreviewState extends State<_CopyPreview> {
  MediaPreview? _preview;

  bool get _isVideo => widget.path.isVideoPath;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_CopyPreview old) {
    super.didUpdateWidget(old);

    if (old.path != widget.path) _load();
  }

  Future<void> _load() async {
    // Sólo los vídeos: de una imagen basta la ruta, y pedir la previsualización
    // de todas obligaría a esperar para pintar algo que ya se puede pintar.
    if (!_isVideo) return;

    final preview = await MediaPreviewService.instance.load(widget.path);
    if (!mounted) return;

    setState(() => _preview = preview);
  }

  @override
  Widget build(BuildContext context) {
    final path = _isVideo ? _preview?.thumbnailPath : widget.path;

    if (path == null) {
      return Center(
        child: Icon(
          _isVideo ? Icons.movie_outlined : Icons.broken_image_outlined,
          color: context.colors.unremarked,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Image.file(
        File(path),
        fit: BoxFit.contain,
        width: double.infinity,
        // Que un fichero no se pueda pintar no puede tumbar la comparación: el
        // resto de la ficha sigue sirviendo para elegir.
        errorBuilder: (context, error, stack) => Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: context.colors.unremarked,
          ),
        ),
      ),
    );
  }
}
