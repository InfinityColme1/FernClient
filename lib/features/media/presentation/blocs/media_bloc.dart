import 'package:flutter_bloc/flutter_bloc.dart';
import 'media_events.dart';
import 'media_states.dart';


class MediaBloc extends Bloc<MediaEvents, MediaStates>{

  MediaBloc() : super(MediaLoading());
}