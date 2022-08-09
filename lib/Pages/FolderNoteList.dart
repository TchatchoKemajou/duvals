
import 'package:duvalsx/Models/Note.dart';
import 'package:duvalsx/Pages/SelectNotes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:text_scroll/text_scroll.dart';
import '../Constants.dart';
import '../Models/Folder.dart';
import '../Services/DuvalDatabase.dart';
import 'ReadOrEditNote.dart';

class FolderNoteList extends StatefulWidget {
  final Folder folder;
  const FolderNoteList({
    Key? key,
    required this.folder
  }) : super(key: key);

  @override
  State<FolderNoteList> createState() => _FolderNoteListState();
}

class _FolderNoteListState extends State<FolderNoteList> {
  final _formKey = GlobalKey<FormState>();
  String? title;
  List<Note> noteFolders = [];
  List<Note> searchNoteFolders = [];
  bool isSearch = false;
  bool isLoading = false;
  bool isActiveSearch = false;
  final searchController = TextEditingController();

  refreshFolderNote() async {
    setState(() => isLoading = true);

    final f = await DuvalDatabase.instance.readFolder(widget.folder.folderId!);
    setState(() {
      noteFolders.clear();
      noteFolders = f;
    });

    setState(() => isLoading = false);
  }


  @override
  void initState() {
    super.initState();
    refreshFolderNote();
  }


  @override
  void dispose() {
    //DuvalDatabase.instance.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: thirdcolor,
        appBar: AppBar(
          backgroundColor: thirdcolor,
          title: TextScroll(
            widget.folder.folderName,
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  IconButton(
                      onPressed: (){
                        if(isActiveSearch == false){
                          setState(() {
                            isActiveSearch = true;
                          });
                        }else{
                          setState(() {
                            isSearch = false;
                            isActiveSearch = false;
                            searchNoteFolders.clear();
                            searchController.clear();
                          });
                        }
                      },
                      icon: Icon(
                        isActiveSearch == false ? Icons.search : Icons.close,
                        color: isActiveSearch == false ?  Colors.white : Colors.red,
                      )),
                  IconButton(
                    onPressed: () async{
                      int? i = await showDialog<int>(
                          context: context,
                          builder: (context) => dialogMenu()
                      );

                      if(i != null){
                        if(i == 1){
                          if(!mounted) return;
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ReadOrEditNote(id: widget.folder.folderId,)));
                          refreshFolderNote();
                        }else{
                          if(!mounted) return;
                          final note = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SelectNotes()));
                          if(note !=  null){
                            updateNote(note);
                            refreshFolderNote();
                          }else{

                          }
                        }
                      }

                      //final note = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SelectNotes()));
                      // if(note !=  null){
                      //   updateNote(note);
                      //   refreshFolderNote();
                      // }else{
                      //
                      // }
                    },
                    icon: const Icon(
                        Icons.note_add,
                        color: Colors.white
                    ),
                  ),
                  IconButton(
                    onPressed: () {  },
                    icon: const Icon(
                        Icons.edit,
                        color: Colors.white
                    ),
                  ),
                ],
              ),
            ),
          ],
          elevation: 10.0,
        ),
        body: Column(
          children: [
            if(isActiveSearch == true)
              searchWidget(),
            Expanded(
              child:       noteFolders.isEmpty
                  ? Center(
                    child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                    Icon(
                      Icons.folder_open,
                      size: 64,
                      color: Colors.white,
                    ),
                    Text(
                      'Dossier vide',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'PopRegular',
                          fontSize: 13
                      ),
                    ),
                ],
              ),
                  )
                  : StaggeredGridView.countBuilder(
                padding: const EdgeInsets.all(8),
                itemCount:  isSearch == false ? noteFolders.length : searchNoteFolders.length,
                staggeredTileBuilder: (index) => StaggeredTile.count(1, index.isEven ? 1.5 : 1.5),
                crossAxisCount: 2,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                itemBuilder: (context, index) {
                  final note = isSearch == false ? noteFolders[index] : searchNoteFolders[index];

                  return InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ReadOrEditNote(document: note,)));
                      //widget.refresh;
                    },
                    child: Card(
                      color: thirdcolor.withOpacity(0.5),
                      elevation: 8.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
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
                                            await updateNote(note);
                                            refreshFolderNote();
                                          }else{

                                          }
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blueGrey,
                                        )),
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
                          Container(
                            margin: const EdgeInsets.only(bottom: 5, left: 15, right: 15),
                            //height: 5,
                            decoration: BoxDecoration(
                                color: fisrtcolor,
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                    color: Colors.grey,
                                    width: 1
                                )
                            ),
                            child: const Center(
                              child: Text(
                                "Aucun dossier",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'PopRegular',
                                    fontSize: 12
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        )
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

  dialogMenu() {
    return AlertDialog(
      //contentPadding: const EdgeInsets.only(left: 20, right: 20),
      backgroundColor: thirdcolor,
      content: Container(
        color: thirdcolor,
        //padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
        width: MediaQuery.of(context).size.width * 0.8,
        child: SizedBox(
          height: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              InkWell(
                onTap: (){
                  Navigator.of(context).pop(1);
                },
                child: const Text(
                  "Nouvelle note",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PopRegular',
                      fontSize: 16
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop(2);
                },
                child: const Text(
                  "Note existante",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'PopRegular',
                    fontSize: 16
                  ),
                ),
              )
            ],
          ),
        ),
      ),
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
        decoration: InputDecoration(
          hoverColor: Colors.white,
          suffixIcon: isSearch == true
              ? InkWell(
            child: const Icon(Icons.close, color: Colors.red,),
            onTap: (){
              setState(() {
                isSearch = false;
                isActiveSearch = false;
                searchNoteFolders.clear();
                searchController.clear();
              });
              FocusScope.of(context).requestFocus(FocusNode());
            },
          )
              : const SizedBox(),
          hintText: 'recherche',
          hintStyle: const TextStyle(
            color: Colors.white,
          ),
          focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              borderSide: BorderSide(
                  color: Colors.white
              )
          ),
          enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
              borderSide: BorderSide(
                  color: Colors.white
              )
          ),
          isDense: true,                      // Added this
          contentPadding: const EdgeInsets.all(10),
          //hintText: "login",
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.white,
          ),
          border: const OutlineInputBorder(
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
      searchNoteFolders = noteFolders.where((element) {
        return element.noteTitle.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Future updateNote(Note oldNote) async {
    final newNote = Note(
      noteId: oldNote.noteId,
      noteTitle: oldNote.noteTitle,
      noteIsRead: oldNote.noteIsRead,
      noteIsImportant: oldNote.noteIsImportant,
      noteDuration: oldNote.noteDuration,
      noteContent: oldNote.noteContent,
      noteCreateAt: oldNote.noteCreateAt,
      noteFolder: widget.folder.folderId,
      noteType: oldNote.noteType,
    );

    await DuvalDatabase.instance.update(newNote);
  }
}
