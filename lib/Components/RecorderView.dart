import 'dart:async';
import 'dart:io';

import 'package:duvalsx/Services/DuvalDatabase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';

import '../Constants.dart';
import '../Models/Note.dart';

class RecorderView extends StatefulWidget {
  final Future<dynamic> onSaved;

  const RecorderView({Key? key, required this.onSaved}) : super(key: key);
  @override
  _RecorderViewState createState() => _RecorderViewState();
}

enum RecordingState {
  unSet,
  set,
  recording,
  stopped,
  pause,
}

class _RecorderViewState extends State<RecorderView> {
  IconData _recordIcon = Icons.mic_none;
  String _recordText = 'Click To Start';
  String audioName = "";
  String audioContent = "";
  String audioDuration = "00:00";
  Recording? recording;
  RecordingState _recordingState = RecordingState.unSet;

  // Recorder properties
  late FlutterAudioRecorder2 audioRecorder;

  @override
  void initState() {
    super.initState();

    FlutterAudioRecorder2.hasPermissions.then((hasPermision) {
      if (hasPermision!) {
        _recordingState = RecordingState.set;
        _recordIcon = Icons.mic;
        _recordText = 'Record';
      }
    });
  }

  @override
  void dispose() {
    _recordingState = RecordingState.unSet;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: thirdcolor
      ),
      child: Wrap(
        children: [
          const Divider(
            height: 2,
            color: Colors.grey,
          ),
          if(_recordingState == RecordingState.recording || _recordingState == RecordingState.pause)
          Container(
            margin: const EdgeInsets.only(top: 5, bottom: 5),
            child: Center(
              child: Text(
                  recording!.duration.toString().split(".").first,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'PopBold'
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () async{
              _onRecordButtonPressed();
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.only(top: 5, bottom: 5),
              padding: const EdgeInsets.only(left: 5,),
              height: 40,
              decoration: BoxDecoration(
                  color: foothcolor,
                  borderRadius: BorderRadius.circular(5.0)
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      _recordingState == RecordingState.recording ? "Pause" : _recordingState == RecordingState.pause ? "Resume" :"Start",
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'PopBold',
                        fontSize: 14
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      _recordingState == RecordingState.recording ? Icons.pause_circle_outline : _recordingState == RecordingState.pause ? Icons.play_circle_outline :Icons.mic,
                      color: _recordingState == RecordingState.recording ? Colors.blueGrey : _recordingState == RecordingState.pause ? color1 : secondcolor,
                    ),
                  )
                ],
              ),
            ),
          ),
          if(_recordingState == RecordingState.recording || _recordingState == RecordingState.pause)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  _stopRecording();
                  setState(() {});
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 10),
                  padding: const EdgeInsets.only(left: 5,),
                  height: 40,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                      color: foothcolor,
                      borderRadius: BorderRadius.circular(5.0)
                  ),
                  child: Stack(
                    children: const [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Stop",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'PopBold',
                              fontSize: 14
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.stop_circle_outlined,
                          color: secondcolor,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  _cancelRecording();
                  setState(() {});
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 10),
                  padding: const EdgeInsets.only(left: 5,),
                  height: 40,
                  width: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                      color: foothcolor,
                      borderRadius: BorderRadius.circular(5.0)
                  ),
                  child: Stack(
                    children: const [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'PopBold',
                              fontSize: 14
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  svsdvdfv(){
    return Stack(
      alignment: Alignment.center,
      children: [
        MaterialButton(
          onPressed: () async {
            await _onRecordButtonPressed();
            setState(() {});
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          child: SizedBox(
            width: 150,
            height: 150,
            child: Icon(
              _recordIcon,
              size: 50,
            ),
          ),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_recordText),
            ))
      ],
    );
  }

  Future<void> _onRecordButtonPressed() async {
    switch (_recordingState) {
      case RecordingState.set:
        await _recordVoice();
        break;

      case RecordingState.recording:
        await _pauseRecording();
        break;

      case RecordingState.pause:
        await _resumeRecording();
        break;

      case RecordingState.stopped:
        await _recordVoice();
        break;

      case RecordingState.unSet:
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please allow recording from settings.'),
        ));
        break;
    }
  }

  _initRecorder() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String name = DateTime.now().millisecondsSinceEpoch.toString();
    String filePath = '${appDirectory.path}/$name.aac';
    audioRecorder = FlutterAudioRecorder2(filePath, audioFormat: AudioFormat.AAC);
    await audioRecorder.initialized;
    setState(() {
      audioContent = filePath;
      audioName = 'REC${DateTime.now().millisecondsSinceEpoch.toString()}';
    });
  }

  _startRecording() async {
    await audioRecorder.start();
    var r = await audioRecorder.current(channel: 0);
    setState(() {
      recording = r;
      _recordingState = RecordingState.recording;
    });

    const tick = Duration(milliseconds: 50);
    Timer.periodic(tick, (Timer t) async {
      if (_recordingState == RecordingStatus.Stopped) {
        t.cancel();
      }

      var current = await audioRecorder.current(channel: 0);
      // print(current.status);
      setState(() {
        recording = current;
      });
    });
    // final r = await audioRecorder.current(channel: 0);
    // setState(() {
    //   recoding = r;
    // });
  }

  _resumeRecording() async{
    await audioRecorder.resume();
    setState(() {
      _recordingState = RecordingState.recording;
    });
  }

  _pauseRecording() async{
    await audioRecorder.pause();
    setState(() {
      _recordingState = RecordingState.pause;
    });
  }

  _cancelRecording() async{
    await audioRecorder.stop();
    setState(() {
      _recordingState = RecordingState.stopped;
    });
  }

  _stopRecording() async {
    var r = await audioRecorder.current(channel: 0);
    await audioRecorder.stop();
    setState(() {
      _recordingState = RecordingState.stopped;
    });
    Duration? d = r?.duration;
    await addNote(d.toString().split(".").first);
    if (kDebugMode) {
      print("duree ${d.toString().split(".").first}");
    }
    widget.onSaved;
  }

  Future addNote(String duration) async {
    final note = Note(
      noteTitle: audioName,
      noteIsRead: false,
      noteIsImportant: false,
      noteDuration: duration,
      noteContent: audioContent,
      noteCreateAt: DateTime.now(),
      noteType: NoteType.audio.toString(),
    );

    await DuvalDatabase.instance.create(note);
  }

  Future<void> _recordVoice() async {
    final hasPermission = await FlutterAudioRecorder2.hasPermissions;
    if (hasPermission ?? false) {
      await _initRecorder();

      await _startRecording();
      // _recordingState = RecordingState.recording;
      // _recordIcon = Icons.stop;
      // _recordText = 'Recording';
    } else {
      if(!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please allow recording from settings.'),
      ));
    }
  }
}
