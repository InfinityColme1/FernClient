import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/ui/ui.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/assign_creator_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/assign_tag_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/confirm_delete_dialog.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernie_mode_bloc.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernie_mode_events.dart';
import 'package:Fern/features/recognition/presentation/blocs/fernie_mode_states.dart';
import 'package:Fern/features/settings/domain/entities/app_settings_entity.dart';
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

  const MediaInfo({super.key, required this.fernieMode});

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
                  child: _InfoContent(media: media, fernieMode: fernieMode),
                ),
                const SizedBox(height: AppSpacing.l),

                // Acciones fijas: quedan fuera de la zona desplazable.
                FernActionButton(
                  label: texts.actionSave,
                  onPressed: (state.isNew || state.isModified)
                      ? () {
                          // El contenido pendiente de revisar se abre desde la
                          // pantalla de importación; al darlo por definitivo
                          // deja de estar allí, así que el visor no puede
                          // quedarse donde estaba: o pasa al siguiente o se
                          // cierra, según lo que el usuario tenga elegido.
                          final goToNext = state.isNew &&
                              context
                                      .read<SettingsBloc>()
                                      .state
                                      .settings
                                      .viewerSaveBehavior ==
                                  ViewerSaveBehavior.goToNext;

                          context
                              .read<MediaBloc>()
                              .add(SaveMediaEvent(media, goToNext: goToNext));

                          if (state.isNew && !goToNext) context.pop();
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

                    // El visor sólo se cierra si el borrado ha salido adelante:
                    // cancelar el aviso deja al usuario donde estaba.
                    final deleted =
                        await deleteMediaWithConfirmation(context, media);
                    if (deleted && context.mounted) context.pop();
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

/// Zona desplazable del panel.
///
/// Está construida con slivers a propósito: las etiquetas se pintan bajo
/// demanda, así que el panel aguanta igual con tres etiquetas que con cientos.
/// La sección de fernies encaja como un sliver más; la de colecciones, cuando
/// llegue, hará lo mismo.
class _InfoContent extends StatelessWidget {
  final MediaEntity media;
  final FernieModeBloc fernieMode;

  const _InfoContent({required this.media, required this.fernieMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context);
    final tags = media.tags ?? const [];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(texts.mediaInfoTitle, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.m),
              _DescriptionField(
                mediaId: media.id,
                description: media.description,
              ),
              const SizedBox(height: AppSpacing.l),
              _CreatorRow(media: media),
              const SizedBox(height: AppSpacing.l),
              _FerniesSection(media: media, fernieMode: fernieMode),
              const SizedBox(height: AppSpacing.l),
              FernSectionHeader(
                icon: Icons.label_outline,
                title: texts.tagsTitle,
              ),
              const SizedBox(height: AppSpacing.m),
            ],
          ),
        ),

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
                  fallbackIcon: Icons.label,
                  radius: AppSizes.avatarMedium,
                  iconSize: AppSizes.iconMedium,
                  backgroundColor: context.colors.secondary,
                ),
              ),
            );
          },
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.l),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FernAddButton.inline(
                label: texts.addTag,
                onTap: () => showFernDialog(
                  context: context,
                  bloc: context.read<MediaBloc>(),
                  builder: (_) => AssignTagDialog(media: media),
                ),
              ),
            ),
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
        children: [
          // La cabecera no lleva botón: el "+" de abajo ya entra al modo de
          // marcar, y dos botones para lo mismo en la misma sección sólo hacen
          // dudar de si hacen cosas distintas. El atajo de siempre está en la
          // barra del visor.
          FernSectionHeader(
            icon: Icons.face_retouching_natural_outlined,
            iconAsset: icFernie,
            title: texts.ferniesTitle,
          ),
          const SizedBox(height: AppSpacing.m),
          // En fila y bajando de línea: el panel es estrecho y los fernies de un
          // mismo contenido pueden ser unos cuantos.
          Wrap(
            spacing: AppSpacing.l,
            runSpacing: AppSpacing.m,
            children: [
              FernAddButton(
                label: texts.addFernie,
                onTap: () => _enterFernieMode(context),
              ),
              // Los que siguen atados al contenido, no los que se han llegado
              // a tocar: borrar la última región de un fernie lo desata, y aquí
              // tiene que dejar de verse en el acto.
              for (final fernie in state.ferniesInMedia)
                FernAvatarTile(
                  label: fernie.name,
                  imagePath: fernie.picturePath,
                  fallbackIcon: Icons.face_retouching_natural,
                  fallbackAsset: icFernie,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        FernEditableAvatar(
          imagePath: media.creator.picturePath,
          fallbackIcon: Icons.person,
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
              Text(
                media.creator.name,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
