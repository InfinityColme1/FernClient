import 'package:Fern/config/theme/app_colors.dart';
import 'package:flutter/material.dart';

class FernDialog extends StatelessWidget {
  final Widget? leftContent;
  final Widget? rightContent;
  final Widget? actionButton;
  final VoidCallback onClose;

  const FernDialog({
    super.key,
    this.leftContent,
    this.rightContent,
    this.actionButton,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: AppColors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 28),
                  onPressed: onClose,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (leftContent != null)
                      Expanded(flex: 1, child: leftContent!),
                    if (leftContent != null && rightContent != null)
                      const SizedBox(width: 48),
                    if (rightContent != null)
                      Expanded(flex: 1, child: rightContent!),
                  ],
                ),
              ),
              if (actionButton != null) ...[
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.bottomRight,
                  child: actionButton!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
