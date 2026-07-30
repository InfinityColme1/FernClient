import 'dart:io';
import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/core/widgets/fern_dialog.dart';
import 'package:Fern/core/widgets/fern_search_input.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AssignTagDialog extends StatefulWidget {
  final MediaEntity media;
  
  const AssignTagDialog({super.key, required this.media});

  @override
  State<AssignTagDialog> createState() => _AssignTagDialogState();
}

class _AssignTagDialogState extends State<AssignTagDialog> {
  String? selectedTagName;
  String? selectedTagPicture;

  @override
  Widget build(BuildContext context) {
    return FernDialog(
      onClose: () => context.pop(),
      leftContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.secondary,
            backgroundImage: selectedTagPicture != null ? FileImage(File(selectedTagPicture!)) : null,
            child: selectedTagPicture == null ? const Icon(Icons.label, size: 60, color: AppColors.primary) : null,
          ),
          const SizedBox(height: 16),
          Text(
            selectedTagName ?? widget.media.creator.name, // Mocking default name as seen in screenshot
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 2),
        ],
      ),
      rightContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FernSearchInput(
            label: "Parent tag",
            hintText: "Tag",
            suggestions: const ["Tag1", "Tag2", "Tag3", "Tag4"], // Mock suggestions
            onSelected: (val) {
              setState(() {
                selectedTagName = val;
                // Here you would normally lookup the picture for the tag
              });
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // TODO: Open Create Tag Dialog
              print("Open Create Tag Dialog");
            },
            child: const Text(
              "Create Tag",
              style: TextStyle(
                color: AppColors.black,
                decoration: TextDecoration.underline,
                fontFamily: 'Courier',
              ),
            ),
          ),
        ],
      ),
      actionButton: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          // TODO: Confirm assignment
          context.pop();
        },
        icon: const Icon(Icons.check),
        label: const Text("Confirm"),
      ),
    );
  }
}
