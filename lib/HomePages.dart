import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:duvalsx/Pages/FolderPage.dart';
import 'package:duvalsx/Pages/NotePage.dart';
import 'package:duvalsx/Pages/PicturePage.dart';
import 'package:duvalsx/Pages/ReadOrEditNote.dart';
import 'package:duvalsx/Pages/TranslatePage.dart';
import 'package:duvalsx/Pages/VoicePage.dart';
import 'package:flutter/material.dart';

import 'Constants.dart';

class HomePages extends StatefulWidget {
  const HomePages({Key? key}) : super(key: key);

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  late List<Widget> page;
  int current = 4;

  @override
  void initState() {
    page = const[
      FolderPage(),
      VoicePage(),
      PicturePage(),
      TranslatePage(),
      NotePage()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: current,
        children: page,
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: const [
          Icons.folder,
          Icons.record_voice_over,
          Icons.cameraswitch,
          Icons.translate,
        ],
        //leftCornerRadius: 20,
        //elevation: 10.0,
        backgroundColor: fisrtcolor,
        activeColor: secondcolor,
        inactiveColor: Colors.white,
        splashColor: Colors.blueGrey,
        activeIndex: current,
        gapLocation: GapLocation.end,
        notchSmoothness: NotchSmoothness.sharpEdge,
        onTap: (index) => setState(() => current = index),
        //other params
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(current == 4){
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ReadOrEditNote()));
          }else{
            setState(() {
              current = 4;
            });
          }
        },
        backgroundColor: secondcolor,
        child: Icon(current == 4 ?Icons.note_add: Icons.sticky_note_2),
      ),
    );
  }
}
