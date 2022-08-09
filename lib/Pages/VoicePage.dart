import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:duvalsx/Components/RecorderView.dart';
import 'package:duvalsx/Constants.dart';
import 'package:duvalsx/Services/DuvalDatabase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';

import '../Components/RecordListView.dart';
import '../Models/Note.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({Key? key}) : super(key: key);

  @override
  State<VoicePage> createState() => _VoicePageState();
}

enum PlayingState {
  unSet,
  play,
  stopped,
  pause,
  completed
}

class _VoicePageState extends State<VoicePage> {
  final _formKey = GlobalKey<FormState>();
  String? title;
  ItemScrollController itemScrollController = ItemScrollController();
  AudioPlayer audioPlayer = AudioPlayer();
  Duration fullDuration = Duration.zero;
  Duration position = Duration.zero;
  int selectedIndex = -1;
  PlayingState playingState = PlayingState.unSet;
  late Directory appDirectory;
  List<Note> records = [];
  List<Note> searchRecords = [];
  final searchController = TextEditingController();
  bool isActiveSearch = false;
  bool isPlaying = false;
  bool isSearch = false;
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
    audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        position = Duration.zero;
        playingState = PlayingState.unSet;
        isPlaying = false;
      });
    });
    audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        fullDuration = duration;
      });
    });

    audioPlayer.onPositionChanged.listen((duration) {
      setState(() {
        position = duration;
        //   _completedPercentage =
        //       _currentDuration.toDouble() / _totalDuration.toDouble();
      });
    });

    audioPlayer.onPlayerStateChanged.listen((event) {
    });
  }


  @override
  void dispose() {
    //DuvalDatabase.instance.close();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: thirdcolor,
      appBar: AppBar(
        backgroundColor: thirdcolor,
        title: const Text(
          "Notes vocales",
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'PopBold',
              fontSize: 18
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
                onPressed: (){
                  if(isActiveSearch == false){
                    setState(() {
                      isActiveSearch = true;
                    });
                  }else{
                    setState(() {
                      isSearch = false;
                      isActiveSearch = false;
                      searchRecords.clear();
                      searchController.clear();
                    });
                  }
                },
                icon: Icon(
                  isActiveSearch == false ? Icons.search : Icons.close,
                  color: isActiveSearch == false ?  Colors.white : Colors.red,
                )),
          )
        ],
        bottom: isPlaying == true ? PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: playerView(),
        ) : null,
        elevation: 10.0,
      ),
      body: Column(
        children: [
          if(isActiveSearch == true)
          searchWidget(),
          Expanded(
            child: records.isEmpty
                ?  Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.mic,
                      size: 64,
                      color: Colors.white,
                    ),
                    Text(
                       'Aucun enregistrement',
                       style: TextStyle(
                       color: Colors.white,
                       fontFamily: 'PopRegular',
                       fontSize: 13
                    ),
            ),
                  ],
                ))
                : ScrollablePositionedList.builder(
              itemCount: isSearch == false ? records.length : searchRecords.length,
              shrinkWrap: true,
              itemScrollController: itemScrollController,
              //reverse: true,
              itemBuilder: (BuildContext context, int i) {
                final record = isSearch == false ? records[i] : searchRecords[i];
                return Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: selectedIndex == i ?  playingState == PlayingState.pause || playingState == PlayingState.unSet ? secondcolor : Colors.green : secondcolor,
                        child: IconButton(
                          icon: Icon(
                              selectedIndex == i ? playingState == PlayingState.pause || playingState == PlayingState.unSet ? Icons.play_circle_outline : Icons.pause_circle_outline : Icons.play_circle_outline
                          ),
                          onPressed: (){
                            _onPlay(filePath: record.noteContent, index: i);
                          },
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            record.noteTitle,
                            softWrap: true,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'PopBold',
                                fontSize: 15
                            ),
                          ),
                          FocusedMenuHolder(
                            menuWidth: MediaQuery.of(context).size.width* 0.4,
                            blurSize: .0,
                            menuItemExtent: 45,
                            menuBoxDecoration: const BoxDecoration(
                                color: thirdcolor,
                                borderRadius: BorderRadius.all(Radius.circular(15.0))),
                            duration: const Duration(milliseconds: 100),
                            animateMenuItems: true,
                            blurBackgroundColor: Colors.transparent,
                            openWithTap: true, // Open Focused-Menu on Tap rather than Long Press
                            menuOffset: 10.0, // Offset value to show menuItem from the selected item
                            bottomOffsetHeight: 80.0,
                            menuItems: <FocusedMenuItem>[
                              FocusedMenuItem(
                                  title: const Text(
                                      "Renommer",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "PopRegular"
                                    ),
                                  ),
                                  trailingIcon: const Icon(Icons.update, color: Colors.white,) ,
                                  backgroundColor: thirdcolor,
                                  onPressed: () async{
                                    String oldTitle = record.noteTitle;
                                    String? result = await showDialog<String>(
                                        context: context,
                                        builder: (context) => dialogTitle()
                                    );

                                    if(result != null && result != oldTitle){
                                      await updateNote(record, result);
                                      refreshNotes();
                                    }else{

                                    }
                              }),
                              FocusedMenuItem(
                                  title: const Text(
                                    "Partager",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "PopRegular"
                                    ),
                                  ),
                                  trailingIcon: const Icon(Icons.share, color: Colors.white,) ,
                                  backgroundColor: thirdcolor,
                                  onPressed: (){
                                Share.shareFiles([record.noteContent], text: 'Fichier audio');
                              }),
                              FocusedMenuItem(
                                  title: const Text(
                                      "Important",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "PopRegular"
                                    ),
                                  ),
                                  trailingIcon: const Icon(Icons.label_important_outline, color: Colors.white,) ,
                                  backgroundColor: thirdcolor,
                                  onPressed: () async{
                                    if(record.noteIsImportant == true){
                                      await updateNoteImportant(record, false);
                                      refreshNotes();
                                    }else{
                                      await updateNoteImportant(record, true);
                                      refreshNotes();
                                    }
                                  }),
                              FocusedMenuItem(
                                  title: const Text(
                                    "Supprimer",
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                      fontFamily: "PopRegular"
                                    ),
                                  ),
                                  trailingIcon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,) ,
                                  backgroundColor: thirdcolor,
                                  onPressed: (){
                                deleteRecorder(record.noteContent, record.noteId!);
                              }),
                            ],
                            onPressed: (){

                            },
                            child: const SizedBox(
                              width: 30,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: FaIcon(
                                  FontAwesomeIcons.ellipsisVertical,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            record.noteDuration,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontFamily: 'PopBold',
                                fontSize: 15
                            ),
                          ),
                          Text(
                            DateFormat.yMMMd().format(record.noteCreateAt),
                            style: const TextStyle(
                                color: Colors.grey,
                                fontFamily: 'PopRegular',
                                fontSize: 15
                            ),
                          )
                        ],
                      ),
                    ),
                    const Divider(
                      height: 2,
                      color: Colors.grey,
                    ),
                  ],
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
        onChanged: searchFunction,
        controller: searchController,
        maxLines: 1,
        style: const TextStyle(
            color: Colors.white
        ),
        decoration: const InputDecoration(
          hoverColor: Colors.white,
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

  searchFunction(String query) {
    setState(() {
      if(query == ""){
        isSearch = false;
      }else{
        isSearch = true;
      }
    });

    setState(() {
      searchRecords = records.where((element) {
        return element.noteTitle.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  playerView(){
    return InkWell(
      onTap: () {
        itemScrollController.scrollTo(
            index: 150,
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOutCubic);
      },
      child: Container(
        height: 40,
        color: foothcolor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: (){
                      if(playingState == PlayingState.play){
                        audioPlayer.pause();
                        setState(() {
                          playingState = PlayingState.pause;
                        });
                      }else{
                        audioPlayer.resume();
                        setState(() {
                          playingState = PlayingState.play;
                        });
                      }
                    },
                    icon: Icon(
                      playingState == PlayingState.pause || playingState == PlayingState.unSet ? Icons.play_arrow : Icons.pause,
                      color: color1,
                    )),
                Slider(
                  min: 0,
                    max: fullDuration.inSeconds.toDouble(),
                    value: position.inSeconds.toDouble(),
                    onChanged: (d) async{
                    final position = Duration(seconds: d.toInt());
                    await audioPlayer.seek(position);

                    /// optional
                    //await audioPlayer.resume();
                    }
                ),
                Text(
                  position.toString().split(".").first,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'PopRegular',
                    fontSize: 12
                  ),
                ),
                // IconButton(
                //     onPressed: (){
                //
                //     },
                //     icon: const Icon(
                //       Icons.arrow_downward,
                //       color: color1,
                //     )),
              ],
            ),
            IconButton(
                onPressed: (){
                  setState(() {
                    audioPlayer.stop();
                    isPlaying = false;
                    playingState = PlayingState.unSet;
                  });
                },
                icon: const Icon(
                  Icons.close,
                  color: kErrorColor,
                ))
          ],
        ),
      ),
    );
  }

  Future<void> _onPlay({required String filePath, required int index}) async {
    print("index $index");
    switch(playingState){
      case PlayingState.unSet:
        audioPlayer.play(DeviceFileSource(filePath));
        setState(() {
          selectedIndex = index;
          isPlaying = true;
          playingState = PlayingState.play;
        });
        // TODO: Handle this case.
        break;
      case PlayingState.play:
        if(selectedIndex == index){
          audioPlayer.pause();
          setState(() {
            playingState = PlayingState.pause;
          });
        }else{
          audioPlayer.play(DeviceFileSource(filePath));
          setState(() {
            selectedIndex = index;
          });
        }
        // TODO: Handle this case.
        break;
      case PlayingState.stopped:
        // TODO: Handle this case.
        break;
      case PlayingState.pause:
        if(selectedIndex == index){
          audioPlayer.resume();
          setState(() {
            playingState = PlayingState.play;
          });
        }else{
          audioPlayer.play(DeviceFileSource(filePath));
          setState(() {
            selectedIndex = index;
          });
        }
        // TODO: Handle this case.
        break;
      case PlayingState.completed:
        // TODO: Handle this case.
        break;
    }

  }


  dialogTitle() {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(6.0),
      backgroundColor: thirdcolor,
      title: const Text(
        "Renommer",
        style: TextStyle(
            color: Colors.white,
            fontFamily: 'PopRegular',
            fontSize: 14
        ),
      ),
      content: Container(
        color: thirdcolor,
        padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: TextFormField(
            keyboardType: TextInputType.text,
            validator: (e) => e!.isEmpty || e.length < 5 ? "5 caractères maximum" : null,
            onChanged: (e) {
              setState(() {
                title = e;
              });
            },
            maxLines: 1,
            style: const TextStyle(
                color: Colors.white
            ),
            decoration: const InputDecoration(
              hoverColor: Colors.white,
              hintText: 'titre',
              hintStyle: TextStyle(
                color: Colors.white,
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(
                      color: Colors.white
                  )
              ),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(
                      color: Colors.white
                  )
              ),
              isDense: true,                      // Added this
              contentPadding: EdgeInsets.all(10),
              //hintText: "login",
              prefixIcon: Icon(
                Icons.title,
                color: Colors.white,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
            ),
          ),
        ),
      ),
      actions: [
        FlatButton(
          onPressed: (){
            Navigator.of(context).pop(null);
          },
          child: const Text(
            'Annuler',
            style: TextStyle(
                color: kErrorColor,
                fontFamily: 'PopRegular'
            ),
          ),
        ),
        FlatButton(
          child: const Text(
            'Enregistrer',
            style: TextStyle(
                color: secondcolor,
                fontFamily: 'PopRegular'
            ),
          ),
          onPressed: () {
            if(_formKey.currentState!.validate()) {
              Navigator.of(context).pop(title!);
            }
          },
        ),
      ],
    );
  }

Future updateNote(Note newNote, String newTitle) async {
  final note = Note(
    noteId: newNote.noteId,
    noteTitle: newTitle,
    noteIsRead: newNote.noteIsRead,
    noteIsImportant: newNote.noteIsImportant,
    noteDuration: newNote.noteDuration,
    noteContent: newNote.noteContent,
    noteCreateAt: newNote.noteCreateAt,
    noteType: newNote.noteType,
  );

  await DuvalDatabase.instance.update(note);
}


  Future updateNoteImportant(Note newNote, bool isImportant) async {
    final note = Note(
      noteId: newNote.noteId,
      noteTitle: newNote.noteTitle,
      noteIsRead: newNote.noteIsRead,
      noteIsImportant: isImportant,
      noteDuration: newNote.noteDuration,
      noteContent: newNote.noteContent,
      noteCreateAt: newNote.noteCreateAt,
      noteType: newNote.noteType,
    );

    await DuvalDatabase.instance.update(note);
  }

  deleteRecorder(String path, int id) async{
    File file = File(path);
    if(await file.exists()){
      await  DuvalDatabase.instance.delete(id);
      await file.delete();
      refreshNotes();
    }
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
