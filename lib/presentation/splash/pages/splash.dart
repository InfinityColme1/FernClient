
import 'package:fernclient/core/config/assets/app_vectors.dart';
import 'package:fernclient/presentation/hub/pages/hub.dart';
import 'package:fernclient/presentation/splash/bloc/splash_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashCubit(),
      child: SplashView()
      );
  }
}


class SplashView extends StatelessWidget {
  const SplashView({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state.status == SplashStatus.success) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(
              builder: (BuildContext context) => const HubPage()
              )
          );
        }
      },

      child: Scaffold(
        body: Center(
          child: SvgPicture.asset(AppVectors.logo),
        ),
      ),
    );
  }
}