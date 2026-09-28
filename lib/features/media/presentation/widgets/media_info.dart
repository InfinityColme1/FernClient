import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/services/viewer_save_action.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/confirm_delete_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/media_info_body.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernie_mode_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/suggestions_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/suggestions_events.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Panel lateral con los datos del contenido que se está viendo.
///
/// Se divide en dos: una zona desplazable con los datos editables y, fija
/// debajo, las acciones de guardar y borrar.
class MediaInfo extends StatelessWidget {
  /// El modo del visor.
  ///
  /// Llega por parámetro y no por el árbol: el panel vive dentro del visor, que
  /// es quien lo crea, y un `BlocProvider` sólo para esto añadiría un
  /// `InheritedWidget` que hay que desmontar con cuidado al salir.
  final FernieModeBloc fernieMode;

  /// Lo que los modelos proponen sobre este contenido.
  ///
  /// Llega por parámetro por lo mismo que [fernieMode]: lo crea el visor, vive
  /// con él y muere con él.
  final SuggestionsBloc suggestions;

  /// Si guardar pasa al siguiente contenido en vez de cerrar el visor.
  ///
  /// Sólo llega puesto desde la pantalla de importación: el salto existe para
  /// revisar una tanda recién traída sin volver a la rejilla entre uno y otro.
  /// Abriendo desde la biblioteca, desde una etiqueta o desde un fernie se ha
  /// ido a **ese** contenido, y saltar al guardar sería perder de vista lo que
  /// se estaba mirando.
  final bool isReviewing;

  const MediaInfo({
    super.key,
    required this.fernieMode,
    required this.suggestions,
    this.isReviewing = false,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return BlocBuilder<MediaBloc, MediaStates>(
      builder: (context, state) {
        final media = state.currentMedia;

        if (media == null) {
          return const SizedBox.shrink();
        }

        // Lo que ya está en la papelera se borra del todo, igual que con el
        // botón del visor: es el mismo contenido y el mismo sitio del que sale.
        final isMarked = state.isCurrentMediaMarked;

        return ColoredBox(
          color: context.colors.background,
          // **Aquí sólo el relleno de arriba y de abajo.** El de los lados lo
          // pone cada parte: el cuerpo ocupa el panel de lado a lado para que
          // lo que asoma de sus piezas —el velo de una cabecera, los botones de
          // un avatar— caiga dentro de algo, que es lo único que Flutter deja
          // pulsar. Con el relleno por fuera, eso quedaba recortado y muerto.
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.infoPadding.vertical / 2,
            ),
            child: Column(
              children: [
                Expanded(
                  child: MediaInfoBody(
                    media: media,
                    fernieMode: fernieMode,
                    suggestions: suggestions,
                  ),
                ),
                const SizedBox(height: AppSpacing.l),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: mediaInfoGutter,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // **Ya no hay botón de guardar.** El panel baja lo que se
                      // toca conforme se toca: salir del visor no pierde nada, y
                      // un botón que hay que acordarse de pulsar para que no se
                      // pierda lo escrito es justo lo que se ha quitado.
                      //
                      // Lo que queda es la confirmación, y sólo revisando una
                      // importación: dar un contenido por revisado es lo único
                      // que seguía necesitando una decisión. Desde la biblioteca
                      // no hay nada que confirmar.
                      if (isReviewing) ...[
                        FernActionButton(
                          label: texts.actionImport,
                          onPressed: () {
                            // Qué pasa después de confirmar: la regla vive
                            // aparte, en `viewerSaveActionFor`, con sus motivos
                            // escritos y su prueba.
                            final action = viewerSaveActionFor(
                              isNew: state.isNew,
                              isReviewing: isReviewing,
                              behavior: context
                                  .read<SettingsBloc>()
                                  .state
                                  .settings
                                  .viewerSaveBehavior,
                            );

                            context.read<MediaBloc>().add(
                              SaveMediaEvent(
                                media,
                                goToNext: action == ViewerSaveAction.goToNext,
                              ),
                            );

                            // Red por si algo hubiera quedado aceptado sin
                            // contestar: hoy aceptar baja en el acto, pero
                            // cerrarlo aquí cuesta nada y evita que una
                            // sugerencia se quede preguntando lo mismo para
                            // siempre. Va **antes** de que el visor pueda
                            // cerrarse o saltar al siguiente, que es lo que
                            // vacía el estado del bloc.
                            suggestions.add(const SuggestionsCommittedEvent());

                            if (action == ViewerSaveAction.close) context.pop();
                          },
                        ),
                        const SizedBox(height: AppSpacing.s),
                      ],
                      FernActionButton(
                        label: texts.actionDelete,
                        backgroundColor: context.colors.error,
                        foregroundColor: Colors.white,
                        onPressed: () async {
                          if (isMarked) {
                            // El visor se cierra solo al quedarse el estado sin
                            // contenido, así que aquí no hay nada más que hacer.
                            await purgeMediaWithConfirmation(context, media);
                            return;
                          }

                          // Revisando una importación se sigue con el
                          // siguiente: descartar es parte de repasar la tanda,
                          // y salir del visor en cada descarte obliga a volver
                          // a entrar por el que venía detrás. Fuera de ahí se
                          // cierra, como siempre.
                          final deleted = await deleteMediaWithConfirmation(
                            context,
                            media,
                            goToNext: isReviewing,
                          );

                          // El visor sólo se cierra si el borrado ha salido
                          // adelante: cancelar el aviso deja al usuario donde
                          // estaba. Y no se cierra si va a quedarse en el
                          // siguiente — de eso se encarga el bloc, que además
                          // sabe si queda alguno.
                          if (deleted && !isReviewing && context.mounted) {
                            context.pop();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
