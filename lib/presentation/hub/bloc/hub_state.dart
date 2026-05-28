// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import 'package:fernclient/data/models/media_item_model.dart';

enum HubStatus {
  loading,
  success,
  empty,
  error
}


class HubState extends Equatable {
  final int selectedOption;
  final List<MediaItem> mediaList;
  final HubStatus status;

  const HubState({
    this.selectedOption = 0,
    this.mediaList = const [],
    this.status = HubStatus.loading
  });

  
  @override
  List<Object?> get props => [selectedOption, mediaList, status];


  HubState copyWith({
    int? selectedOption,
    List<MediaItem>? mediaList,
    HubStatus? status,
  }) {
    return HubState(
      selectedOption: selectedOption ?? this.selectedOption,
      mediaList: mediaList ?? this.mediaList,
      status: status ?? this.status,
    );
  }
}
