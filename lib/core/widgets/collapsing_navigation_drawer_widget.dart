import 'package:Fern/core/constants/app_constants.dart';
import 'package:Fern/core/widgets/sidebar_item.dart';
import 'package:flutter/material.dart';
import 'collapsing_list_tile_widget.dart';


class CollapsingNavigationDrawer extends StatefulWidget {

  final List<SidebarItem> items;
  final double maxWidth;
  final double minWidth;
  final TextStyle textStyle;
  final double iconSize;

  final Color backgroundColor;
  final Color selectedColor;
  final Color textSelectedColor;
  final Color unselectedColor;
  final Color textUnselectedColor;

  bool isCollapsed = false;

  CollapsingNavigationDrawer({
    super.key,
    required this.items,
    this.maxWidth = 210,
    this.minWidth = 70,
    required this.textStyle,
    required this.iconSize,

    required this.backgroundColor,
    required this.selectedColor,
    required this.textSelectedColor,
    required this.unselectedColor,
    required this.textUnselectedColor,

    this.isCollapsed = false,
  });

  @override
  State<StatefulWidget> createState() => _CollapsingNavigationDrawerState();
}

class _CollapsingNavigationDrawerState extends State<CollapsingNavigationDrawer>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> widthAnimation;
  int currentSelectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: drawerAnimationDuration);
    widthAnimation = Tween<double>(begin: widget.maxWidth, end: widget.minWidth)
        .animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, w) => getWidget(context, w, widget),
    );
  }

  Widget getWidget(BuildContext context, w, drawer) {
    return Material(
      elevation: 0.0,
      child: Container(
        width: widthAnimation.value,
        color: widget.backgroundColor,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, counter) {
                  return CollapsingListTile(
                    onTap: () {
                        setState(() {
                          currentSelectedIndex = counter;
                        });
                        widget.items[counter].onTap.call();
                      },
                    isSelected: currentSelectedIndex == counter,
                    title: widget.items[counter].title,
                    icon: widget.items[counter].icon,
                    animationController: _animationController,
                    textStyle: widget.textStyle,
                    selectedColor: widget.selectedColor,
                    textSelectedColor: widget.textSelectedColor,
                    unselectedColor: widget.unselectedColor,
                    textUnselectedColor: widget.textUnselectedColor,
                    iconSize: widget.iconSize,
                  );
                },
                itemCount: widget.items.length,
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  widget.isCollapsed = !widget.isCollapsed;
                  widget.isCollapsed
                      ? _animationController.forward()
                      : _animationController.reverse();
                });
              },
              child: AnimatedIcon(
                icon: AnimatedIcons.close_menu,
                progress: _animationController,
                color: widget.selectedColor,
                size: widget.iconSize,
              ),
            ),
            SizedBox(
              height: 50.0,
            ),
          ],
        ),
      ),
    );
  }
}
