import 'package:fernclient/data/models/media_item_model.dart';
import 'package:fernclient/domain/repositories/media_repo.dart';

class GetMediaItemsUseCase {
  final MediaRepository repository;

  GetMediaItemsUseCase(this.repository);

  Future<List<MediaItem>> execute() {
    return repository.getMediaItems();
  }
}