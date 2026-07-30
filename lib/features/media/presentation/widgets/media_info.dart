import 'dart:io';

import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/assign_tag_dialog.dart';
import 'package:Fern/features/media/presentation/widgets/edit_creator_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MediaInfo extends StatefulWidget {
  const MediaInfo({super.key});

  @override
  State<MediaInfo> createState() => _MediaInfoState();
}

class _MediaInfoState extends State<MediaInfo> {
  bool _isHoveringCreator = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<MediaBloc, MediaStates>(
      builder: (context, state) {
        final media = state.currentMedia;

        if (media == null) {
          return const SizedBox.shrink();
        }

        return Container(
          color: AppColors.background,
          padding: AppSpacing.infoPadding,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Media Info",
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: "Add a description",
                        ),
                        onChanged: (value) {
                          context.read<MediaBloc>().add(UpdateMediaInfoEvent(media));
                        },
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      
                      // Created by section
                      _buildSectionHeader(Icons.face_unlock_outlined, "Created by:"),
                      const SizedBox(height: AppSpacing.l),
                      Row(
                        children: [
                          MouseRegion(
                            onEnter: (_) => setState(() => _isHoveringCreator = true),
                            onExit: (_) => setState(() => _isHoveringCreator = false),
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => EditCreatorDialog(creator: media.creator),
                                );
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: AppSizes.avatarLarge,
                                    backgroundImage: media.creator.picturePath != null
                                        ? FileImage(File(media.creator.picturePath!))
                                        : null,
                                    child: media.creator.picturePath == null
                                        ? const Icon(Icons.person, size: AppSizes.avatarLarge)
                                        : null,
                                  ),
                                  if (_isHoveringCreator)
                                    Container(
                                      width: AppSizes.avatarXLarge,
                                      height: AppSizes.avatarXLarge,
                                      decoration: const BoxDecoration(
                                        color: Colors.black38,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.edit, color: AppColors.white),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.l),
                          Text(
                            media.creator.name,
                            style: theme.textTheme.titleMedium?.copyWith(fontFamily: 'Courier'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Collections Section (Mock)
                      _buildSectionHeader(Icons.folder_open_outlined, "Collections"),
                      const SizedBox(height: AppSpacing.m),
                      Row(
                        children: [
                          const CircleAvatar(radius: AppSizes.avatarMedium, backgroundColor: AppColors.lightgray),
                          const SizedBox(width: AppSpacing.m),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Marinette's Album", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Courier')),
                              Text("24 elements", style: theme.textTheme.labelSmall?.copyWith(color: AppColors.gray)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Fernies Section (Mock)
                      _buildSectionHeader(Icons.person_search_outlined, "Fernies"),
                      const SizedBox(height: AppSpacing.l),
                      Row(
                        children: [
                          _buildAddButton("Add", onTap: () {}),
                          const SizedBox(width: AppSpacing.l),
                          const _MockAvatar(name: "Marinette\nDupain-Cheng"),
                          const SizedBox(width: AppSpacing.l),
                          const _MockAvatar(name: "Adrien\nAgreste"),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Tags Section
                      _buildSectionHeader(Icons.label_outline, "Tags"),
                      const SizedBox(height: AppSpacing.l),
                      if (media.tags != null)
                        ...media.tags!.map((tag) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.m),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (tag.picturePath != null)
                                   ClipOval(
                                       child: Image.file(
                                           File(tag.picturePath!),
                                           width: AppSizes.avatarXLarge,
                                           height: AppSizes.avatarXLarge,
                                           fit: BoxFit.cover
                                       )
                                   )
                                else
                                  const Icon(Icons.circle, size: AppSizes.avatarXLarge, color: Colors.red),
                                const SizedBox(width: AppSpacing.m),
                                Text(
                                    tag.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight:
                                        FontWeight.bold,
                                        fontFamily: 'Courier'
                                    )),
                              ],
                            ),
                          ),
                        )),
                      const SizedBox(height: AppSpacing.s),
                      _buildAddButton("Add Tag", onTap: () {
                         showDialog(
                           context: context,
                           builder: (context) => AssignTagDialog(media: media),
                         );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Bottom Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton(
                      onPressed: (state.isNew || state.isModified)
                          ? () => context.read<MediaBloc>().add(SaveMediaEvent(media))
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                      ),
                      child: Text(
                        state.isNew ? "Import" : "Save",
                        style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<MediaBloc>().add(DeleteMediaEvent(media));
                        context.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.terciary,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconMedium, color: AppColors.gray),
        const SizedBox(width: AppSpacing.s),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.gray),
        ),
      ],
    );
  }

  Widget _buildAddButton(String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.black, width: 2),
            ),
            child: const Icon(Icons.add, size: AppSizes.iconLarge, color: AppColors.black),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _MockAvatar extends StatelessWidget {
  final String name;
  const _MockAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(radius: AppSizes.avatarLarge, backgroundColor: AppColors.lightgray),
        const SizedBox(height: AppSpacing.s),
        Text(
          name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
