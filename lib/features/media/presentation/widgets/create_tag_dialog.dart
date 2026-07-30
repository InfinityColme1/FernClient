import 'dart:io';
import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/core/widgets/fern_dialog.dart';
import 'package:Fern/core/widgets/fern_search_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateTagDialog extends StatefulWidget {
  const CreateTagDialog({super.key});

  @override
  State<CreateTagDialog> createState() => _CreateTagDialogState();
}

class _CreateTagDialogState extends State<CreateTagDialog> {
  final TextEditingController _nameController = TextEditingController();
  String? _selectedImagePath;

  @override
  Widget build(BuildContext context) {
    return FernDialog(
      onClose: () => context.pop(),
      leftContent: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              // TODO: Implement image picker
            },
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.secondary,
              backgroundImage: _selectedImagePath != null ? FileImage(File(_selectedImagePath!)) : null,
              child: _selectedImagePath == null 
                  ? const Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.primary) 
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "New Tag",
            style: TextStyle(
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
          const Text(
            "Tag Name",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Courier'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: "Enter name",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 24),
          const FernSearchInput(
            label: "Parent tag (Optional)",
            hintText: "Search parent tag",
            suggestions: ["Tag1", "Tag2", "Tag3"], // Mock
          ),
        ],
      ),
      actionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          // TODO: Save tag logic
          context.pop();
        },
        child: const Text("Create", style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold)),
      ),
    );
  }
}
