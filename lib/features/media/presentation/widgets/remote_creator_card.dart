import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/remote_creator.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';

/// Un creador de una fuente remota, para elegir de quién traerse contenido.
///
/// Es la celda de la rejilla cuando la pantalla de importación está enseñando
/// creadores en vez de contenido. Dice tres cosas, y las tres deciden si merece
/// la pena pulsarla:
///
/// - **Quién es**: su avatar y su nombre en la plataforma.
/// - **Cuánto ha publicado desde la última vez**, si se sabe. Es lo que
///   convierte una lista de cincuenta nombres en una lista de tres que
///   interesan. Pero saberlo cuesta una petición por creador, así que con
///   cincuenta marcados casi nunca llega a tiempo — y para los que nunca se ha
///   importado no llega jamás, porque no hay con qué comparar. Mientras tanto se
///   enseña **cuándo se importó de él por última vez** y si ha publicado desde
///   entonces: las dos cosas salen de fechas que ya se tienen y están desde el
///   primer momento. Lo que no se enseña nunca es un cero que en realidad
///   significa «todavía no lo he contado».
/// - **Si ya se le tiene dado de alta aquí.** Sin esto, una lista de cincuenta
///   no distingue a quien se lleva siguiendo meses de un hallazgo.
class RemoteCreatorCard extends StatefulWidget {
  final RemoteCreator creator;
  final bool isSelected;

  /// Traerse lo de este creador, ahora.
  final VoidCallback? onTap;

  /// Marcarlo para traerse lo de varios de una vez.
  final VoidCallback? onSelectionToggled;

  const RemoteCreatorCard({
    super.key,
    required this.creator,
    this.isSelected = false,
    this.onTap,
    this.onSelectionToggled,
  });

  @override
  State<RemoteCreatorCard> createState() => _RemoteCreatorCardState();
}

class _RemoteCreatorCardState extends State<RemoteCreatorCard> {
  bool _isHovered = false;

  RemoteCreator get creator => widget.creator;
  bool get isSelected => widget.isSelected;
  VoidCallback? get onSelectionToggled => widget.onSelectionToggled;

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        // Con el botón derecho se marca sin traerse nada: es la forma de juntar
        // varios sin que el primero arranque su importación.
        onSecondaryTap: onSelectionToggled,
        child: AnimatedScale(
          // El mismo gesto que la rejilla de contenido: la tarjeta crece un poco
          // bajo el cursor. Sin nada de esto no parecía que se pudiera pulsar.
          scale: _isHovered ? mediaHoverScale : 1.0,
          duration: hoverAnimationDuration,
          curve: Curves.easeOut,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusSurface),
              // Marcado se dice con el borde, que es lo que hace la rejilla de
              // contenido con lo seleccionado.
              border: Border.all(
                color: isSelected
                    ? context.colors.primary
                    : Colors.transparent,
                width: mediaHighlightBorderWidth,
              ),
            ),
            child: FernSurface(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  _avatar(context),
                  if (onSelectionToggled != null) _selectionMark(context),
                ],
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                creator.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (creator.service.isNotEmpty)
                Text(
                  creator.service,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: context.colors.gray),
                ),
              const SizedBox(height: AppSpacing.s),
              _news(context, texts),
              if (creator.isKnown) ...[
                const SizedBox(height: AppSpacing.xs),
                _knownMark(context, texts),
              ],
            ],
          ),
        ),
            ),
          ),
        ),
      ),
    );
  }

  /// Su avatar en la plataforma, o su inicial si no lo tiene.
  ///
  /// Es de la red y no del disco, que es lo que lo distingue de los avatares de
  /// la aplicación: este creador todavía no existe aquí, así que no hay ningún
  /// fichero suyo que enseñar.
  Widget _avatar(BuildContext context) {
    const size = AppSizes.avatarLarge * 2;

    return ClipOval(
      child: SizedBox.square(
        dimension: size,
        child: creator.avatarUrl == null
            ? _initial(context)
            : Image.network(
                creator.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _initial(context),
              ),
      ),
    );
  }

  Widget _initial(BuildContext context) {
    final letter = creator.name.trim();

    return ColoredBox(
      color: context.colors.secondary,
      child: Center(
        child: Text(
          letter.isEmpty ? '?' : letter.characters.first.toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: context.colors.black),
        ),
      ),
    );
  }

  /// Cuántas publicaciones nuevas tiene; y si no se sabe, cuándo se le importó.
  ///
  /// La cuenta es mejor dato, así que gana siempre que esté. Pero llega tarde o
  /// no llega, y una tarjeta que no dice nada no sirve para elegir: la fecha se
  /// lee del disco y está desde el primer momento.
  Widget _news(BuildContext context, AppLocalizations texts) {
    final count = creator.newPosts;
    final theme = Theme.of(context);

    if (count == null) return _lastImport(context, texts);

    return Text(
      texts.remoteCreatorNewPosts(count),
      textAlign: TextAlign.center,
      style: theme.textTheme.labelSmall?.copyWith(
        color: creator.hasNews ? context.colors.primary : context.colors.gray,
        fontWeight: creator.hasNews ? FontWeight.w600 : null,
      ),
    );
  }

  /// Cuándo se importó de este creador por última vez, y si ha publicado desde
  /// entonces.
  ///
  /// Las dos cosas salen de fechas que ya se tienen —la de aquí, del disco; la
  /// suya, del mismo listado que trajo la tarjeta—, así que no cuestan ninguna
  /// petición y están desde el primer momento.
  ///
  /// «Nunca» no es una ausencia de dato: es el dato, y además el que más dice de
  /// una lista de creadores marcados — ése es el que está sin estrenar.
  Widget _lastImport(BuildContext context, AppLocalizations texts) {
    final at = creator.lastImport;
    final theme = Theme.of(context);

    if (at == null) return _highlighted(context, texts.remoteCreatorNeverImported);

    final when = DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
        .format(at);

    if (creator.hasNews) {
      return _highlighted(context, texts.remoteCreatorNewsSince(when));
    }

    return Text(
      texts.remoteCreatorLastImport(when),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: theme.textTheme.labelSmall?.copyWith(color: context.colors.gray),
    );
  }

  /// Lo que hace que una tarjeta destaque entre cincuenta.
  Widget _highlighted(BuildContext context, String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  /// A este creador ya se le tiene dado de alta aquí.
  Widget _knownMark(BuildContext context, AppLocalizations texts) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Symbols.bookmark_added,
          size: AppSizes.iconSmall,
          color: context.colors.terciary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            texts.remoteCreatorKnown,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: context.colors.terciary),
          ),
        ),
      ],
    );
  }

  Widget _selectionMark(BuildContext context) {
    return GestureDetector(
      onTap: onSelectionToggled,
      child: Icon(
        isSelected ? Symbols.check_circle : Symbols.circle,
        color: isSelected ? context.colors.primary : context.colors.gray,
        size: AppSizes.iconMedium,
      ),
    );
  }
}
