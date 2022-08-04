import 'dart:io';

import 'package:duvalsx/Components/RecorderView.dart';
import 'package:duvalsx/Constants.dart';
import 'package:duvalsx/Services/DuvalDatabase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../Components/RecordListView.dart';
import '../Models/Note.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({Key? key}) : super(key: key);

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  late Directory appDirectory;
  List<Note> records = [];
  //late List<Note> records;
  bool isLoading = false;
  bool isPlaying = false;
  //List<String> records = [];

  refreshNotes() async {
    //setState(() => isLoading = true);

    final n = await DuvalDatabase.instance.readAllNotes(NoteType.audio.toString());
    //print(n);
    setState(() {
      records.clear();
      records = n.reversed.toList();
    });

    //setState(() => isLoading = false);
  }


  @override
  void initState() {
    super.initState();
    refreshNotes();
  }


  @override
  void dispose() {
    DuvalDatabase.instance.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: thirdcolor,
      appBar: AppBar(
        backgroundColor: thirdcolor,
        title: const Text(
          "Duvals",
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'PopBold',
              fontSize: 18
          ),
        ),
        flexibleSpace: playerView(),
        elevation: 0.0,
      ),
      body: Column(
        children: [
          searchWidget(),
          Expanded(
            child: records.isEmpty
                ? const Center(child: Text(
              'Aucun enregistrement',
              style: TextStyle(
                color: Colors.white,
              ),
            ))
                : ListView.builder(
              itemCount: records.length,
              shrinkWrap: true,
              //reverse: true,
              itemBuilder: (BuildContext context, int i) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      isPlaying = true;
                    });
                  },
                    child: RecordListView(records: records[i])
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: RecorderView(onSaved: refreshNotes()),
    );
  }

  searchWidget(){
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 5),
      child: TextFormField(
        keyboardType: TextInputType.text,
        onChanged: (e) {
          // setState(() {
          //   isSearch = true;
          //   querySearch = e;
          // });
        },
        onFieldSubmitted: (e) async{
          // await getAllResult();
          // isValidSearch = true;
          // if(videosSearch.length  <= 0){
          //   await videoprovider.postSearchRequest(querySearch);
          // }
          // FocusScope.of(context).requestFocus(FocusNode());
        },
        //controller: searchController,
        maxLines: 1,
        style: const TextStyle(
            color: Colors.white
        ),
        decoration: const InputDecoration(
          hoverColor: Colors.white,
          // suffixIcon: isSearch == true
          //     ? InkWell(
          //   child: Icon(Icons.close, color: secondcolor,),
          //   onTap: (){
          //     setState(() {
          //       isValidSearch = false;
          //       isSearch = false;
          //       videosSearch.clear();
          //       searchController.clear();
          //     });
          //     FocusScope.of(context).requestFocus(FocusNode());
          //   },
          // )
          //     : SizedBox(),
          hintText: 'recherche',
          hintStyle: TextStyle(
            color: Colors.white,
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              borderSide: BorderSide(
                  color: Colors.white
              )
          ),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              borderSide: BorderSide(
                  color: Colors.white
              )
          ),
          isDense: true,                      // Added this
          contentPadding: EdgeInsets.all(10),
          //hintText: "login",
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
        ),
      ),
    );
  }

  playerView(){
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Row(
            children: [
              IconButton(
                  onPressed: (){

                  },
                  icon: const Icon(
                    Icons.play_arrow,
                  )),
              Text("name")
            ],
          )
        ],
      ),
    );
  }


  // _onRecordComplete() {
  //   records.clear();
  //   appDirectory.list().listen((onData) {
  //     if (onData.path.contains('.aac')){
  //       records.add(onData.path);
  //       if (kDebugMode) {
  //         print(onData.path);
  //       }
  //     }
  //   }).onDone(() {
  //     records.sort();
  //     records = records.reversed.toList();
  //     setState(() {});
  //   });
  // }
}
