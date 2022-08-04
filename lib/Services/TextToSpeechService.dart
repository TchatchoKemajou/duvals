
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService{
  final _flutterTts = FlutterTts();
  bool state = false;

   bool initializeTTS(){
    _flutterTts.setStartHandler(() {
      state =  true;
    });
    _flutterTts.setCompletionHandler(() {
      state = false;
    });
    _flutterTts.setErrorHandler((message) {
      state = false;
    });

    return state;
  }

  void speak(String text) async {
      await _flutterTts.speak(text);
  }

  void stop() async {
    await _flutterTts.stop();
  }

}