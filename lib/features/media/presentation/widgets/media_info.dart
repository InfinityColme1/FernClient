import 'dart:math' as math;

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/services/file_explorer_service.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/tag_entity.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/assign_creator_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/assign_tag_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/confirm_delete_dialog.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernie_mode_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernie_mode_events.dart';
import 'package:Fern/features/recognition/domain/entities/fernie_entity.dart';
import 'package:Fern/features/recognition/domain/entities/media_suggestion_entity.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernie_mode_states.dart';
import 'package:Fern/features/recognition/presentation/blocs/suggestions_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/suggestions_events.dart';
import 'package:Fern/features/recognition/presentation/blocs/suggestions_states.dart';
import 'package:Fern/features/recognition/presentation/widgets/suggestion_row.dart';
import 'package:Fern/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/core/service_locator.dart';
import 'package:Fern/features/recognition/data/services/suggestion_spotlight.dart';
import 'package:Fern/features/recognition/domain/services/suggestion_groups.dart';
import 'package:Fern/features/recognition/domain/usecases/adopt_fernie_tag_usecase.dart';
import 'package:Fern/features/media/domain/usecases/get_tag_relatives_usecase.dart';
import 'package:Fern/core/ui/display/nsfw_tag_mark.dart';
import 'package:Fern/l10n/app_localizations.dart';
import 'package:Fern/features/media/domain/services/content_visibility.dart';
import 'package:Fern/features/media/domain/services/viewer_save_action.dart';
import 'package:Fern/features/nsfw/domain/services/nsfw_visibility.dart';
import 'package:Fern/features/media/presentation/widgets/creator_tags.dart';
import 'package:Fern/features/media/presentation/widgets/tag_log_dialog.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
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
          child: Padding(
            padding: AppSpacing.infoPadding,
            child: Column(
              children: [
                Expanded(
                  child: _InfoContent(
                    media: media,
                    fernieMode: fernieMode,
                    suggestions: suggestions,
                  ),
                ),
                const SizedBox(height: AppSpacing.l),

                // Acciones fijas: quedan fuera de la zona desplazable.
                FernActionButton(
                  label: texts.actionSave,
                  onPressed: (state.isNew || state.isModified)
                      ? () {
                          // Qué pasa después de guardar: la regla vive aparte,
                          // en `viewerSaveActionFor`, con sus motivos escritos y
                          // su prueba.
                          final action = viewerSaveActionFor(
                            isNew: state.isNew,
                            isReviewing: isReviewing,
                            behavior: context
                                .read<SettingsBloc>()
                                .state
                                .settings
                                .viewerSaveBehavior,
                          );

                          context.read<MediaBloc>().add(SaveMediaEvent(
                                media,
                                goToNext:
                                    action == ViewerSaveAction.goToNext,
                              ));

                          // Lo aceptado pasa a estarlo de verdad justo aquí:
                          // hasta ahora sólo era una etiqueta más entre los
                          // cambios sin guardar. Va **antes** de que el visor
                          // pueda cerrarse o saltar al siguiente, que es lo que
                          // vacía el estado del bloc.
                          suggestions.add(const SuggestionsCommittedEvent());

                          if (action == ViewerSaveAction.close) context.pop();
                        }
                      : null,
                ),
                const SizedBox(height: AppSpacing.s),
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

                    // Revisando una importación se sigue con el siguiente:
                    // descartar es parte de repasar la tanda, y salir del visor
                    // en cada descarte obliga a volver a entrar por el que
                    // venía detrás. Fuera de ahí se cierra, como siempre.
                    final deleted = await deleteMediaWithConfirmation(
                      context,
                      media,
                      goToNext: isReviewing,
                    );

                    // El visor sólo se cierra si el borrado ha salido adelante:
                    // cancelar el aviso deja al usuario donde estaba. Y no se
                    // cierra si va a quedarse en el siguiente — de eso se
                    // encarga el bloc, que además sabe si queda alguno.
                    if (deleted && !isReviewing && context.mounted) {
                      context.pop();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Lo que ocupa el botón de añadir en la cabecera de una sección del panel.
///
/// **El mayor de los dos rótulos, medido aquí y no una constante.** Los dos
/// botones tienen que ocupar lo mismo o sus dos «+» caen en columnas distintas y
/// las dos secciones dejan de parecer la misma cosa; y sus rótulos son de
/// distinto largo —«Añadir etiquetas» y «Añadir fernies»— y de distinto largo en
/// cada lengua. Una constante habría que revisarla cada vez que se toque una
/// traducción, y el día que se olvide el rótulo sale recortado.
///
/// Se mide el texto y se le suma lo que el botón pone alrededor: el círculo, el
/// hueco hasta el rótulo y su propio relleno.
double _addButtonWidth(BuildContext context, List<String> labels) {
  final style = Theme.of(context).textTheme.labelSmall;

  var widest = 0.0;

  for (final label in labels) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: Directionality.of(context),
    )..layout();

    widest = math.max(widest, painter.width);
  }

  return widest + _addButtonChrome;
}

/// Lo que el botón menudo ocupa además del rótulo.
///
/// Su relleno, el círculo —con su borde, que también ocupa— y el hueco hasta el
/// texto, sacados de las mismas medidas con las que se dibuja: así no hay dos
/// sitios que puedan decir cosas distintas.
const double _addButtonChrome = AppSpacing.xs * 2 +
    (AppSizes.borderThin * 2 + AppSpacing.xxs * 2 + AppSizes.iconSmall) +
    AppSpacing.s;

/// Los dos rótulos que tienen que caber, para medirlos juntos.
List<String> _addLabels(AppLocalizations texts) =>
    [texts.addTags, texts.addFernies];

/// El contenido del panel: lo que el contenido tiene puesto.
///
/// **El panel no se desplaza; se desplaza cada lista por su cuenta.** Con un
/// solo desplazamiento para todo, veinte etiquetas empujaban lo demás fuera de
/// la pantalla: para ver los fernies había que subir y para llegar al final de
/// las etiquetas, bajar del todo. Ahora lo de arriba —descripción y creador— se
/// queda fijo, y las dos listas se reparten el alto que sobra y se recorren por
/// dentro.
///
/// Las etiquetas siguen pintándose bajo demanda, con slivers dentro de su
/// sección: el panel aguanta igual con tres que con cientos.
class _InfoContent extends StatelessWidget {
  final MediaEntity media;
  final FernieModeBloc fernieMode;
  final SuggestionsBloc suggestions;

  const _InfoContent({
    required this.media,
    required this.fernieMode,
    required this.suggestions,
  });

  /// Enseña el fichero en el explorador, y avisa si ya no está.
  ///
  /// Que no esté es un caso real: la biblioteca guarda rutas, y un fichero
  /// movido o borrado desde fuera deja la fila apuntando a un sitio vacío.
  Future<void> _reveal(BuildContext context, String path) async {
    final texts = AppLocalizations.of(context);
    final revealed = await const FileExplorerService().reveal(path);

    if (revealed || !context.mounted) return;

    showFernToast(
      context,
      texts.revealInExplorerFailed,
      icon: Symbols.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);
    final tags = media.tags ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lo de arriba, con el alto que pida: son cuatro cosas de tamaño
        // acotado —el título, la descripción (que tiene tope de líneas), el
        // creador y lo que un modelo proponga para él—, así que no hay nada que
        // desplazar aquí.
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      texts.mediaInfoTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  // De dónde ha salido cada cosa que tiene puesta. Es la
                  // pregunta que no tenía dónde mirarse: la aplicación etiqueta
                  // sola por cinco caminos y en el panel todos se ven igual.
                  IconButton(
                    tooltip: texts.actionTagLog,
                    iconSize: AppSizes.iconMedium,
                    onPressed: () => showFernDialog<void, MediaBloc>(
                      context: context,
                      builder: (_) => TagLogDialog(mediaId: media.id),
                    ),
                    icon: const Icon(Symbols.history),
                  ),
                  // Llegar al fichero de verdad. Sólo donde la aplicación sabe
                  // hacerlo: un botón que no hace nada es peor que no tenerlo.
                  if (const FileExplorerService().isSupported)
                    IconButton(
                      tooltip: texts.actionRevealInExplorer,
                      iconSize: AppSizes.iconMedium,
                      onPressed: () => _reveal(context, media.path),
                      icon: const Icon(Symbols.folder_open),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              _DescriptionField(
                mediaId: media.id,
                description: media.description,
              ),
              const SizedBox(height: AppSpacing.l),
              _CreatorRow(media: media),
              _SuggestionList(
                bloc: suggestions,
                fernieMode: fernieMode,
                pick: (state) => state.creatorSuggestions,
                fallbackIcon: Symbols.person,
                title: texts.suggestionCreatorTitle,
                // El creador es uno: aceptar el último sustituye al anterior,
                // que es lo mismo que hace el diálogo de asignarlo.
                //
                // Y con lo que el creador trae consigo, por el mismo sitio que
                // el diálogo: sin eso, aceptar la sugerencia y elegirlo a mano
                // dejaban el contenido distinto.
                apply: (context, which) async {
                  final creator = which.last.creator;
                  if (creator == null) return;

                  // Por el mismo sitio que el diálogo: sin eso, aceptar la
                  // sugerencia y elegirlo a mano dejaban el contenido distinto.
                  final brings = await tagsOfCreator(creator);

                  if (!context.mounted) return;

                  context
                      .read<MediaBloc>()
                      .add(MediaCreatorAssignedEvent(creator, brings: brings));
                },
              ),
              const SizedBox(height: AppSpacing.l),
            ],
        ),

        const SizedBox(height: AppSpacing.l),

        // **Cada lista se desplaza por su cuenta, y el panel no.**
        //
        // Con un solo desplazamiento para todo, veinte etiquetas empujaban lo
        // demás fuera de la pantalla: para ver los fernies había que subir y
        // para llegar al final de las etiquetas, bajar del todo. Ahora las dos
        // secciones se reparten lo que queda de alto y lo que no cabe se
        // desplaza dentro de la suya, así que las dos están siempre a la vista.
        //
        // El reparto es holgado para las etiquetas: son las que crecen.
        Flexible(
          flex: mediaInfoFerniesFlex,
          child: _FerniesSection(media: media, fernieMode: fernieMode),
        ),
        const SizedBox(height: AppSpacing.l),
        Flexible(
          flex: mediaInfoTagsFlex,
          child: _TagsSection(
            media: media,
            fernieMode: fernieMode,
            suggestions: suggestions,
            tags: tags,
          ),
        ),
      ],
    );
  }
}

