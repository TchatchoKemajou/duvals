import 'package:duvalsx/Services/TextToSpeechService.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:share_plus/share_plus.dart';

import '../Constants.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({Key? key}) : super(key: key);

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  TextToSpeechService textToSpeechService = TextToSpeechService();
  bool isSpeaking = false;
  String sourceLanguage = "Anglais";
  String targetLanguage = "Français";
  List<String> languages = ["Français", "Anglais", "Allemand", "Espagnol", "Swahili", "Chinois", "Russe", "Italien", "Afrikaans", "Japonais"];
  String translateText = "Traduction";


  @override
  void initState() {
    super.initState();
    setState(() {
      isSpeaking = textToSpeechService.initializeTTS();
    });
  }


  @override
  void dispose() {
    textToSpeechService.stop();
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: (){
                textToSpeechService.speak(translateText);
              },
              child: const Icon(
                  Icons.volume_up,
                  size: 30,
                  color: Colors.blueGrey
              ),
            ),
          ),
        ],
        elevation: 0.0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.only(right:10.0, left: 10.0),
                  //width: MediaQuery.of(context).size.width,
                  height: 40,
                  decoration: BoxDecoration(
                    //color: fisrtcolor,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: Colors.grey,)
                  ),
                  child: Center(
                    child: DropdownButton<String>(
                      value: sourceLanguage,
                      dropdownColor: fisrtcolor,
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
                          sourceLanguage = e!;
                        });
                        // switch (e!) {
                        //   case "Allemand":
                        //     value.changeLocale("fr", "Allemand");
                        //     //await videosProviders.allMovies(1);
                        //     break;
                        //
                        //   case "Français":
                        //     value.changeLocale("fr", "Français");
                        //     //await videosProviders.allMovies(1);
                        //     break;
                        //
                        //   case "Anglais":
                        //     value.changeLocale("en", "Anglais");
                        //     break;
                        // }
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
                    ),
                  ),
                ),
                IconButton(
                    onPressed: (){

                    },
                    icon: const Icon(Icons.compare_arrows, color: secondcolor, size: 24,)
                ),
                Container(
                  padding: const EdgeInsets.only(right:10.0, left: 10.0),
                  //width: MediaQuery.of(context).size.width,
                  height: 40,
                  decoration: BoxDecoration(
                    //color: fisrtcolor,
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: Colors.grey,)
                  ),
                  child: Center(
                    child: DropdownButton<String>(
                      value: targetLanguage,
                      dropdownColor: fisrtcolor,
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
                          targetLanguage = e!;
                        });
                        // switch (e!) {
                        //   case "Allemand":
                        //     value.changeLocale("fr", "Allemand");
                        //     //await videosProviders.allMovies(1);
                        //     break;
                        //
                        //   case "Français":
                        //     value.changeLocale("fr", "Français");
                        //     //await videosProviders.allMovies(1);
                        //     break;
                        //
                        //   case "Anglais":
                        //     value.changeLocale("en", "Anglais");
                        //     break;
                        // }
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
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: thirdcolor,
              child: TextFormField(
                onChanged: (source) async{
                  var t = await source.translate(to: "en");
                  setState((){
                    translateText = t.text;
                  });
                },
                maxLines: null,
                style: const TextStyle(
                  fontFamily: 'PopBold',
                  color: Colors.white
                ),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10),
                  isDense: true,
                  hintText: 'source',
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'PopBold'
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white
                    )
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.white
                      )
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.white
                      )
                  ),
                ),
                keyboardType: TextInputType.multiline,
                expands: true,
              ),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                child: SelectableText(
                  translateText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'PopBold',
                    fontSize: 14
                  ),
                ),
              ),
          )
        ],
      ),
    );
  }
}
