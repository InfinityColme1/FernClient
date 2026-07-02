import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../features/media/presentation/widgets/media_thumbnail.dart';
import '../widgets/surface.dart';


const largeScreenMinWidth = 600;


class MainLayout extends StatefulWidget{

  final Widget child;

  const MainLayout({
    super.key,
    required this.child
  });

  @override
  State<StatefulWidget> createState() => _MainLayoutState();
}


class _MainLayoutState extends State<MainLayout> {

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > largeScreenMinWidth;

          if (isLargeScreen) {
            return _buildLargeScreenLayout(context, widget.child);
          }

          return _buildSmallScreenLayout(context, widget.child);
        }
    );
  }

  Widget _buildLargeScreenLayout(BuildContext context, Widget child) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.only(right: 50),
              child:  Image.asset(
                appLogo,
                width: 150,
              ),
            ),

            SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (_) {
                      controller.openView();
                    },
                    leading: const Icon(Icons.search),
                    hintText: "Search",
                  );
                },
                suggestionsBuilder: (BuildContext context, SearchController controller ) {
                  return List<ListTile>.generate(3, (int index) {
                    final String item = 'item $index';
                    return ListTile(
                      title: Text(item),
                    );
                  });
                }
            )
          ],
        ),
        actions: [
          IconButton(
              onPressed: () { },
              icon: Icon(Icons.add)
          ),

          IconButton(
              onPressed: () { },
              icon: Icon(Icons.settings)
          )
        ],
      ),

      body: Row(
        children: [
          Sidebar(iconSize: 25,),
          Expanded(child: child)
        ],
      ),
    );
  }

  Widget _buildSmallScreenLayout(BuildContext context, Widget child) {
    return Center(
      child: Surface(
        radius: 5,
        child: MediaThumbnail(path: 'C:/Users/Mauricio/Pictures/Gang/Random/UnaiUwU.jpeg'),
      ),
    );
  }
}