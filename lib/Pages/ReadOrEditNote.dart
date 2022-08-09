
import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:duvalsx/Constants.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:text_scroll/text_scroll.dart';
import 'dart:convert';

import '../Models/Note.dart';
import '../Services/DuvalDatabase.dart';

class ReadOrEditNote extends StatefulWidget {
  final Note? document;
  final int? id;
  final Future<dynamic>? refresh;
  const ReadOrEditNote({
    this.document,
    this.id,
    this.refresh,
    Key? key
  }) : super(key: key);

  @override
  State<ReadOrEditNote> createState() => _ReadOrEditNoteState();
}

class _ReadOrEditNoteState extends State<ReadOrEditNote> {
  String textVoice = '';
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  final _formKey = GlobalKey<FormState>();
  String? title;
  bool onSaved = false;
  quill.QuillController? quillController;


  @override
  void initState() {
    super.initState();
    loadData();
    _initSpeech();
  }

  loadData() async{
    setState(() {
      quillController = quill.QuillController.basic();
    });

    if(widget.document != null){
      File file = File(widget.document!.noteContent);
      String fileContent = await file.readAsString();
      var j = json.decode(fileContent);
      print(await file.length());
      //quillController = quill.QuillController(document: quill.Document.fromJson(j), selection: const TextSelection.collapsed(offset: 0));
      setState(() {
        quillController = quill.QuillController(document: quill.Document.fromJson(j), selection: const TextSelection.collapsed(offset: 0));
      });
    }else{
      //quillController = quill.QuillController.basic();
      setState(() {
        quillController = quill.QuillController.basic();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: fisrtcolor,
        title: TextScroll(
          widget.document?.noteTitle ?? "Nouvelle note",
          mode: TextScrollMode.bouncing,
          velocity: const Velocity(pixelsPerSecond: Offset(50, 0)),
          delayBefore: const Duration(seconds: 1),
          numberOfReps: 5,
          pauseBetween: const Duration(seconds: 30),
          style: const TextStyle(
              color: Colors.white,
              fontFamily: 'PopBold',
              fontSize: 18
          ),
        ),
        bottom: onSaved == true ? const PreferredSize(
          preferredSize: Size.fromHeight(5.0),
          child: LinearProgressIndicator(),
      ) : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Row(
              children: [
                IconButton(
                    onPressed: () async{
                      if(widget.document == null){
                        String? result = await showDialog<String>(
                            context: context,
                            builder: (context) => dialogTitle()
                        );
                        if(result != null){
                          setState(() {
                            onSaved = true;
                          });
                          String apercu = quillController!.document.toPlainText().length > 200 ? quillController!.document.toPlainText().substring(0, 200) : quillController!.document.toPlainText();
                          String path = await saveJsonDoc(result);
                          await addNote(apercu, result, path);
                          setState(() {
                            onSaved = false;
                          });
                        }
                      }else{
                        setState(() {
                          onSaved = true;
                        });
                        String apercu = quillController!.document.toPlainText().length > 200 ? quillController!.document.toPlainText().substring(0, 200) : quillController!.document.toPlainText();
                        await updateJsonDoc(widget.document!.noteContent);
                        await updateNote(apercu);

                        setState(() {
                          onSaved = false;
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.save_as,
                      color: secondcolor,
                    )),
                if(widget.document != null)
                IconButton(
                    onPressed: () async{
                      setState(() {
                        onSaved = true;
                      });
                      if(widget.document!.noteIsImportant == true){
                        await updateNoteImportant(widget.document!, false);
                      }else{
                        await updateNoteImportant(widget.document!, true);
                      }
                      setState(() {
                        onSaved = false;
                      });
                    },
                    icon: Icon(
                      widget.document!.noteIsImportant == false ? Icons.label_important_outline : Icons.label_important,
                      color: Colors.white,
                    )),
                if(widget.document != null)
                IconButton(
                    onPressed: (){
                      Share.shareFiles([widget.document!.noteContent], text: 'note');
                    },
                    icon: const Icon(
                      Icons.share,
                      color: Colors.white,
                    )),
                if(widget.document != null)
                IconButton(
                    onPressed: (){
                      deleteNote(widget.document!.noteContent, widget.document!.noteId!);
                      widget.refresh;
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ))
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          quill.QuillToolbar.basic(controller: quillController!),
          Expanded(
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.lightBlueAccent,
                      offset: Offset(5.0, 5.0),
                      blurRadius: 10.0,
                      spreadRadius: 2.0
                    ),
                    BoxShadow(
                        color: Colors.white,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0
                    )
                  ]
                ),
                child: quill.QuillEditor.basic(controller: quillController!, readOnly: false),
              )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
        child: Icon(_speechToText.isNotListening ? Icons.mic : Icons.mic_none, size: 36),
      ),
    );
  }

  dialogTitle() {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(6.0),
      backgroundColor: thirdcolor,
       title: const Text(
         "Nouveau",
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
            validator: (e) => e!.isEmpty || e.length < 5 ? "le nom doit être superieur à 5" : null,
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

  Future<String> saveJsonDoc(String name) async{
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String filePath = '${appDirectory.path}/$name.json';
    File file = File(filePath);
    await file.writeAsString(json.encode(quillController!.document.toDelta().toJson()));
    return filePath;
  }

  updateJsonDoc(String path) async{
    File file = File(path);
    await file.writeAsString(json.encode(quillController!.document.toDelta().toJson()));
  }

  Future addNote(String duration, String title, String content) async {
    final note = Note(
      noteTitle: title,
      noteIsRead: false,
      noteIsImportant: false,
      noteDuration: duration,
      noteContent: content,
      noteCreateAt: DateTime.now(),
      noteFolder: widget.id,
      noteType: NoteType.text.toString(),
    );

    await DuvalDatabase.instance.create(note);
  }

  deleteNote(String path, int id) async{
    File file = File(path);
    if(await file.exists()){
      await  DuvalDatabase.instance.delete(id);
      await file.delete();
      //refreshNotes();
    }
  }
  Future updateNote(String duration) async {
    final note = Note(
      noteId: widget.document!.noteId,
      noteTitle: widget.document!.noteTitle,
      noteIsRead: widget.document!.noteIsRead,
      noteIsImportant: widget.document!.noteIsImportant,
      noteDuration: duration,
      noteContent: widget.document!.noteContent,
      noteCreateAt: DateTime.now(),
      noteType: widget.document!.noteType,
    );

    await DuvalDatabase.instance.update(note);
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
    print(_speechEnabled);
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    print(textVoice);
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
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

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    await FlutterClipboard.copy(textVoice);
    setState(() {});
    print(textVoice);
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      textVoice = result.recognizedWords;
    });
  }
}
