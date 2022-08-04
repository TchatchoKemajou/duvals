import 'package:audioplayers/audioplayers.dart';
import 'package:duvalsx/Models/Note.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordListView extends StatefulWidget {
  final Note records;
  const RecordListView({
    Key? key,
    required this.records,
  }) : super(key: key);

  @override
  State<RecordListView> createState() => _RecordListViewState();
}

class _RecordListViewState extends State<RecordListView> {
  late int _totalDuration;
  late int _currentDuration;
  double _completedPercentage = 0.0;
  bool _isPlaying = false;
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            child: IconButton(
              icon: const Icon(
                  Icons.play_circle_outline
              ),
              onPressed: (){

              },
            ),
          ),
          title: Row(
            children: [
              Text(
                widget.records.noteTitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'PopBold',
                    fontSize: 15
                ),
              ),

            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.records.noteDuration,
                style: const TextStyle(
                    color: Colors.grey,
                    fontFamily: 'PopBold',
                    fontSize: 15
                ),
              ),
              Text(
                DateFormat.yMMMd().format(widget.records.noteCreateAt),
                style: const TextStyle(
                    color: Colors.grey,
                    fontFamily: 'PopRegular',
                    fontSize: 15
                ),
              )
            ],
          ),
        ),
        const Divider(
          height: 2,
          color: Colors.grey,
        ),
      ],
    );
  }

  // zdaqdaqd(){
  //   return ExpansionTile(
  //     title: Text('New recoding ${widget.records.length - i}'),
  //     subtitle: Text(_getDateFromFilePatah(
  //         filePath: widget.records.elementAt(i))),
  //     onExpansionChanged: ((newState) {
  //       if (newState) {
  //         setState(() {
  //           _selectedIndex = i;
  //         });
  //       }
  //     }),
  //     children: [
  //       Container(
  //         height: 100,
  //         padding: const EdgeInsets.all(10),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             LinearProgressIndicator(
  //               minHeight: 5,
  //               backgroundColor: Colors.black,
  //               valueColor:
  //               const AlwaysStoppedAnimation<Color>(Colors.green),
  //               value: _selectedIndex == i ? _completedPercentage : 0,
  //             ),
  //             IconButton(
  //               icon: _selectedIndex == i
  //                   ? _isPlaying
  //                   ? const Icon(Icons.pause)
  //                   : const Icon(Icons.play_arrow)
  //                   : const Icon(Icons.play_arrow),
  //               onPressed: () => _onPlay(
  //                   filePath: widget.records.elementAt(i), index: i),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Future<void> _onPlay({required String filePath, required int index}) async {
    AudioPlayer audioPlayer = AudioPlayer();

    if (!_isPlaying) {
      audioPlayer.play(DeviceFileSource(filePath), );
      setState(() {
        _selectedIndex = index;
        _completedPercentage = 0.0;
        _isPlaying = true;
      });

      audioPlayer.onPlayerComplete.listen((_) {
        setState(() {
          _isPlaying = false;
          _completedPercentage = 0.0;
        });
      });
      audioPlayer.onDurationChanged.listen((duration) {
        setState(() {
          _totalDuration = duration.inMicroseconds;
        });
      });

      audioPlayer.onPositionChanged.listen((duration) {
        setState(() {
          _currentDuration = duration.inMicroseconds;
          _completedPercentage =
              _currentDuration.toDouble() / _totalDuration.toDouble();
        });
      });
    }
  }

  String _getDateFromFilePatah({required String filePath}) {
    String fromEpoch = filePath.substring(
        filePath.lastIndexOf('/') + 1, filePath.lastIndexOf('.'));

    DateTime recordedDate =
        DateTime.fromMillisecondsSinceEpoch(int.parse(fromEpoch));
    int year = recordedDate.year;
    int month = recordedDate.month;
    int day = recordedDate.day;

    return ('$year-$month-$day');
  }
}
