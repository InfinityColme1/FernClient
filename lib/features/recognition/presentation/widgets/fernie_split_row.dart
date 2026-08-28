import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/domain/entities/model_fernie_entity.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Un fernie dentro de un modelo: quién es, cuánto aporta y cómo se reparte.
///
/// El reparto se toca arrastrando los dos tiradores de la barra. Se eligió barra
/// y no tres campos numéricos porque lo que importa es la **proporción**, y tres
/// números que tienen que sumar cien obligan a hacer cuentas para cambiar uno.
class FernieSplitRow extends StatefulWidget {
  final ModelFernieEntity assignment;

  /// Se avisa **al soltar**, no en cada movimiento.
  ///
  /// Mientras se arrastra, la barra se mueve sola con lo que lleva a medias: por
  /// aquí sale un cambio que hay que guardar, y guardar en cada movimiento del
  /// ratón escribe en la base de datos decenas de veces por segundo y deja el
  /// tirador arrastrándose detrás del dedo.
  final ValueChanged<DatasetSplit>? onSplitChanged;

  final VoidCallback? onRemove;

  const FernieSplitRow({
    super.key,
    required this.assignment,
    this.onSplitChanged,
    this.onRemove,
  });

  @override
  State<FernieSplitRow> createState() => _FernieSplitRowState();
}

class _FernieSplitRowState extends State<FernieSplitRow> {
  /// El reparto a medias, mientras se arrastra.
  ///
  /// Se queda puesto hasta que llega de vuelta el guardado: soltarlo antes
  /// enseñaría un instante el valor viejo, que es el parpadeo que se quiere
  /// evitar.
  DatasetSplit? _draft;

  DatasetSplit get _split => _draft ?? widget.assignment.split;

  @override
  void didUpdateWidget(covariant FernieSplitRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_draft != null && widget.assignment.split == _draft) _draft = null;
  }

  void _commit() {
    final draft = _draft;
    if (draft == null) return;

    widget.onSplitChanged?.call(draft);
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final assignment = widget.assignment;
    final fernie = assignment.fernie;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FernAvatar(
                imagePath: fernie.picturePath,
                fallbackIcon: Symbols.face_retouching_natural,
                radius: AppSizes.avatarMedium,
                iconSize: AppSizes.iconMedium,
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fernie.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    _counts(context, texts),
                  ],
                ),
              ),
              if (widget.onRemove != null)
                IconButton(
                  tooltip: texts.modelRemoveFernie,
                  onPressed: widget.onRemove,
                  icon: Icon(
                    Symbols.close,
                    size: AppSizes.iconMedium,
                    color: context.colors.unremarked,
                  ),
                ),
            ],
          ),
          _warningLine(context, texts),
          const SizedBox(height: AppSpacing.s),
          _SplitBar(
            split: _split,
            // Mientras se arrastra sólo se mueve el dibujo; lo que hay que
            // guardar sale al soltar.
            onChanged: widget.onSplitChanged == null
                ? null
                : (split) => setState(() => _draft = split),
            onChangeEnd: _commit,
          ),
          const SizedBox(height: AppSpacing.xs),
          _numbers(context, texts),
        ],
      ),
    );
  }

  /// Cuántas regiones aporta y sobre cuántos contenidos, con su aviso.
  ///
  /// Los dos números hacen falta: cien regiones de un solo fichero enseñan el
  /// fondo, no el objeto, y eso no se ve mirando sólo el primero.
  Widget _counts(BuildContext context, AppLocalizations texts) {
    final fernie = widget.assignment.fernie;
    final theme = Theme.of(context);

    return Text(
      '${texts.modelRegionCount(fernie.regionCount)} · '
      '${texts.modelMediaCount(fernie.mediaCount)}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall
          ?.copyWith(color: context.colors.unremarked),
    );
  }

  /// El aviso, entero.
  ///
  /// Va en su propia línea y ocupando el ancho de la fila, no al lado de los
  /// números: son frases que explican **por qué** el modelo va a salir malo, y
  /// cortadas con puntos suspensivos no explican nada. En la columna estrecha
  /// del detalle sólo cabían cuatro palabras.
  ///
  /// Se deja envolver en las líneas que haga falta por lo mismo: es un aviso que
  /// se lee una vez y se actúa, no una etiqueta que tenga que caber siempre en
  /// el mismo sitio.
  Widget _warningLine(BuildContext context, AppLocalizations texts) {
    final warning = _warning(texts);
    if (warning == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Symbols.warning_amber,
            size: AppSizes.iconSmall,
            color: context.colors.error,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              warning,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Lo que hay que decirle al usuario antes de que entrene y se lleve el
  /// chasco.
  ///
  /// Con muy pocas regiones no se puede entrenar en absoluto; con pocos
  /// contenidos se puede, pero el modelo aprenderá el fondo en lugar del objeto,
  /// y eso no se ve en las métricas: salen bien y luego falla con todo lo demás.
  String? _warning(AppLocalizations texts) {
    final fernie = widget.assignment.fernie;

    if (fernie.regionCount < minRegionsPerClass) {
      return texts.modelTooFewRegions(minRegionsPerClass);
    }
    if (fernie.mediaCount < minMediaPerClass) return texts.modelTooFewMedia;
    if (fernie.regionCount < lowRegionsPerClass) {
      return texts.modelFewRegions(lowRegionsPerClass);
    }

    return null;
  }

  Widget _numbers(BuildContext context, AppLocalizations texts) {
    final split = _split;
    final theme = Theme.of(context);

    Widget number(String label, int value, Color color) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSpacing.s,
            height: AppSpacing.s,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            '$label $value%',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: context.colors.unremarked),
          ),
        ],
      );
    }

    return Wrap(
      spacing: AppSpacing.m,
      runSpacing: AppSpacing.xxs,
      children: [
        number(texts.splitTrain, split.train, context.colors.terciary),
        number(texts.splitValidation, split.validation, context.colors.gray),
        number(texts.splitTest, split.test, context.colors.lightgray),
      ],
    );
  }
}

