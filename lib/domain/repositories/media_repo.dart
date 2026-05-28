
import 'package:fernclient/data/models/media_item_model.dart';

abstract class MediaRepository {
  Future<List<MediaItem>> getMediaItems();
}