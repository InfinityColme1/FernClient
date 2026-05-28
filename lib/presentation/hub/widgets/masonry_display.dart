import 'dart:io';
import 'package:fernclient/core/config/theme/app_colors.dart';
import 'package:fernclient/data/models/media_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MediaMasonryDisplay extends StatelessWidget {
  final List<MediaItem> items;

  const MediaMasonryDisplay({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int columns = (screenWidth / 250).round().clamp(2, 6);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: MasonryGridView.builder(
        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
        ),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => print('Abrir ventana dedicada para: ${item.id}'), //TODO
              child: Card(
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Image.file(
                      File(item.path),
                      fit: BoxFit.cover,
                      cacheWidth: 400, 
                    ),
                    
                    if (item.type == MediaType.video)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.play_arrow_rounded, 
                                color: Colors.white, 
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDuration(item.duration),
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return "--:--";
    
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return "$hours:${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }
}