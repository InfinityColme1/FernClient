
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:fernclient/data/models/media_item_model.dart';
import 'package:fernclient/domain/repositories/media_repo.dart';

class DesktopMediaRepoImpl implements MediaRepository {

  final String targetDir = '';

  @override
  Future<List<MediaItem>> getMediaItems() async{
    final dir = Directory(targetDir);

    if (!await dir.exists()) {
      throw Exception('Directory does not exist');
    }

    List<MediaItem> items = [];

    await for (final FileSystemEntity entity in dir.list(recursive: false)) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        final type = _detectType(ext);

        if (type != null) {
          items.add(
            MediaItem(
              id: entity.path, // En escritorio, la propia ruta única puede ser el ID
              name: p.basename(entity.path),
              path: entity.path,
              type: type,
              origin: 'Directorio Local',
              downloadedAt: (await entity.lastModified()),
              tags: [], 
            ),
          );
        }
      }
    }
    return items;
  }

  MediaType? _detectType(String extension) {
    if (['.jpg', '.jpeg', '.png', '.webp', '.bmp'].contains(extension)) {
      return MediaType.photo;
    }
    if (['.mp4', '.mkv', '.mov', '.avi'].contains(extension)) {
      return MediaType.video;
    }
    if (extension == '.gif') {
      return MediaType.gif;
    }
    return null;
  }
}