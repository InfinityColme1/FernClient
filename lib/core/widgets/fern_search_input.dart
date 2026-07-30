import 'package:Fern/config/theme/app_colors.dart';
import 'package:Fern/config/theme/app_sizes.dart';
import 'package:Fern/config/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class FernSearchInput extends StatefulWidget {
  final String label;
  final String hintText;
  final List<String> suggestions;
  final ValueChanged<String>? onSelected;
  final ValueChanged<String>? onChanged;

  const FernSearchInput({
    super.key,
    required this.label,
    this.hintText = '',
    this.suggestions = const [],
    this.onSelected,
    this.onChanged,
  });

  @override
  State<FernSearchInput> createState() => _FernSearchInputState();
}

class _FernSearchInputState extends State<FernSearchInput> {
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _showOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + AppSpacing.xs),
          child: Material(
            elevation: 0.0, // Elevación eliminada
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(color: AppColors.lightgray),
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: widget.suggestions
                    .where((s) => s.toLowerCase().contains(_controller.text.toLowerCase()))
                    .map((suggestion) => ListTile(
                          title: Text(
                            suggestion, 
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'Courier'),
                          ),
                          onTap: () {
                            _controller.text = suggestion;
                            widget.onSelected?.call(suggestion);
                            _hideOverlay();
                            FocusScope.of(context).unfocus();
                          },
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideOverlay();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.black, width: 2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: (val) {
                    widget.onChanged?.call(val);
                    if (val.isNotEmpty) {
                      _showOverlay();
                    } else {
                      _hideOverlay();
                    }
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.l, 
                      vertical: AppSpacing.m
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.cancel, color: AppColors.black),
                            onPressed: () {
                              _controller.clear();
                              _hideOverlay();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
              Positioned(
                top: -10,
                left: 12,
                child: Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: Text(
                    widget.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
