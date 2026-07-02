import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_masonry_view/flutter_masonry_view.dart';


class MediaGrid extends StatelessWidget {

  final List<File> mediaList;
  final int columns;

  const MediaGrid({
    super.key,
    required this.mediaList,
    required this.columns
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: 15, right: 15),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).secondaryHeaderColor,
            borderRadius: BorderRadius.circular(43)
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: MasonryView(
              listOfItem: mediaList,
              numberOfColumn: columns,
              itemPadding: 10,
              itemRadius: 30,
              itemBuilder: (item) {
                return Image.file(item);
              }
          ),
        ),
      ),
    );
  }

}