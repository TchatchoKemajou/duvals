import 'package:duvalsx/Pages/FolderNoteList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../Constants.dart';
import '../Models/Folder.dart';
import '../Services/DuvalDatabase.dart';

class FolderPage extends StatefulWidget {
  const FolderPage({Key? key}) : super(key: key);

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final _formKey = GlobalKey<FormState>();
  String? title;
  List<Folder> folders = [];
  List<Folder> searchFolders = [];
  bool isSearch = false;
  bool isLoading = false;
  bool isActiveSearch = false;
  final searchController = TextEditingController();

  refreshFolder() async {
    setState(() => isLoading = true);

    final f = await DuvalDatabase.instance.readAllFolder();
    //print(n);
    setState(() {
      folders.clear();
      folders = f;
    });

    setState(() => isLoading = false);
  }


  @override
  void initState() {
    super.initState();
    refreshFolder();
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
          "Dossier",
          style: TextStyle(
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
                          searchFolders.clear();
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
                    String? result = await showDialog<String>(
                        context: context,
                        builder: (context) => dialogTitle()
                    );

                    if(result != null){
                      await createFolder(result);
                      refreshFolder();
                    }else{

                    }
                  },
                  icon: const Icon(
                      Icons.create_new_folder,
                      color: kWarninngColor
                  ),
                ),
                IconButton(
                  onPressed: () {  },
                  icon: const Icon(
                      Icons.settings,
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
              child:
              folders.isEmpty
                  ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.folder,
                        size: 64,
                        color: kWarninngColor,
                      ),
                      Text(
                        'Aucun dossier',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'PopRegular',
                          fontSize: 13
                        ),
                      ),
                    ],
                  ))
                  :
              StaggeredGridView.countBuilder(
                padding: const EdgeInsets.all(8),
                itemCount: isSearch == false ?  folders.length : searchFolders.length,
                staggeredTileBuilder: (index) => StaggeredTile.count(1, index.isEven ? 1.0 : 1.0),
                crossAxisCount: 3,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                itemBuilder: (context, index) {
                  final folder = isSearch == false ?  folders[index] : searchFolders[index];

                  return InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FolderNoteList(folder: folder,)));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.folder,
                          size: 64,
                          color: kWarninngColor,
                        ),

                        Text(
                          folder.folderName,
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'PopRegular',
                              fontSize: 14
                          ),
                        )
                      ],
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
        "Nouveau dossier",
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
            validator: (e) => e!.isEmpty || e.length < 6 ? "6 caractères minimum" : null,
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
  Future createFolder(String name) async {
    final folder = Folder(
      folderName: name,
      folderCreateAt: DateTime.now(),
    );

    await DuvalDatabase.instance.createFolder(folder);
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
      searchFolders = folders.where((element) {
        return element.folderName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }
}