/// Las etiquetas del contenido y lo que los modelos proponen, con su propio
/// desplazamiento.
///
/// El "+" va **en la cabecera** y no al final de la lista: con veinte etiquetas
/// puestas quedaba en el fondo, así que añadir una empezaba por desplazarse
/// hasta abajo del todo para encontrar el botón — y cuantas más se ponen, más
/// lejos queda. Arriba está siempre a la vista y siempre en el mismo sitio.
class _TagsSection extends StatelessWidget {
  final MediaEntity media;
  final FernieModeBloc fernieMode;
  final SuggestionsBloc suggestions;
  final List<TagEntity> tags;

  const _TagsSection({
    required this.media,
    required this.fernieMode,
    required this.suggestions,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sin icono: al lado del botón con su texto entero no cabía, y lo que
        // el icono dice ya lo dice el título que tiene pegado. Ver
        // [AppSizes.infoPanelWidth].
        FernSectionHeader(
          title: texts.tagsTitle,
          // A la altura del título y con su texto entero: es un botón ancho, se
          // acierta sin apuntar, y está siempre a la vista por muchas etiquetas
          // que haya debajo. El hueco es el mismo que el de los fernies, que es
          // lo que deja los dos «+» en la misma columna.
          trailing: SizedBox(
            width: _addButtonWidth(context, _addLabels(texts)),
            child: FernAddButton.compact(
              label: texts.addTags,
              onTap: () => showFernDialog(
                context: context,
                bloc: context.read<MediaBloc>(),
                builder: (_) => AssignTagDialog(media: media),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        // Con slivers a propósito: las etiquetas se pintan bajo demanda, así que
        // esto aguanta igual con tres que con cientos.
        Flexible(
          child: CustomScrollView(
            slivers: [
        // Las etiquetas van directamente sobre el fondo del panel: ni píldora,
        // ni sombra, ni esquinas redondeadas.
        SliverList.separated(
          itemCount: tags.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.l),
          itemBuilder: (context, index) {
            final tag = tags[index];

            return Align(
              alignment: Alignment.centerLeft,
              child: FernChip.plain(
                label: tag.name,
                leading: FernAvatar(
                  imagePath: tag.picturePath,
                  fallbackIcon: Symbols.label,
                  radius: AppSizes.avatarMedium,
                  iconSize: AppSizes.iconMedium,
                  backgroundColor: context.colors.secondary,
                ),
                trailing: tag.isUnderNsfw ? const NsfwTagMark() : null,
                // Con su cruz, como las sugerencias de aquí debajo: quitar una
                // etiqueta era lo único que había que ir a hacer a la pantalla
                // de gestión, y encima allí se quita de lo que esté marcado en
                // la rejilla y no del contenido que se está mirando.
                onRemove: () => context.read<MediaBloc>().add(
                      RemoveTagFromMediaEvent(
                        mediaId: media.id,
                        tagId: tag.id,
                      ),
                    ),
              ),
            );
          },
        ),

        // Debajo de las etiquetas de verdad y encima del "+": lo que el
        // contenido lleva va primero, y lo que un modelo propone después, que es
        // el orden en el que se lee «esto es, y esto podría ser».
        SliverToBoxAdapter(
          child: _SuggestionList(
            bloc: suggestions,
            fernieMode: fernieMode,
            // Las que no proponen nada van aquí también: no se pueden
            // aceptar, pero sí rechazar, que es lo que las quita de en medio y
            // deja de señalar el contenido como pendiente.
            pick: (state) => [
              ...state.tagSuggestions,
              ...state.unlinkedSuggestions,
            ],
            fallbackIcon: Symbols.label,
            adoptsUnlinked: true,
            apply: (context, which) async {
              // Lo que viene con las aceptadas se pide a la base, y en esa
              // espera el panel puede haberse cerrado: sin la comprobación,
              // aceptar una sugerencia y cambiar de contenido a la vez
              // reventaba.
              final tags = await _withTags(media, which);

              if (!context.mounted) return;

              _updateMedia(context, media.copyWith(tags: tags));
            },
          ),
        ),

        // Un respiro al final: la última etiqueta no puede quedar pegada al
        // borde del panel.
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.l)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Los fernies que tienen alguna región marcada en este contenido.
///
/// Es la sección desde la que se entra al modo de marcar: el botón de la
/// cabecera y el "+" hacen lo mismo, porque un fernie es regiones más etiqueta y
/// asignarlo sin marcar nada no serviría para entrenar. La lista de aquí son los
/// que ya están marcados **en esto**, no todos los de la aplicación.
class _FerniesSection extends StatelessWidget {
  final MediaEntity media;
  final FernieModeBloc fernieMode;

  const _FerniesSection({required this.media, required this.fernieMode});

  /// Entra al modo de marcar, recordando si el panel estaba abierto para
  /// dejarlo como estaba al salir.
  void _enterFernieMode(BuildContext context) {
    final showInfo = context.read<MediaBloc>().state.showInfo;

    fernieMode.add(EnterFernieModeEvent(infoWasOpen: showInfo));
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return BlocBuilder<FernieModeBloc, FernieModeState>(
      bloc: fernieMode,
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // El botón de añadir a la altura del título, igual que el de las
          // etiquetas y con el mismo hueco: las dos secciones son lo mismo —una
          // lista de lo que el contenido lleva puesto— y ponerlo en un sitio en
          // una y en otro en la otra obliga a buscarlo cada vez.
          //
          // El atajo de siempre sigue en la barra del visor.
          // Sin icono, como la de etiquetas y por lo mismo.
          FernSectionHeader(
            title: texts.ferniesTitle,
            trailing: SizedBox(
              width: _addButtonWidth(context, _addLabels(texts)),
              child: FernAddButton.compact(
                label: texts.addFernies,
                onTap: () => _enterFernieMode(context),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          // Con su propio desplazamiento: la cabecera se queda fija y lo que no
          // quepa se recorre aquí dentro, sin empujar a las etiquetas de abajo.
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
          // En fila y bajando de línea: el panel es estrecho y los fernies de un
          // mismo contenido pueden ser unos cuantos.
          Wrap(
            spacing: AppSpacing.l,
            runSpacing: AppSpacing.m,
            children: [
              // Los que siguen atados al contenido, no los que se han llegado
              // a tocar: borrar la última región de un fernie lo desata, y aquí
              // tiene que dejar de verse en el acto.
              for (final fernie in state.ferniesInMedia)
                FernAvatarTile(
                  label: fernie.name,
                  imagePath: fernie.picturePath,
                  fallbackIcon: Symbols.face_retouching_natural,
                  // Pulsar un fernie lleva a su pantalla, donde están todas
                  // sus regiones y no sólo las de este contenido.
                  //
                  // Va con `go` y no con `push`: el visor está apilado sobre el
                  // armazón de la aplicación, así que apilar encima la pantalla
                  // de fernies montaría un segundo armazón con las mismas claves
                  // globales que el primero, y eso revienta.
                  onTap: () =>
                      context.go(fernieManagerRouteWithFernie(fernie.id)),
                ),
            ],
          ),
          if (state.ferniesInMedia.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s),
              child: Text(
                texts.fernieNoneHere,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: context.colors.unremarked),
              ),
            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Descripción del contenido.
///
/// Cada pulsación se guarda en el estado del bloc; a la base de datos sólo baja
/// cuando se pulsa "Save".
class _DescriptionField extends StatefulWidget {
  final int mediaId;
  final String? description;

  const _DescriptionField({required this.mediaId, this.description});

  @override
  State<_DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<_DescriptionField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.description);
  }

  @override
  void didUpdateWidget(covariant _DescriptionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sólo al cambiar de contenido: si se reconstruyera con cada pulsación se
    // perdería la posición del cursor.
    if (oldWidget.mediaId == widget.mediaId) return;
    _controller.text = widget.description ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      minLines: 1,
      maxLines: mediaDescriptionMaxLines,
      keyboardType: TextInputType.multiline,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).descriptionHint,
      ),
      onChanged: (value) =>
          context.read<MediaBloc>().add(UpdateMediaDescriptionEvent(value)),
    );
  }
}

/// Avatar, título y nombre del creador; al pulsar el avatar abre el diálogo de
/// asignación.
class _CreatorRow extends StatelessWidget {
  final MediaEntity media;

  const _CreatorRow({required this.media});

  ContentVisibility get _visibility => getIt.isRegistered<NsfwVisibility>()
      ? getIt<NsfwVisibility>()
      : const ContentVisibility();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        FernEditableAvatar(
          imagePath: media.creator.picturePath,
          fallbackIcon: Symbols.person,
          radius: AppSizes.avatarMedium,
          iconSize: AppSizes.iconMedium,
          overlayIconSize: AppSizes.iconMedium,
          backgroundColor: context.colors.secondary,
          onTap: () => showFernDialog(
            context: context,
            bloc: context.read<MediaBloc>(),
            builder: (_) => AssignCreatorDialog(media: media),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).createdBy,
                style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.gray),
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      media.creator.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  // Como con las etiquetas de aquí debajo: con el filtro quitado
                  // hay que poder distinguir al que esconde algo.
                  if (_visibility.marksCreator(media.creator.id)) ...[
                    const SizedBox(width: AppSpacing.s),
                    const NsfwTagMark(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Las sugerencias de una clase, o nada si no hay ninguna.
///
/// No reserva sitio cuando está vacía —ni cabecera, ni hueco, ni un «no hay
/// sugerencias»—: la mayoría de los contenidos no tienen ninguna, y una sección
/// vacía permanente en un panel estrecho es papel gastado en decir que no pasa
/// nada.
class _SuggestionList extends StatelessWidget {
  final SuggestionsBloc bloc;

  /// El modo de marcar del visor, para poder abrirlo con lo que el modelo vio.
  ///
  /// Llega por parámetro y no por el árbol, como en el resto del panel: lo crea
  /// el visor y muere con él.
  final FernieModeBloc fernieMode;

  /// Cuáles de las que hay le tocan a esta lista.
  final List<MediaSuggestionEntity> Function(SuggestionsState) pick;

  /// Qué hacer con el contenido al aceptar. Es lo único que cambia entre la
  /// lista de etiquetas y la de creador: una añade a una lista y la otra
  /// sustituye un valor.
  ///
  /// Vacío significa que esta lista no sabe poner nada, y entonces no aparece
  /// el botón de aceptar.
  final void Function(BuildContext, List<MediaSuggestionEntity>)? apply;

  /// Si aceptar una que no propone nada le da al fernie su etiqueta.
  ///
  /// Sólo en la lista de etiquetas. La de creador no lo hace ni podría: lo que
  /// se crearía es una etiqueta, y ahí lo que hace falta es un creador.
  final bool adoptsUnlinked;

  final IconData fallbackIcon;

  /// Encabezado, si esta lista necesita decir de qué va. Las de etiqueta no lo
  /// llevan: van justo debajo de las etiquetas y se entiende solo.
  final String? title;

  const _SuggestionList({
    required this.bloc,
    required this.fernieMode,
    required this.pick,
    required this.fallbackIcon,
    this.apply,
    this.title,
    this.adoptsUnlinked = false,
  });

  /// Dice que sí: pone lo propuesto en el contenido y aparta la sugerencia.
  ///
  /// Las dos cosas van juntas siempre. La etiqueta se queda entre los cambios
  /// sin guardar del contenido, y la sugerencia no baja a la base de datos hasta
  /// que se guarde: si se apuntara ya y el usuario se fuera sin guardar,
  /// quedaría contestada sin que la etiqueta llegara a ponerse.
  Future<void> _accept(
    BuildContext context,
    List<MediaSuggestionEntity> which,
  ) async {
    final acceptable = [for (final one in which) if (_canAccept(one)) one];
    if (acceptable.isEmpty) return;

    final resolved = await _adopted(acceptable);
    if (resolved.isEmpty || !context.mounted) return;

    apply!(context, resolved);
    bloc.add(SuggestionsAcceptedEvent(resolved));

    getIt<SuggestionSpotlight>()
        .releaseIf([for (final one in resolved) one.id]);
  }

  /// Las mismas sugerencias, con las que no proponían nada ya resueltas.
  ///
  /// El fernie que no enlaza ninguna etiqueta se queda con la que se llama como
  /// él —la que ya hubiera, o una nueva— y enlazado con ella. **Eso se escribe
  /// en el momento**, a diferencia de poner la etiqueta en el contenido, que
  /// sigue esperando a Guardar como todo lo demás del panel: la etiqueta tiene
  /// que existir de verdad para poder ponérsela a nada.
  ///
  /// La que no se pueda resolver se queda sin contestar en vez de darse por
  /// aceptada: apartarla sin haber puesto nada es perder la sugerencia y no
  /// poner la etiqueta, que es lo peor de las dos opciones.
  Future<List<MediaSuggestionEntity>> _adopted(
    List<MediaSuggestionEntity> which,
  ) async {
    if (!adoptsUnlinked) return which;

    final resolved = <MediaSuggestionEntity>[];

    for (final one in which) {
      if (one.proposes != FernieLinkKind.none) {
        resolved.add(one);
        continue;
      }

      final adopted =
          await getIt<AdoptFernieTagUseCase>()(params: one.fernie);
      if (adopted.data case final tag?) resolved.add(one.withTag(tag));
    }

    return resolved;
  }

  /// Si hay algo que poner en el contenido al decir que sí.
  ///
  /// Lo que no propone nada también, cuando la lista sabe adoptarlo: el modelo
  /// acierta, se ve que acierta, y hasta ahora lo único que se podía hacer con
  /// esa fila era decirle que no.
  bool _canAccept(MediaSuggestionEntity suggestion) =>
      apply != null &&
      (suggestion.proposes != FernieLinkKind.none ||
          (adoptsUnlinked && suggestion.fernie.name.trim().isNotEmpty));

  void _reject(List<MediaSuggestionEntity> which) {
    if (which.isEmpty) return;

    bloc.add(SuggestionsRejectedEvent(which));

    getIt<SuggestionSpotlight>()
        .releaseIf([for (final one in which) one.id]);
  }

  /// Enseña sobre el contenido dónde vio el modelo lo que propone esta fila.
  ///
  /// **Todas las veces que lo vio.** Cuatro coches en una foto son cuatro cajas
  /// de la misma fila, y enseñar sólo una dejaba las otras tres sin forma de
  /// verse.
  void _spotlight(SuggestionGroup? group) {
    final spotlight = getIt<SuggestionSpotlight>();

    if (group == null) {
      spotlight.clear();

      return;
    }

    spotlight.show(_boxesOf(group));
  }

  /// Deja las cajas puestas, o las quita si ya lo estaban.
  void _pin(SuggestionGroup group) {
    final boxes = _boxesOf(group);
    if (boxes.isEmpty) return;

    getIt<SuggestionSpotlight>().pin(boxes);
  }

  /// Las cajas de un grupo, las que tengan.
  ///
  /// Un modelo booleano dice que algo está pero no dónde: esas detecciones no se
  /// pueden pintar, pero siguen contando en la fila.
  List<SpottedBox> _boxesOf(SuggestionGroup group) => [
        for (final one in group.located)
          (
            id: one.id,
            box: one.box!,
            label: one.label,
            frameMs: one.frameMs,
          ),
      ];

  /// Abre el modo de marcar con lo que el modelo vio, para confirmarlo.
  ///
  /// **No lo guarda a ciegas**, que es lo que hacía antes. Un modelo que ve
  /// cuatro coches puede estar acertando en tres, y guardar los cuatro deja tres
  /// regiones buenas y una que hay que buscar y borrar. Así se ven dibujados y
  /// se pulsa lo que esté bien, o se aceptan todos de una vez.
  ///
  /// No contesta la sugerencia: marcar dónde está algo y decir que la etiqueta
  /// es correcta son dos cosas, y quien acaba de marcar la región puede querer
  /// rechazar la etiqueta igualmente.
  void _markRegion(BuildContext context, SuggestionGroup group) {
    final located = group.located;
    if (located.isEmpty) return;

    fernieMode.add(ProposedRegionsOfferedEvent(
      infoWasOpen: context.read<MediaBloc>().state.showInfo,
      // Al aceptar sus regiones, estas sugerencias quedan contestadas: ir a
      // mirarlas, darlas por buenas y volver a aceptar la fila es decir dos
      // veces lo mismo.
      suggestionIds: group.ids,
      regions: [
        for (final one in located)
          ProposedRegion(
            rect: Rect.fromLTWH(
              one.box!.x,
              one.box!.y,
              one.box!.w,
              one.box!.h,
            ),
            // Entero y no sólo su identificador: el fernie puede no tener
            // todavía ninguna región en este contenido, y entonces el modo no
            // sabría de dónde sacar su nombre para la pastilla.
            fernie: one.fernie,
            confidence: one.confidence,
            label: one.label,
            frameMs: one.frameMs,
          ),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return BlocBuilder<SuggestionsBloc, SuggestionsState>(
      bloc: bloc,
      builder: (context, state) {
        final suggestions = pick(state);
        if (suggestions.isEmpty) return const SizedBox.shrink();

        // Lo mismo visto varias veces es **una fila**: es la misma etiqueta, y
        // ponerla cuatro veces no significa nada. Las cuatro cajas siguen ahí
        // para señalarlas y para poder marcarlas como regiones.
        final groups = groupSuggestions(suggestions);

        final label = title;

        // Con una sola no hay nada que agrupar: los dos botones de la fila ya
        // hacen exactamente lo mismo que harían los de «todas», y repetirlos
        // encima sólo haría dudar de si son distintos.
        final canAnswerAll = suggestions.length > 1;
        final canAcceptAll = suggestions.any(_canAccept);
        final canAnswerGroups = groups.length > 1;

        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null) ...[
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: context.colors.unremarked),
                ),
                const SizedBox(height: AppSpacing.s),
              ],
              for (final group in groups)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.m),
                  child: SuggestionRow(
                    suggestion: group.best,
                    group: group,
                    fallbackIcon: fallbackIcon,
                    // La cruz y el visto van sobre el grupo entero: aceptar pone
                    // la etiqueta una vez —es la misma— y da por contestadas
                    // todas. Las regiones se eligen aparte.
                    onAccept: _canAccept(group.best)
                        ? () => _accept(context, group.instances)
                        : null,
                    onReject: () => _reject(group.instances),
                    onMarkRegion: () => _markRegion(context, group),
                    onSpotlight: _spotlight,
                    onSpotlightPinned: _pin,
                  ),
                ),
              if (canAnswerAll && canAnswerGroups)
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _reject(suggestions),
                      child: Text(texts.suggestionRejectAll),
                    ),
                    if (canAcceptAll)
                      TextButton(
                        onPressed: () => _accept(context, suggestions),
                        child: Text(texts.suggestionAcceptAll),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Deja el contenido con los cambios puestos, sin bajarlos a la base de datos.
///
/// Se queda entre lo que está sin guardar, igual que la descripción o las
/// etiquetas que se añaden a mano: aceptar una sugerencia no es una excepción a
/// cómo funciona el panel, y confirmarla en el acto dejaría media pantalla
/// transaccional y media inmediata.
void _updateMedia(BuildContext context, MediaEntity media) {
  context.read<MediaBloc>().add(UpdateMediaInfoEvent(media));
}

/// Las etiquetas del contenido más las que se acaban de aceptar.
///
/// Sin repetir: dos modelos distintos pueden proponer la misma etiqueta, y
/// aceptar las dos no puede dejarla puesta dos veces.
///
/// Con lo que viene con ellas —sus hermanas y la rama de todas—, igual que al
/// ponerlas a mano desde el diálogo. Sin eso, aceptar «Rombo simple» no pone
/// «Rombo» y el contenido no aparece al buscar por la etiqueta padre: la misma
/// acción daría dos resultados distintos según por dónde se haga.
Future<List<TagEntity>> _withTags(
  MediaEntity media,
  List<MediaSuggestionEntity> accepted,
) async {
  final tags = List<TagEntity>.of(media.tags ?? const []);
  final puestas = <TagEntity>[];

  for (final one in accepted) {
    final tag = one.tag;
    if (tag == null) continue;
    if (tags.any((existing) => existing.id == tag.id)) continue;

    tags.add(tag);
    puestas.add(tag);
  }

  if (puestas.isEmpty) return tags;

  final relatives = await getIt<GetTagRelativesUseCase>()(params: puestas);
  if (relatives is! DataSuccess || relatives.data == null) return tags;

  for (final tag in relatives.data!) {
    if (tags.any((existing) => existing.id == tag.id)) continue;

    tags.add(tag);
  }

  return tags;
}
