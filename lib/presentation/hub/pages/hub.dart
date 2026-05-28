import 'package:fernclient/presentation/hub/bloc/hub_cubit.dart';
import 'package:fernclient/presentation/hub/widgets/masonry_display.dart';
import 'package:fernclient/presentation/hub/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HubPage extends StatelessWidget {
  const HubPage({super.key});
  

  @override
  Widget build(BuildContext context) {
    final hubCubit = context.read<HubCubit>()..loadAllMedia();
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(child: MediaMasonryDisplay(items: hubCubit.state.mediaList))
        ],
      ),
    );
  }
}