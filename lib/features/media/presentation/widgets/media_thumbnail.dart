import 'dart:io';
import 'package:flutter/material.dart';


class MediaThumbnail extends StatelessWidget {

  final String path;
  final Function() ? onTap;

  const MediaThumbnail({
    super.key,
    required this.path,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Image.file(
        width: 50,
        File(path)
      ),
    );
  }

}