
import 'dart:io';


import 'package:flutter/material.dart';

enum ImageLabelType {
  Vertical,
  Horizontal
}

class ImageLabel extends StatelessWidget{

  late final String? label;
  late final String title;
  late final String picturePath;
  late final ImageLabelType type;

  ImageLabel({
    super.key,
    this.label,
    required this.title,
    required this.picturePath,
    this.type = ImageLabelType.Horizontal
  });


  @override
  Widget build(BuildContext context) {
    if (type == ImageLabelType.Vertical) {
      return _buildVertical(label: label, title: title, picturePath: picturePath);
    } else {
      return _buildHorizontal(title: title, picturePath: picturePath);
    }
  }


  Widget _buildVertical({
    String? label,
    required String title,
    required String picturePath
}) {
    return Column(
      children: [
        Image.file(File(picturePath)),

        if(label != null)
          Text(label),

        Text(title),
      ],
    );
  }


  Widget _buildHorizontal({
    String? label,
    required String title,
    required String picturePath
  }) {
    return Row(
      children: [
        Image.file(File(picturePath)),

        if(label != null)
          Text(label),

        Text(title),
      ],
    );
  }
}