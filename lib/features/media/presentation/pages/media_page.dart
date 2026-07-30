import 'dart:io';

import 'package:Fern/features/media/presentation/widgets/media_grid.dart';
import 'package:flutter/material.dart';


class MediaPage extends StatelessWidget {
  const MediaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Texto"),
        Expanded(
          child: MediaGrid(
            mediaList: [
              /*File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/CattyRuby.jpg'),
              File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/Fotor_AI.png'),
              File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/MayaaaPompee.png'),
              File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/kpopdemonhunters.png'),
              File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/rubymolesta.png'),
              File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/rubymegacute.png'),
              File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/RubyChikitaRubyChikita.png'),
              File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/Talonius.png'),
              File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/Cesarius.png'),
              File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/halloween.png'),
              File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/delphineunai.jpg'),
              File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/1cattyfeet.png'),
              File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/2delphinefeet.png'),
              File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/3rubyfeet.png'),
              File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/Marigold.png'),
              File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/memerubyy.jpg'),
              File('C:/Users/Mauricio/Pictures/Gang/PompeuAndFanarts/memeruby.png'),*/
            ],
            columns: 4
        ),)
      ],
    );
  }

}