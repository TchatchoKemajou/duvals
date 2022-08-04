
import 'package:duvalsx/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../Models/Note.dart';


class NoteListView extends StatefulWidget {
  final List<Note> notes;
  const NoteListView({
    Key? key,
    required this.notes
  }) : super(key: key);

  @override
  State<NoteListView> createState() => _NoteListViewState();
}

class _NoteListViewState extends State<NoteListView> {
  @override
  Widget build(BuildContext context) {
    return 
    //   widget.notes.isEmpty
    //   ? const Center(child: Text(
    //   'Aucune note',
    //   style: TextStyle(
    //     color: Colors.white,
    //   ),
    // ))
    //   :
    StaggeredGridView.countBuilder(
          padding: const EdgeInsets.all(8),
          itemCount:  5, //widget.notes.length,
          staggeredTileBuilder: (index) => StaggeredTile.count(1, index.isEven ? 1.5 : 1.3),
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          itemBuilder: (context, index) {
           // final note = widget.notes[index];

            return Card(
              color: kContentColorLightTheme,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Title",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'PopBold',
                            fontSize: 16
                          ),
                        ),
                        Text(
                          "1 Aout 2022",
                          style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'PopLight',
                              fontSize: 13
                          ),
                        ),
                        Text(
                          "ekvjnoiefhvnoeribvlevherofbvdfjkvfuibvkfuvgfbvjkvgfbucibefcuicfbgerfgjebdfgeryjvfcecjjerybfryjzeyzerfbjzyejyfbejyrc frbfjycjecbvjehbvjdc bjebycjebjkbfxjcef",
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 6,
                          style: TextStyle(
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
            );
          },
    );
  }
}
