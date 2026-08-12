// lib/features/media/presentation/widgets/media_item.dart

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/services/media_preview_service.dart';
import 'package:Fern/core/utils/media_type.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../domain/entities/media/media_summary_entity.dart';

/// Celda de la rejilla multimedia.
///
/// Se encarga de tres cosas: pintar el contenido a máxima calidad (recortando
/// antes que escalar hacia arriba), dar respuesta visual al ratón y, en el caso
/// de los vídeos, reproducir una previsualización en bucle mientras el cursor
/// está encima.
class MediaItem extends StatefulWidget {
  final MediaSummaryEntity media;
  final VoidCallback? onTap;

  /// `true` si el elemento forma parte de la selección actual.
  final bool isSelected;

  /// Se invoca al pulsar el botón de selección que aparece al pasar el ratón.
  final VoidCallback? onSelectionToggled;

  /// Se invoca al pulsar con la tecla mayúsculas, tanto en el contenido como en
  /// el botón de selección: en vez de tocar sólo este elemento, la selección se
  /// extiende desde el último marcado hasta él.
  final VoidCallback? onRangeSelectionRequested;

  /// Se invoca, una sola vez por fichero, cuando el contenido no se ha podido
  /// cargar. Quien lo escuche decide qué hacer con el contenido.
  final VoidCallback? onLoadFailed;

  const MediaItem({
    super.key,
    required this.media,
    this.onTap,
    this.isSelected = false,
    this.onSelectionToggled,
    this.onRangeSelectionRequested,
    this.onLoadFailed,
  });

  @override
  State<MediaItem> createState() => _MediaItemState();
}

class _MediaItemState extends State<MediaItem> {
  MediaPreview? _preview;
  bool _isHovered = false;

  Player? _player;
  VideoController? _videoController;
  StreamSubscription<Duration>? _positionSubscription;
  bool _isPreviewReady = false;

  /// Evita repetir el aviso de fallo de carga: la celda se reconstruye muchas
  /// veces (scroll, hover, selección) y el fichero sigue siendo el mismo.
  bool _loadFailureReported = false;

  bool get _isVideo => widget.media.path.isVideoPath;

  @override
  void initState() {
    super.initState();
    _preview = MediaPreviewService.instance.peek(widget.media.path);
    if (_preview == null) _loadPreview();
  }

  @override
  void didUpdateWidget(covariant MediaItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.path == widget.media.path) return;