/// La barra de tres tramos con sus dos tiradores.
///
/// El gesto va en la barra entera y no en cada tirador: al empezar a arrastrar
/// se mira cuál de los dos está más cerca y se mueve ése. Así se puede agarrar
/// en cualquier punto —no hay que acertarle a una línea de dos píxeles— y los
/// tiradores se quedan siendo sólo dibujo.
class _SplitBar extends StatefulWidget {
  final DatasetSplit split;
  final ValueChanged<DatasetSplit>? onChanged;

  /// Se ha soltado. Es cuando lo que se llevaba a medias pasa a ser definitivo.
  final VoidCallback? onChangeEnd;

  const _SplitBar({required this.split, this.onChanged, this.onChangeEnd});

  @override
  State<_SplitBar> createState() => _SplitBarState();
}

class _SplitBarState extends State<_SplitBar> {
  /// Cuál se está arrastrando: `0` el que separa entrenar de validar, `1` el que
  /// separa validar de probar.
  int? _dragging;

  double get _first => widget.split.train / 100;
  double get _second =>
      (widget.split.train + widget.split.validation) / 100;

  void _start(double fraction) {
    _dragging =
        (fraction - _first).abs() <= (fraction - _second).abs() ? 0 : 1;
  }

  void _move(double fraction) {
    final onChanged = widget.onChanged;
    if (onChanged == null) return;

    final percent = (fraction * 100).round().clamp(0, 100);
    final split = widget.split;

    onChanged(
      _dragging == 0
          ? split.withTrain(percent)
          : split.withValidation(percent - split.train),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bar = SizedBox(
          height: splitBarHeight,
          child: Stack(
            children: [
              Positioned.fill(child: _segments(context)),
              if (widget.onChanged != null) ...[
                _handle(context, at: _first, width: width),
                _handle(context, at: _second, width: width),
              ],
            ],
          ),
        );

        if (widget.onChanged == null) return bar;

        return MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: (details) =>
                _start(_fractionOf(details.localPosition.dx, width)),
            onHorizontalDragUpdate: (details) =>
                _move(_fractionOf(details.localPosition.dx, width)),
            onHorizontalDragEnd: (_) {
              _dragging = null;
              widget.onChangeEnd?.call();
            },
            child: bar,
          ),
        );
      },
    );
  }

  double _fractionOf(double dx, double width) =>
      width <= 0 ? 0 : (dx / width).clamp(0.0, 1.0);

  Widget _segments(BuildContext context) {
    // Los tramos de cero no se pintan: un `Expanded` con flex cero no ocupa
    // nada, pero deja un borde recto en mitad de la barra.
    Widget part(int flex, Color color) {
      return Expanded(
        flex: flex,
        child: ColoredBox(
          color: color,
          child: const SizedBox(height: splitBarHeight),
        ),
      );
    }

    final split = widget.split;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: Row(
        children: [
          // El de entrenar con el acento: es el trozo grande y el que se mira,
          // y con el lavanda del primario se confundía con la superficie de
          // debajo hasta parecer que la barra estaba vacía. Los otros dos, dos
          // grises de peso distinto: son lo que se aparta.
          if (split.train > 0) part(split.train, context.colors.terciary),
          if (split.validation > 0)
            part(split.validation, context.colors.gray),
          if (split.test > 0) part(split.test, context.colors.lightgray),
        ],
      ),
    );
  }

  /// Un tirador. Sólo dibujo: quien atiende el arrastre es la barra.
  Widget _handle(BuildContext context, {required double at, required double width}) {
    return Positioned(
      left: (width * at - AppSizes.borderRegular / 2)
          .clamp(0.0, (width - AppSizes.borderRegular).clamp(0.0, width)),
      top: 0,
      bottom: 0,
      width: AppSizes.borderRegular,
      child: IgnorePointer(
        child: ColoredBox(color: context.colors.white),
      ),
    );
  }
}
