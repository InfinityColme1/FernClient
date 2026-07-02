import 'package:flutter/material.dart';


class Surface extends StatelessWidget {

  final double radius;
  final Widget ? child;

  const Surface({
    super.key,
    required this.radius,
    this.child
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).secondaryHeaderColor,
        borderRadius: BorderRadius.circular(radius)
      ),
      child: child,
    );
  }

}