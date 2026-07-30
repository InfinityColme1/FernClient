import 'dart:io';

import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/features/media/presentation/blocs/media_bloc.dart';
import 'package:Fern/features/media/presentation/blocs/media_events.dart';
import 'package:Fern/features/media/presentation/blocs/media_states.dart';
import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/service_locator.dart';


class ImportPage extends StatelessWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MediaBloc>.value(
      value: getIt(),
      child: _ImportView(),
    );
  }

}

class _ImportView extends StatelessWidget {
  const _ImportView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MediaBloc, MediaStates>(
        listenWhen: (previous, current) =>
        previous is! DetailedMedia && current is DetailedMedia,

        listener: (context, state) {
          if (state is DetailedMedia) {
            context.push(viewerRoute);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Row(
                children: [
                  TextButton(
                  onPressed: () {
                    context.read<MediaBloc>().add(ScanDirectoryEvent());
                  },
                    child: Text("Import")
                  )
                ],
              ),

              Expanded(
                child: MediaGrid(
                  mediaList: state.mediaList ?? [],
                  columns: 4,
                ),
              )
            ],
          );
        }
    );
  }

}