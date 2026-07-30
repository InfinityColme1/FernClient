import 'dart:io';
import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/core/widgets/fern_dialog.dart';
import 'package:Fern/core/widgets/fern_search_input.dart';
import 'package:Fern/features/media/domain/entities/persona/creator_entity.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditCreatorDialog extends StatefulWidget {
  final CreatorEntity creator;
  const EditCreatorDialog({super.key, required this.creator});

  @override
  State<EditCreatorDialog> createState() => _EditCreatorDialogState();
}

class _EditCreatorDialogState extends State<EditCreatorDialog> {
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
            backgroundImage: widget.creator.picturePath != null ? FileImage(File(widget.creator.picturePath!)) : null,
            child: widget.creator.picturePath == null ? const Icon(Icons.person, size: 60, color: AppColors.primary) : null,
          ),
          const SizedBox(height: 16),
          Text(
            widget.creator.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'Courier',
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
          const FernSearchInput(
            label: "Search Creator",
            hintText: "Name",
            suggestions: ["Marinette Dupain-Cheng", "Adrien Agreste", "Gabriel Agreste"],
          ),
          const SizedBox(height: 24),
          const Text(
            "Or create a new one",
            style: TextStyle(fontFamily: 'Courier', fontSize: 12, decoration: TextDecoration.underline),
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
          context.pop();
        },
        icon: const Icon(Icons.check),
        label: const Text("Confirm", style: TextStyle(fontFamily: 'Courier')),
      ),
    );
  }
}
