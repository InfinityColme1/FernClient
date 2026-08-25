import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/services/media_preview_service.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/features/media/domain/entities/search/search_result_type.dart';
import 'package:Fern/core/ui/display/nsfw_tag_mark.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Cómo se pinta cada tipo de resultado: el texto que lo nombra y el icono con
/// el que se muestra cuando no hay imagen.
extension SearchResultTypeVisuals on SearchResultType {
  String label(AppLocalizations texts) => switch (this) {
        SearchResultType.media => texts.resultTypeMedia,
        SearchResultType.tag => texts.resultTypeTag,
        SearchResultType.creator => texts.resultTypeCreator,
      };

  IconData get icon => switch (this) {
        SearchResultType.media => Icons.image_outlined,
        SearchResultType.tag => Icons.label,
        SearchResultType.creator => Icons.person,
      };
}

/// Fila de un resultado de búsqueda: avatar, nombre y tipo en gris.
///
/// Es la misma pieza en los dos sitios donde aparece un resultado: las
/// sugerencias del buscador principal, donde el tipo va al final de la fila, y
/// las cabeceras que separan los grupos de la rejilla, donde va justo detrás del
/// nombre porque la fila ocupa todo el ancho de la rejilla.
class SearchResultRow extends StatelessWidget {
  final String label;
  final String? imagePath;
  final SearchResultType type;
  final double radius;
  final VoidCallback? onTap;

  /// La fila es una etiqueta marcada como NSFW y hay que decirlo.
  final bool isNsfw;

  /// Cabecera de grupo: nombre en negrita, avatar más pequeño y sin pulsación.
  final bool _isHeader;

  const SearchResultRow.suggestion({
    super.key,
    required this.label,
    required this.type,
    required this.onTap,
    this.imagePath,
    this.isNsfw = false,
  })  : radius = AppSizes.avatarMedium,
        _isHeader = false;

  const SearchResultRow.header({
    super.key,
    required this.label,
    required this.type,
    this.imagePath,
    this.isNsfw = false,
  })  : radius = AppSizes.avatarSmall,
        onTap = null,
        _isHeader = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final name = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _isHeader
          ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)
          : theme.textTheme.bodyMedium,
    );

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      child: Row(
        mainAxisSize: _isHeader ? MainAxisSize.min : MainAxisSize.max,
        children: [
          SearchResultAvatar(
            imagePath: imagePath,
            type: type,
            radius: radius,
          ),
          const SizedBox(width: AppSpacing.m),
          _isHeader ? Flexible(child: name) : Expanded(child: name),
          // El distintivo va detrás del nombre y delante del tipo: así no tapa
          // el avatar, que es con lo que se reconoce la etiqueta.
          if (isNsfw) ...[
            const SizedBox(width: AppSpacing.s),
            const NsfwTagMark(),
          ],
          const SizedBox(width: AppSpacing.m),
          Text(
            type.label(AppLocalizations.of(context)),
            style: theme.textTheme.labelSmall?.copyWith(color: context.colors.gray),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      mouseCursor: WidgetStateMouseCursor.clickable,
      child: content,
    );
  }
}

/// Avatar de un resultado de búsqueda.
///
/// Las etiquetas y los creadores tienen su propia imagen; un contenido se
/// muestra a sí mismo, y si es un vídeo hay que esperar a que se extraiga su
/// fotograma, porque el fichero de vídeo no se puede pintar directamente.
class SearchResultAvatar extends StatefulWidget {
  final String? imagePath;
  final SearchResultType type;
  final double radius;

  const SearchResultAvatar({
    super.key,
    required this.type,
    required this.radius,
    this.imagePath,
  });

  @override
  State<SearchResultAvatar> createState() => _SearchResultAvatarState();
}

class _SearchResultAvatarState extends State<SearchResultAvatar> {
  String? _thumbnailPath;

  bool get _isVideo => widget.imagePath?.isVideoPath ?? false;

  @override
  void initState() {
    super.initState();
    _resolveThumbnail();
  }

  @override
  void didUpdateWidget(covariant SearchResultAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath == widget.imagePath) return;

    _thumbnailPath = null;
    _resolveThumbnail();
  }

  Future<void> _resolveThumbnail() async {
    final path = widget.imagePath;
    if (path == null || !_isVideo) return;

    final cached = MediaPreviewService.instance.peek(path);
    if (cached?.thumbnailPath != null) {
      _thumbnailPath = cached!.thumbnailPath;
      return;
    }

    final preview = await MediaPreviewService.instance.load(path);
    if (!mounted || preview?.thumbnailPath == null) return;
    setState(() => _thumbnailPath = preview!.thumbnailPath);
  }

  @override
  Widget build(BuildContext context) {
    return FernAvatar(
      imagePath: _isVideo ? _thumbnailPath : widget.imagePath,
      fallbackIcon: _isVideo ? Icons.movie_outlined : widget.type.icon,
      radius: widget.radius,
      iconSize: widget.radius,
    );
  }
}
