import 'package:flutter/material.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
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
  List<Note> searchNotes = [];
  bool isSearch = false;
  bool isLoading = false;
  final searchController = TextEditingController();
  String currentLanguage = "Français";
  String language = "Français";
  String lang = "fr";
  List<String> languages = ["Français", "English", "Deutsch", "Español", "kiswahili", "中国人", "Italiano", "Русский", "Afrikaans", "日本"];
 // List<String> languages = ["Français", "Anglais", "Allemand", "Espagnol", "Swahili", "Chinois", "Russe", "Italien", "Afrikaans", "Japonais"];




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



  notification() {
    return InAppNotifications.show(
        title: 'Welcome to InAppNotifications',
        leading: const Icon(
          Icons.fact_check,
          color: Colors.green,
          size: 50,
        ),
        ending: const Icon(
          Icons.arrow_right_alt,
          color: Colors.red,
        ),
        description:
        'This is a very simple notification with leading and ending widget.',
        onTap: () {
          // Do whatever you need!
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: thirdcolor,
      appBar: AppBar(
        backgroundColor: thirdcolor,
        title: const Text(
          "Notes",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PopBold',
            fontSize: 18
          ),
        ),
        elevation: 10.0,
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
                  child: isLoading == false ? NoteListView(notes: isSearch == false ? notes : searchNotes, refresh: refreshNotes(),) : const Center(
                    child: CircularProgressIndicator(),
                  ),
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
                searchNotes.clear();
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
      searchNotes = notes.where((element) {
        return element.noteTitle.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  refreshNotes() async {
    setState(() => isLoading = true);

    final n = await DuvalDatabase.instance.readAllNotes(NoteType.text.toString());
    //print(n);
    setState(() {
      notes.clear();
      notes = n.reversed.toList();
    });

    setState(() => isLoading = false);
  }
}
