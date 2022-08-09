import 'package:duvalsx/Services/TextToSpeechService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:share_plus/share_plus.dart';

import '../Constants.dart';
import '../Providers/LanguageChangeProvider.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({Key? key}) : super(key: key);

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  TextToSpeechService textToSpeechService = TextToSpeechService();
  final translateController = TextEditingController();
  final translator = GoogleTranslator();
  bool isSpeaking = false;
  String sourceLanguage = "English";
  String targetLanguage = "Français";
  String localSource = "en";
  String localTarget = "fr";
  List<String> languagesSource = ["Français", "English", "Deutsch", "Español", "kiswahili", "中国人", "Italien", "Русский", "Afrikaans", "日本"];
  List<String> languagesTarget = ["Français", "English", "Deutsch", "Español", "kiswahili", "中国人", "Italien", "Русский", "Afrikaans", "日本"];
  String translateText = "Traduction";


  @override
  void initState() {
    super.initState();
    setState(() {
      isSpeaking = textToSpeechService.initializeTTS();
    });
  }

  // loadLanguage() {
  //   final languageProvider = Provider.of<LanguageChangeProvider>(context, listen: false);
  //   String l = languageProvider.currentLocale.toString();
  //   setState(() {
  //     language = languageProvider.currentLocaleName;
  //     if(language == "All"){
  //       lang = "all";
  //     }else{
  //       lang = l;
  //     }
  //   });
  // }


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
          "Traduction",
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
        elevation: 10.0,
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
                        switch (e!) {
                          case "Deutsch":
                            setState(() {
                              localSource = "de";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "Français":
                            setState(() {
                              localSource = "fr";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "English":
                            setState(() {
                              localSource = "en";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "Español":
                            setState(() {
                              localSource = "es";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "kiswahili":
                            setState(() {
                              localSource = "sw";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "Русский":
                            setState(() {
                              localSource = "ru";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "中国人":
                            setState(() {
                              localSource = "zh";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "Italien":
                            setState(() {
                              localSource = "it";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "Afrikaans":
                            setState(() {
                              localSource = "af";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "日本":
                            setState(() {
                              localSource = "ja";
                            });
                            translateFunction(translateController.text);
                            break;
                        }
                      },
                      items: languagesSource
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
                      String temp1 = localSource;
                      String temp2 = sourceLanguage;

                      setState(() {
                        localSource = localTarget;
                        localTarget = temp1;
                        sourceLanguage = targetLanguage;
                        targetLanguage = temp2;
                        translateController.text = translateText;
                      });
                      translateFunction(sourceLanguage);
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
                        switch (e!) {
                          case "Deutsch":
                            setState(() {
                              localTarget = "de";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "Français":
                            setState(() {
                              localTarget = "fr";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "English":
                            setState(() {
                              localTarget = "en";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "Español":
                            setState(() {
                              localTarget = "es";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "kiswahili":
                            setState(() {
                              localTarget = "sw";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "Русский":
                            setState(() {
                              localTarget = "ru";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "中国人":
                            setState(() {
                              localTarget = "zh";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "Italien":
                            setState(() {
                              localTarget = "it";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "Afrikaans":
                            setState(() {
                              localTarget = "af";
                            });
                            translateFunction(translateController.text);
                            break;

                          case "日本":
                            setState(() {
                              localTarget = "ja";
                            });
                            translateFunction(translateController.text);
                            break;
                        }
                      },
                      items: languagesTarget
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
                onChanged: translateFunction,
                controller: translateController,
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

  translateFunction(String source) {
    translator.translate(source, from: localSource, to: localTarget).then((s) {
      setState(() {
        translateText = s.text;
      });
    });
  }
}
