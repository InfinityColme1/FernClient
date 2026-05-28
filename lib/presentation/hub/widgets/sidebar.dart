
import 'package:fernclient/core/config/assets/app_icons.dart';
import 'package:fernclient/core/config/assets/app_vectors.dart';
import 'package:fernclient/presentation/hub/bloc/hub_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final hubCubit = context.read<HubCubit>();
    final List<Widget> sidebarItems = [];

    sidebarItems.add(SvgPicture.asset(AppVectors.logo));

    for (var section in hubCubit.sections) {
      sidebarItems.add(
        Padding(
          padding: const EdgeInsets.all(5),
          child: Text(section.name)
        )
      );

      for (var option in section.options) {
        sidebarItems.add(
          ListTile(
            leading: Icon(AppIcons.getIcon(option)),
            title: Text(option),
            onTap: () {
              //TODO
            },
          )
        );
      }

      sidebarItems.add(const Divider());
    }

    return Drawer(
      child: SafeArea(
        child: ListView.builder(
          itemCount: sidebarItems.length,
          itemBuilder: (context, idx) {
            return sidebarItems[idx];
          }
        )
      ),
    );

  }
}