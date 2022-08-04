import 'package:flutter/material.dart';

import '../Constants.dart';

class FolderPage extends StatefulWidget {
  const FolderPage({Key? key}) : super(key: key);

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: fisrtcolor,
      body: Center(child: Text("Folder", style: TextStyle(color: Colors.white),),),
    );
  }
}
