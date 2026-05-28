
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'splash_state.dart';

class SplashCubit extends HydratedCubit<SplashState> {
  SplashCubit() : super(const SplashState()) {
    _init();
  }

  void _init() {
    Future.delayed(const Duration(seconds: 2), () {
      emit(state.copyWith(status: SplashStatus.success));
    });
  }
  
  @override
  SplashState? fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
  
  @override
  Map<String, dynamic>? toJson(SplashState state) {
    throw UnimplementedError();
  }
}
