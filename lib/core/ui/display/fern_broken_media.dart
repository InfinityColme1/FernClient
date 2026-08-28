import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/resources/app_icons.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Lo que se enseña donde tenía que haber un contenido y no lo hay.
///
/// **Un icono suelto no dice qué ha pasado.** Antes cada sitio pintaba el suyo
/// —uno gris claro aquí, uno gris medio allá, con tamaños distintos— y ninguno
/// explicaba nada: quien se lo encuentra no sabe si el fichero está tardando, si
/// se ha movido de carpeta o si la aplicación está rota.
///
/// Es siempre lo mismo: el fichero ya no está donde la biblioteca lo apuntó.
/// Decirlo cuesta una línea, y con ella se sabe que hay que ir a buscarlo y no a
/// reinstalar nada.
///
/// En una miniatura de rejilla no cabe esa línea, y ahí se queda sólo el icono
/// ([FernBrokenMedia.compact]): a ese tamaño lo que hace falta es distinguir de
/// un vistazo la celda rota de las demás, no leerla.
class FernBrokenMedia extends StatelessWidget {
  /// Si es un vídeo lo que falta. Cambia el icono, no el mensaje.
  final bool isVideo;

  /// Sin texto, sólo el icono.
  final bool isCompact;

  const FernBrokenMedia({
    super.key,
    this.isVideo = false,
  }) : isCompact = false;

  const FernBrokenMedia.compact({
    super.key,
    this.isVideo = false,
  }) : isCompact = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final icon = Icon(
      isVideo ? AppIcons.video : AppIcons.brokenMedia,
      color: colors.unremarked,
      size: isCompact ? AppSizes.iconLarge : AppSizes.iconExtraLarge,
    );

    if (isCompact) return Center(child: icon);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(height: AppSpacing.s),
          Text(
            AppLocalizations.of(context).mediaFileMissing,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: colors.unremarked),
          ),
        ],
      ),
    );
  }
}
