import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// El distintivo de una etiqueta NSFW: un recuadro pequeño con la palabra.
///
/// Hace falta porque una etiqueta marcada se ve igual que cualquier otra en
/// todos los sitios donde aparece —el menú lateral, los buscadores, las
/// etiquetas de un contenido—, y con el filtro quitado no hay forma de saber
/// cuál de las que se están usando esconde contenido. Quien asigna una etiqueta
/// sin saber que está marcada acaba de esconder algo sin querer.
///
/// Va **detrás** del nombre y no en el hueco del avatar. Delante tapaba la
/// imagen de la etiqueta, que es con lo que se la reconoce de un vistazo; y un
/// icono suelto tampoco decía qué significaba. Escrito no hay que adivinarlo.
///
/// [NsfwTagMark.compact] es la misma marca **encima de un avatar**, donde va
/// sobre la imagen y no al lado del nombre: con el tamaño de fila se comía media
/// cara. Letra más pequeña y menos aire alrededor, lo justo para seguir
/// leyéndose.
class NsfwTagMark extends StatelessWidget {
  /// Si va sobre un avatar, y por tanto menuda.
  final bool isCompact;

  const NsfwTagMark({super.key}) : isCompact = false;

  const NsfwTagMark.compact({super.key}) : isCompact = true;

  @override
  Widget build(BuildContext context) {
    final style = isCompact
        ? Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: nsfwCompactMarkFontSize,
          )
        : Theme.of(context).textTheme.labelSmall;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? AppSpacing.xs : AppSpacing.s,
        vertical: isCompact ? AppSpacing.xxs : AppSpacing.xxs * 2,
      ),
      decoration: BoxDecoration(
        // El mismo acento con el que la aplicación marca lo que hay que mirar
        // dos veces, relleno: en una fila de etiquetas con avatares de colores,
        // un borde suelto se pierde.
        color: context.colors.terciary,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        'NSFW',
        style: style?.copyWith(
              // Sobre el acento, el color que se lee en las dos paletas.
              color: context.colors.black,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
      ),
    );
  }
}
