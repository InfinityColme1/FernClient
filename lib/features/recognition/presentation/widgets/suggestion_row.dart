import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/recognition/domain/entities/media_suggestion_entity.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Una sugerencia en el panel de información.
///
/// Se pinta **en tono apagado y con su porcentaje**, que es lo que la separa de
/// una etiqueta de verdad. La distinción no es un adorno: el panel es el sitio
/// donde el usuario decide qué lleva su biblioteca, y una propuesta de un modelo
/// que se leyera igual que algo confirmado convertiría cada equivocación del
/// modelo en una etiqueta que nadie puso.
///
/// Los dos botones sólo aparecen si hay algo que hacer con ella. Una sugerencia
/// de un fernie que no enlaza nada —o cuya etiqueta alguien borró— no se puede
/// aceptar: no hay nada que poner. Enseñar el botón y dar un error al pulsarlo
/// sería peor que no enseñarlo.
class SuggestionRow extends StatelessWidget {
  final MediaSuggestionEntity suggestion;

  /// Qué avatar poner cuando lo propuesto no tiene imagen.
  final IconData fallbackIcon;

  /// Qué pasa al decir que sí. Vacío cuando no hay nada que proponer.
  final VoidCallback? onAccept;

  /// Qué pasa al decir que no. Siempre se puede rechazar, hasta lo que no
  /// propone nada: es lo que quita la fila de en medio y le dice al modelo que
  /// se equivocó.
  final VoidCallback? onReject;

  /// Enseñar o dejar de enseñar dónde lo vio el modelo.
  ///
  /// Con la sugerencia al entrar y con `null` al salir. Es un aviso y no el
  /// servicio en sí: la fila no tiene por qué saber quién pinta encima del
  /// contenido, y un widget que va a buscarlo al localizador no se puede montar
  /// en una prueba sin montar medio programa.
  final void Function(MediaSuggestionEntity?)? onSpotlight;

  /// Dejar la caja puesta, o quitarla si ya lo estaba.
  ///
  /// Al pulsar la fila. Lo que enseña el ratón se va con él; esto se queda.
  final void Function(MediaSuggestionEntity)? onSpotlightPinned;

  /// Guardar esta detección como región del fernie que la vio.
  ///
  /// Sin esto la fila no lo ofrece. Una sugerencia sin caja tampoco: no hay
  /// sitio que guardar.
  final VoidCallback? onMarkRegion;

  const SuggestionRow({
    super.key,
    required this.suggestion,
    this.fallbackIcon = Symbols.label,
    this.onAccept,
    this.onReject,
    this.onMarkRegion,
    this.onSpotlight,
    this.onSpotlightPinned,
  });

  /// El color del porcentaje, por tramos.
  ///
  /// El documento pedía verde, ámbar y gris; la paleta no tiene ni verde ni
  /// ámbar y la elige el usuario, así que meterlos a mano dejaría dos colores
  /// que no se pueden cambiar y que en según qué fondo no se leen. Se usa el
  /// mismo reparto que el panel de métricas: el acento para lo bueno.
  ///
  /// El tercer tramo se marca con opacidad y no con un gris distinto porque en
  /// la paleta clara el gris de los textos secundarios y el de lo apagado son
  /// **el mismo color**: pintarlo así dejaría dos de los tres tramos idénticos
  /// justo en el tema que viene puesto de fábrica.
  Color _confidenceColor(BuildContext context) {
    return switch (suggestion.level) {
      SuggestionConfidence.high => context.colors.terciary,
      SuggestionConfidence.medium => context.colors.unremarked,
      SuggestionConfidence.low =>
        context.colors.unremarked.withValues(alpha: suggestionLowOpacity),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);

    final box = suggestion.box;

    return GestureDetector(
      // Pulsar la fila deja la caja puesta. El ratón por encima ya la enseña,
      // pero se va en cuanto el ratón se mueve, y mirar dónde está algo y
      // decidir si la etiqueta es correcta se hacen a la vez: hay que poder
      // dejarla quieta mientras se piensa.
      onTap: box == null || onSpotlightPinned == null
          ? null
          : () => onSpotlightPinned!(suggestion),
      child: MouseRegion(
      // Pasar por encima enseña dónde lo vio. Es la pregunta inmediata al leer
      // «Estrella 66 %», y hasta ahora no tenía respuesta: el rectángulo se
      // guardaba al detectar y no se enseñaba en ninguna parte.
      onEnter: box == null || onSpotlight == null
          ? null
          : (_) => onSpotlight!(suggestion),
      onExit: box == null || onSpotlight == null
          ? null
          : (_) => onSpotlight!(null),
      child: Tooltip(
      message: texts.suggestionFromModel,
      child: Row(
        children: [
          Flexible(
            child: FernChip.plain(
              label: suggestion.label,
              // Apagado, como las etiquetas pendientes del diálogo de asignar:
              // es el mismo estado —algo que todavía no está puesto— y merece
              // el mismo aspecto.
              labelColor: context.colors.unremarked,
              leading: FernAvatar(
                // La cara de lo propuesto, no la del fernie: es la que el
                // usuario va a ver ahí mismo en cuanto acepte.
                imagePath: suggestion.picturePath,
                fallbackIcon: fallbackIcon,
                radius: AppSizes.avatarMedium,
                iconSize: AppSizes.iconMedium,
                backgroundColor: context.colors.secondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Text(
            texts.suggestionConfidence(suggestion.percent),
            style: theme.textTheme.labelSmall?.copyWith(
              color: _confidenceColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          // Lo que el modelo acierta se puede guardar como región con un
          // clic. Es lo que cierra el círculo: sin esto, cada acierto se pierde
          // y hay que volver a marcar a mano lo que ya estaba bien marcado.
          if (onMarkRegion != null && box != null)
            IconButton(
              tooltip: texts.suggestionMarkRegion,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Symbols.crop_free,
                size: AppSizes.iconSmall,
              ),
              onPressed: onMarkRegion,
            ),
          if (onReject != null)
            IconButton(
              tooltip: texts.actionReject,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Symbols.close, size: AppSizes.iconSmall),
              onPressed: onReject,
            ),
          if (onAccept != null)
            IconButton(
              tooltip: texts.actionAccept,
              visualDensity: VisualDensity.compact,
              // El de aceptar va con el acento y el de rechazar con el color de
              // siempre: decir que no es lo que se hace sin pensar, y no
              // necesita que nada tire de la vista hacia él.
              color: context.colors.terciary,
              icon: const Icon(Symbols.check, size: AppSizes.iconSmall),
              onPressed: onAccept,
            ),
        ],
      ),
      ),
      ),
    );
  }
}
