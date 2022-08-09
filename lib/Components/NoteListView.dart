
import 'package:duvalsx/Constants.dart';
import 'package:duvalsx/Pages/ReadOrEditNote.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../Models/Note.dart';
import '../Pages/FolderNoteList.dart';
import '../Services/DuvalDatabase.dart';


class NoteListView extends StatefulWidget {
  final List<Note> notes;
  final Future<dynamic>? refresh;
  const NoteListView({
    Key? key,
    this.refresh,
    required this.notes
  }) : super(key: key);

  @override
  State<NoteListView> createState() => _NoteListViewState();
}

class _NoteListViewState extends State<NoteListView> {
  final _formKey = GlobalKey<FormState>();
  String? title;


  @override
  Widget build(BuildContext context) {
    return 
      widget.notes.isEmpty
      ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.sticky_note_2,
            size: 64,
            color: Colors.white,
          ),
          Text(
            'Aucune note',
            style: TextStyle(
              color: Colors.white,
                fontFamily: 'PopRegular',
                fontSize: 13
            ),
          ),
        ],
      )
      : StaggeredGridView.countBuilder(
          padding: const EdgeInsets.all(8),
          shrinkWrap: true,
          itemCount:  widget.notes.length,
          staggeredTileBuilder: (index) => StaggeredTile.count(1, index.isEven ? 1.5 : 1.5),
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          itemBuilder: (context, index) {
            final note = widget.notes[index];

            return InkWell(
              onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => ReadOrEditNote(document: note, refresh: widget.refresh,)));
                //widget.refresh;
              },
              child: Card(
                color: note.noteIsImportant == false ? thirdcolor.withOpacity(0.7) : fisrtcolor,
                elevation: 8.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5,),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:  [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  note.noteTitle,
                                  softWrap: true,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'PopBold',
                                    fontSize: 16
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () async{
                                    String oldTitle = note.noteTitle;
                                    String? result = await showDialog<String>(
                                        context: context,
                                        builder: (context) => dialogTitle()
                                    );

                                    if(result != null && result != oldTitle){
                                      await updateNote(note, result);
                                      widget.refresh;
                                    }else{

                                    }
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blueGrey,
                                  )),
                              // FocusedMenuHolder(
                              //   menuWidth: MediaQuery.of(context).size.width* 0.4,
                              //   blurSize: .0,
                              //   menuItemExtent: 45,
                              //   menuBoxDecoration: const BoxDecoration(
                              //       color: thirdcolor,
                              //       borderRadius: BorderRadius.all(Radius.circular(15.0))),
                              //   duration: const Duration(milliseconds: 100),
                              //   animateMenuItems: true,
                              //   blurBackgroundColor: Colors.transparent,
                              //   openWithTap: true, // Open Focused-Menu on Tap rather than Long Press
                              //   menuOffset: 10.0, // Offset value to show menuItem from the selected item
                              //   bottomOffsetHeight: 80.0,
                              //   menuItems: <FocusedMenuItem>[
                              //     FocusedMenuItem(
                              //         title: const Text(
                              //           "Renommer",
                              //           style: TextStyle(
                              //               color: Colors.white,
                              //               fontFamily: "PopRegular"
                              //           ),
                              //         ),
                              //         trailingIcon: const Icon(Icons.update, color: Colors.white,) ,
                              //         backgroundColor: thirdcolor,
                              //         onPressed: () async{
                              //           String oldTitle = note.noteTitle;
                              //           String? result = await showDialog<String>(
                              //               context: context,
                              //               builder: (context) => dialogTitle()
                              //           );
                              //
                              //           if(result != null && result != oldTitle){
                              //             await updateNote(note, result);
                              //             widget.refresh;
                              //           }else{
                              //
                              //           }
                              //         }),
                              //     FocusedMenuItem(
                              //         title: const Text(
                              //           "Ajouter aux dossier",
                              //           style: TextStyle(
                              //               color: Colors.white,
                              //               fontFamily: "PopRegular"
                              //           ),
                              //         ),
                              //         trailingIcon: const Icon(Icons.share, color: Colors.white,) ,
                              //         backgroundColor: thirdcolor,
                              //         onPressed: (){
                              //
                              //         }),
                              //     FocusedMenuItem(
                              //         title: const Text(
                              //           "Important",
                              //           style: TextStyle(
                              //               color: Colors.white,
                              //               fontFamily: "PopRegular"
                              //           ),
                              //         ),
                              //         trailingIcon: const Icon(Icons.label_important_outline, color: Colors.white,) ,
                              //         backgroundColor: thirdcolor,
                              //         onPressed: (){}),
                              //   ],
                              //   onPressed: (){
                              //
                              //   },
                              //   child: const SizedBox(
                              //     width: 30,
                              //     child: Align(
                              //       alignment: Alignment.centerRight,
                              //       child: FaIcon(
                              //         FontAwesomeIcons.ellipsisVertical,
                              //         color: Colors.white,
                              //       ),
                              //     ),
                              //   ),
                              // )
                            ],
                          ),
                          Text(
                            DateFormat.yMMMd().format(note.noteCreateAt),
                            style: const TextStyle(
                                color: Colors.grey,
                                fontFamily: 'PopLight',
                                fontSize: 13
                            ),
                          ),
                          Text(
                            note.noteDuration,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 6,
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'PopRegular',
                                fontSize: 14
                            ),
                          ),

                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if(note.noteFolder != null){
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => FolderNoteList(folder: note.noteFolder,)));
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
                        //height: 5,
                        decoration: BoxDecoration(
                          color: fisrtcolor,
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                                color: Colors.grey,
                                width: 1
                            )
                        ),
                        child: Center(
                          child: note.noteFolder == null
                          ? const Text(
                              "Aucun dossier",
                            style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'PopRegular',
                                fontSize: 12
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.folder,
                                color: kWarninngColor,
                                size: 16,
                              ),
                              SizedBox(width: 2,),
                              Text(
                                "Afficher le dossier",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'PopRegular',
                                    fontSize: 12
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
    );
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
}
