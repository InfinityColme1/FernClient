import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
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
class NsfwTagMark extends StatelessWidget {
  const NsfwTagMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xxs * 2,
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
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              // Sobre el acento, el color que se lee en las dos paletas.
              color: context.colors.black,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
      ),
    );
  }
}
