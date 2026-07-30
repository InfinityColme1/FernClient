import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/resources/data_state.dart';
import 'package:Fern/features/media/data/models/media/media_model.dart';
import 'package:Fern/features/media/data/models/media/media_summary_model.dart';
import 'package:Fern/features/media/domain/entities/media/media_entity.dart';
import 'package:Fern/features/media/domain/entities/media/media_summary_entity.dart';
import 'package:Fern/features/media/domain/repositories/local_media_repository.dart';
import 'package:Fern/features/media/data/models/persona/creator_model.dart';
import 'package:Fern/features/media/data/models/tag_model.dart';
import 'package:isar/isar.dart';


class LocalMediaRepositoryImpl implements LocalMediaRepository {

  final Isar _appDatabase;

  LocalMediaRepositoryImpl({required this._appDatabase});


  int _fastHash(String string) {
    var hash = 0xcbf29ce484222325;
    var i = 0;
    while (i < string.length) {
      final codeUnit = string.codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xff;
      hash *= 0x100000001b3;
    }
    return hash;
  }


  Future<void> _saveBatch(List<MediaModel> models) async {
    await _appDatabase.writeTxn(() async {
      await _appDatabase.mediaModels.putAll(models);
    });
  }


  @override
  Stream<DataState<MediaSummaryEntity>> selectAndScanDirectory(String rootPath) {
    return scanDirectory(rootPath);
  }

  @override
  Stream<DataState<MediaSummaryEntity>> scanDirectory(String rootPath) async* {
    try {
      final dir = Directory(rootPath);
      if (!await dir.exists()) {
        yield DataException(Exception("Directory does not exist: $rootPath"));
        return;
      }

      final validExtensions = {'.jpg', '.jpeg', '.webp', '.gif', '.png', '.mp4', '.mov', '.avi'};

      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final path = entity.path;
          final lastDotIndex = path.lastIndexOf('.');
          
          if (lastDotIndex != -1) {
            final extension = path.substring(lastDotIndex).toLowerCase();
            if (validExtensions.contains(extension)) {
              yield DataSuccess(
                  MediaSummaryEntity(
                      id: _fastHash(path),
                      path: path
                  )
              );
            }
          }
        }
      }

    } on Exception catch (e) {
      yield DataException(e);
    }
  }

  @override
  Future<DataState> saveScannedMedia(List<MediaEntity> mediaList) async {
    try {
      final models = mediaList.map((e) => MediaModel.fromEntity(e)).toList();
      await _saveBatch(models);

      return DataSuccess(null);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState<List<MediaSummaryEntity>>> getMediaList() async{
    try {
      final query = await _appDatabase.mediaSummaryModels.where().findAll();

      List<MediaSummaryEntity> result = [];
      for (var value in query) {
        result.add(value.toEntity());
      }
      
      return DataSuccess(result);

    } on Exception catch (e) {
     return DataException(e);
    }
  }

  @override
  Future<DataState<MediaEntity>> getMediaDetails(int id) async {
    try {
      final query = await _appDatabase.mediaModels.get(id);
      if (query == null) {
        return DataException(Exception("Media not found"));
      }

      return DataSuccess(query.toEntity());

    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState> saveMedia(MediaEntity media) async {
    try {
      // 1. Get or fallback for Creator
      var creatorModel = await _appDatabase.creatorModels.get(media.creator.id);
      if (creatorModel == null) {
        // Fallback to "Unknown" by name or ID 0
        creatorModel = await _appDatabase.creatorModels.filter().nameEqualTo("Unknown").findFirst();
        if (creatorModel == null) {
           creatorModel = CreatorModel.fromEntity(unknownCreator);
           await _appDatabase.writeTxn(() async {
             creatorModel!.id = await _appDatabase.creatorModels.put(creatorModel!);
           });
        }
      }

      // 2. Handle Tags (Error if a specific tag is not found)
      final List<TagModel> tagModels = [];
      if (media.tags != null) {
        for (final tagEntity in media.tags!) {
          final tagModel = await _appDatabase.tagModels.get(tagEntity.id);
          if (tagModel == null) {
            return DataException(Exception("Tag '${tagEntity.name}' does not exist. Please create it first."));
          }
          tagModels.add(tagModel);
        }
      }

      // 3. Get or fallback for Source (Tag)
      TagModel? sourceModel;
      if (media.source != null) {
        sourceModel = await _appDatabase.tagModels.get(media.source!.id);
        if (sourceModel == null) {
          sourceModel = await _appDatabase.tagModels.filter().nameEqualTo("Unknown").findFirst();
          if (sourceModel == null) {
            sourceModel = TagModel.fromEntity(unknownTag);
            await _appDatabase.writeTxn(() async {
              sourceModel!.id = await _appDatabase.tagModels.put(sourceModel!);
            });
          }
        }
      }

      final model = MediaModel.fromEntity(media);

      await _appDatabase.writeTxn(() async {
        await _appDatabase.mediaModels.put(model);
        
        model.creator.value = creatorModel;
        await model.creator.save();

        model.tags.clear();
        model.tags.addAll(tagModels);
        await model.tags.save();

        if (sourceModel != null) {
          model.source.value = sourceModel;
          await model.source.save();
        }
      });

      return DataSuccess(null);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

  @override
  Future<DataState> deleteMedia(int id) async {
    try {
      final media = await _appDatabase.mediaModels.get(id);

      if (media != null) {
        final file = File(media.path);
        if (await file.exists()) {
          await file.delete();
        }

        await _appDatabase.writeTxn(() async {
          await _appDatabase.mediaModels.delete(id);
        });
      }

      return DataSuccess(null);
    } on Exception catch (e) {
      return DataException(e);
    }
  }

}