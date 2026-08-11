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
import 'package:Fern/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Panel lateral con los datos del contenido que se está viendo.
///
/// Se divide en dos: una zona desplazable con los datos editables y, fija
/// debajo, las acciones de guardar y borrar.
class MediaInfo extends StatelessWidget {
  const MediaInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final texts = AppLocalizations.of(context);

    return BlocBuilder<MediaBloc, MediaStates>(
      builder: (context, state) {
        final media = state.currentMedia;

        if (media == null) {
          return const SizedBox.shrink();
        }

        return ColoredBox(
          color: AppColors.background,
          child: Padding(
            padding: AppSpacing.infoPadding,
            child: Column(
              children: [
                Expanded(child: _InfoContent(media: media)),
                const SizedBox(height: AppSpacing.l),

                // Acciones fijas: quedan fuera de la zona desplazable.
                FernActionButton(
                  label: texts.actionSave,
                  onPressed: (state.isNew || state.isModified)
                      ? () {
                          context.read<MediaBloc>().add(SaveMediaEvent(media));

                          // El contenido pendiente de revisar se abre desde la
                          // pantalla de importación; al darlo por definitivo
                          // deja de estar allí, así que se vuelve atrás para
                          // ver la lista ya sin él.
                          if (state.isNew) context.pop();
                        }
                      : null,
                ),
                const SizedBox(height: AppSpacing.s),
                FernActionButton(
                  label: texts.actionDelete,
                  backgroundColor: AppColors.terciary,
                  foregroundColor: AppColors.white,
                  onPressed: () {
                    context.read<MediaBloc>().add(DeleteMediaEvent(media));
                    context.pop();
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
/// Las secciones que llegarán después (colecciones en vertical, fernies en
/// horizontal) encajan como slivers más en esta misma lista.
class _InfoContent extends StatelessWidget {
  final MediaEntity media;

  const _InfoContent({required this.media});

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
                  backgroundColor: AppColors.secondary,
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
          backgroundColor: AppColors.secondary,
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
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.gray),
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
