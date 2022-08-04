import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../Components/NoteListView.dart';
import '../Constants.dart';
import '../Models/Note.dart';
import '../Providers/LanguageChangeProvider.dart';
import '../Services/DuvalDatabase.dart';

class NotePage extends StatefulWidget {
  const NotePage({Key? key}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final RefreshController refreshController = RefreshController(initialRefresh: true);
  List<Note> notes = [];
  final searchController = TextEditingController();
  String currentLanguage = "Français";
  String language = "Français";
  String lang = "fr";
  List<String> languages = ["Français", "Anglais", "Allemand", "Espagnol", "Swahili", "Chinois", "Russe", "Italien", "Afrikaans", "Japonais"];




  @override
  void initState() {
    super.initState();
   // refreshNotes();
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
        elevation: 0.0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Consumer<LanguageChangeProvider>(
                builder: (context, value, child){
                  return DropdownButton<String>(
                    value: value.currentLocaleName,
                    dropdownColor: thirdcolor,
                    icon: const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    iconSize: 24,
                    //elevation: 16,
                    underline: Container(
                      height: 1,
                      color: fisrtcolor,
                    ),
                    alignment: Alignment.centerRight,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'PopRegular',
                    ),
                    onChanged: (e)  {
                      setState(() {
                        currentLanguage = e!;
                      });
                      switch (e!) {
                        case "Allemand":
                          value.changeLocale("fr", "Allemand");
                          //await videosProviders.allMovies(1);
                          break;

                        case "Français":
                          value.changeLocale("fr", "Français");
                          //await videosProviders.allMovies(1);
                          break;

                        case "Anglais":
                          value.changeLocale("en", "Anglais");
                          break;
                      }
                      //loadLanguage();
                      //findAllVideos(lang);
                    },
                    items: languages
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  );
                }
            ),
          )
        ],
      ),
      body: Column(
        children: [
          searchWidget(),
          Expanded(
              child: SmartRefresher(
                controller: refreshController,
                enablePullUp: true,
                enablePullDown: false,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: NoteListView(notes: notes,),
                ),
              )
          ),
        ],
      ),
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
        controller: searchController,
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


  refreshNotes() async {
    //setState(() => isLoading = true);

    final n = await DuvalDatabase.instance.readAllNotes(NoteType.audio.toString());
    //print(n);
    setState(() {
      notes.clear();
      notes = n;
    });

    //setState(() => isLoading = false);
  }
}
