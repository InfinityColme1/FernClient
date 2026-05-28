import 'package:fernclient/data/models/media_item_model.dart';
import 'package:fernclient/domain/usecases/get_media_uc.dart';
import 'package:fernclient/presentation/hub/bloc/hub_state.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';


class HubSection {
  final String _name;
  final List<String> _options;

  HubSection({
    required String name,
    required List<String> options
  }) : _name = name, _options = options;

  String get name => _name;
  List<String> get options => _options;
}

final gallerySection = HubSection(
  name: "Gallery", 
  options: ["Media", "Import", "Favorites", "Collections", "Deleted"]
);

final recognition = HubSection(
  name: "Recognition", 
  options: ["Fernies", "Repeated Media", "Model"]
);


class HubCubit extends HydratedCubit<HubState> {
  HubCubit({
    required GetMediaItemsUseCase getMediaItemsUseCase}) 
    : _getMediaItemsUseCase = getMediaItemsUseCase,
      super(HubState(selectedOption: 0));

  final List<HubSection> sections = [gallerySection, recognition];

  final GetMediaItemsUseCase _getMediaItemsUseCase;

  void loadAllMedia() async {
    emit(state.copyWith(status: HubStatus.loading));
    try {
      final List<MediaItem> items = await _getMediaItemsUseCase.execute();
      emit(state.copyWith(mediaList: items));
    } catch (e) {
      emit(state.copyWith(status: HubStatus.error));
    }
  }

  @override
  HubState? fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
    throw UnimplementedError();
  }
  
  @override
  Map<String, dynamic>? toJson(HubState state) {
    // TODO: implement toJson
    throw UnimplementedError();
  }
  
}