    _stopPreview();
    _loadFailureReported = false;
    _preview = MediaPreviewService.instance.peek(widget.media.path);
    if (_preview == null) _loadPreview();
  }

  @override
  void dispose() {
    _stopPreview();
    super.dispose();
  }

  Future<void> _loadPreview() async {
    final preview = await MediaPreviewService.instance.load(widget.media.path);
    if (preview == null) {
      _reportLoadFailure();
      return;
    }
    if (!mounted) return;
    setState(() => _preview = preview);
  }

  /// Avisa de que este contenido no se ha podido cargar.
  ///
  /// No se juzga aquí el motivo: sólo se cuenta lo que ha pasado y quien
  /// escucha comprueba si el fichero sigue estando.
  void _reportLoadFailure() {
    if (_loadFailureReported) return;
    _loadFailureReported = true;
    widget.onLoadFailed?.call();
  }

  /// Extiende la selección si se está pulsando mayúsculas. Devuelve `true`
  /// cuando lo ha hecho, para que el clic no siga su camino normal.
  bool _extendSelection() {
    final extend = widget.onRangeSelectionRequested;
    if (extend == null || !HardwareKeyboard.instance.isShiftPressed) {
      return false;
    }
    extend();
    return true;
  }

  /// Clic sobre el contenido: abre el visor, salvo que se esté pulsando
  /// mayúsculas para estirar la selección.
  void _onTap() {
    if (_extendSelection()) return;
    widget.onTap?.call();
  }

  void _onSelectionPressed() {
    if (_extendSelection()) return;
    widget.onSelectionToggled?.call();
  }

  void _onHoverChanged(bool isHovered) {
    if (_isHovered == isHovered) return;
    setState(() => _isHovered = isHovered);

    if (!_isVideo) return;
    isHovered ? _startPreview() : _stopPreview();
  }

  Future<void> _startPreview() async {
    if (_player != null) return;

    final player = Player(
      configuration: const PlayerConfiguration(
        muted: true,
        logLevel: MPVLogLevel.error,
      ),
    );
    final controller = VideoController(player);
    _player = player;
    _videoController = controller;

    // Los vídeos más largos que la previsualización vuelven al principio al
    // llegar al límite; los más cortos se repiten solos con el modo bucle.
    _positionSubscription = player.stream.position.listen((position) {
      if (position >= mediaVideoPreviewLength) player.seek(Duration.zero);
    });

    try {
      await player.setPlaylistMode(PlaylistMode.loop);
      await player.setVolume(0);
      await player.open(Media(widget.media.path));

      if (!mounted || !_isHovered) {
        _stopPreview();
        return;
      }
      setState(() => _isPreviewReady = true);
    } catch (e) {
      debugPrint('MediaItem: no se pudo previsualizar el vídeo: $e');
      _reportLoadFailure();
      _stopPreview();
    }
  }

  void _stopPreview() {
    _positionSubscription?.cancel();
    _positionSubscription = null;

    final player = _player;
    _player = null;
    _videoController = null;
    player?.dispose();

    if (!_isPreviewReady) return;
    _isPreviewReady = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = _preview?.aspectRatio ?? mediaFallbackAspectRatio;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedScale(
          scale: _isHovered ? mediaHoverScale : 1.0,
          duration: hoverAnimationDuration,
          curve: Curves.easeOut,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildContent(),
                  _buildTopShade(),
                  if (_isVideo) _buildVideoBadge(),
                  _buildSelectionButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isPreviewReady && _videoController != null) {
      return Video(
        controller: _videoController!,
        controls: NoVideoControls,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      );
    }

    final path = _isVideo ? _preview?.thumbnailPath : widget.media.path;
    if (path == null) return _buildPlaceholder();

    return LayoutBuilder(
      builder: (context, constraints) => Image.file(
        File(path),
        // El fichero identifica a la imagen: cambiar de contenido (la celda se
        // reaprovecha al desplazar la rejilla) tiene que empezar de cero, y no
        // dejar a la vista la imagen anterior como hace `gaplessPlayback`.
        key: ValueKey(path),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
        // Cambiar de resolución no deja la celda en blanco: se sigue viendo lo
        // que ya estaba descodificado hasta que la nueva está lista. Sin esto,
        // reescalar la ventana apaga y enciende todas las imágenes de la
        // rejilla en cada fotograma.
        gaplessPlayback: true,
        // Se decodifica a la resolución en la que se va a pintar (nunca por
        // debajo), que es lo que evita el efecto borroso.
        cacheWidth: _decodeWidth(context, constraints.maxWidth),
        errorBuilder: (_, _, _) {
          _reportLoadFailure();
          return _buildPlaceholder();
        },
      ),
    );
  }

  /// Ancho de decodificación en píxeles físicos, limitado por el ancho real del
  /// fichero para no gastar memoria escalando hacia arriba.
  ///
  /// Va a saltos de [mediaDecodeWidthStep]: es la clave con la que se guarda la
  /// imagen descodificada, así que si siguiera al ancho exacto de la celda, un
  /// reescalado de la ventana la haría descodificar de nuevo desde el disco en
  /// cada fotograma. Redondea hacia arriba para no perder resolución.
  int? _decodeWidth(BuildContext context, double layoutWidth) {
    if (!layoutWidth.isFinite || layoutWidth <= 0) return null;

    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final target = (layoutWidth * devicePixelRatio * mediaHoverScale).ceil();
    final stepped =
        (target / mediaDecodeWidthStep).ceil() * mediaDecodeWidthStep;
    final intrinsic = _preview?.width;

    if (intrinsic == null || intrinsic <= 0) return stepped;
    return math.min(stepped, intrinsic);
  }

  Widget _buildPlaceholder() {
    return ColoredBox(
      color: AppColors.lightgray,
      child: Icon(
        _isVideo ? Icons.movie_outlined : Icons.broken_image_outlined,
        color: AppColors.white,
        size: AppSizes.iconExtraLarge,
      ),
    );
  }

  /// Sombreado interior en la parte superior, sólo visible bajo el cursor.
  Widget _buildTopShade() {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: _isHovered ? 1.0 : 0.0,
        duration: hoverAnimationDuration,
        child: FractionallySizedBox(
          alignment: Alignment.topCenter,
          heightFactor: mediaShadeHeightFactor,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.black.withValues(alpha: mediaShadeOpacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoBadge() {
    return Positioned(
      top: AppSpacing.s,
      left: AppSpacing.s,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: mediaBadgeOpacity),
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.white,
                size: AppSizes.iconSmall,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _formatDuration(_preview?.duration),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionButton() {
    final isVisible = _isHovered || widget.isSelected;

    return Positioned(
      top: AppSpacing.xs,
      right: AppSpacing.xs,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: hoverAnimationDuration,
        child: IgnorePointer(
          ignoring: !isVisible,
          child: IconButton(
            onPressed: _onSelectionPressed,
            tooltip: widget.isSelected
                ? AppLocalizations.of(context).deselectItem
                : AppLocalizations.of(context).selectItem,
            visualDensity: VisualDensity.compact,
            iconSize: AppSizes.iconMedium,
            icon: Icon(
              widget.isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: widget.isSelected ? AppColors.terciary : AppColors.white,
              shadows: [
                Shadow(
                  color: AppColors.black
                      .withValues(alpha: mediaSelectionShadowOpacity),
                  blurRadius: AppSpacing.xs,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return mediaEmptyDurationLabel;

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if (hours == 0) return '$minutes:$seconds';
    return '$hours:${minutes.toString().padLeft(2, '0')}:$seconds';
  }
}
