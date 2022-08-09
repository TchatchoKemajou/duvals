
import 'dart:io';

import 'package:flutter/material.dart';

import '../Constants.dart';
import '../Models/Note.dart';
import '../Services/DuvalDatabase.dart';

class SelectNotes extends StatefulWidget {
  const SelectNotes({Key? key}) : super(key: key);

  @override
  State<SelectNotes> createState() => _SelectNotesState();
}

class _SelectNotesState extends State<SelectNotes> {
  List<Note> notes = [];
  bool isLoading = false;
  List<Note> searchNotes = [];
  final searchController = TextEditingController();
  bool isActiveSearch = false;
  bool isPlaying = false;
  bool isSearch = false;

  @override
  void initState() {
    super.initState();
    refreshNotes();
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
          title: const Text(
            "Selectionner un fichier",
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
                        searchNotes.clear();
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
          elevation: 10.0,
        ),
        body: Column(
          children: [
            if(isActiveSearch == true)
              searchWidget(),
            Expanded(
              child:
              notes.isEmpty
                  ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.folder_open,
                        size: 64,
                        color: kWarninngColor,
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
                  ))
                  :
              ListView.builder(
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                itemCount:  isSearch == false ? notes.length : searchNotes.length,
                itemBuilder: (context, index) {
                  final note = isSearch == false ? notes[index] : searchNotes[index];

                  return InkWell(
                    onTap: () {
                       Navigator.of(context).pop(note);
                    },
                    child: ListTile(
                      leading: const Icon(
                        Icons.sticky_note_2_outlined,
                        size: 36,
                        color: kWarninngColor,
                      ),
                      title: Text(
                          note.noteTitle,
                        style: const TextStyle(
                          fontFamily: 'PopBold',
                          color: Colors.white
                        ),
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${File(note.noteContent).lengthSync()} bytes",
                            style: const TextStyle(
                                fontFamily: 'PopRegular',
                                color: Colors.white
                            ),
                          ),
                          const Text(
                            "Json",
                            style: TextStyle(
                                fontFamily: 'PopRegular',
                                color: Colors.white
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
      searchNotes = notes.where((element) {
        return element.noteTitle.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  refreshNotes() async {
    setState(() => isLoading = true);

    final n = await DuvalDatabase.instance.readAllNotes(NoteType.text.toString());
    print(n);
    setState(() {
      notes.clear();
      notes = n;
    });

    setState(() => isLoading = false);
  }
}
