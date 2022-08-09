
const String tableNotes = 'notes';


class NoteFields {
  static final List<String> values = [
    /// Add all fields
    id, isRead, isImportant, title, content, type, duration, folder, createAt
  ];

  static const String id = 'id';
  static const String isRead = "isRead";
  static const String isImportant = 'isImportant';
  static const String title = 'title';
  static const String content = 'content';
  static const String type = 'type';
  static const String duration = 'duration';
  static const String folder = 'folder';
  static const String createAt = 'createAt';
}


enum NoteType{
  audio,
  text,
}

class Note{
  final int? noteId;
  final String noteTitle;
  final String noteContent;
  final String noteType;
  final String noteDuration;
  final bool noteIsImportant;
  final bool noteIsRead;
  final int? noteFolder;
  final DateTime noteCreateAt;

  const Note({
    this.noteId,
    required this.noteTitle,
    required this.noteContent,
    required this.noteType,
    required this.noteDuration,
    required this.noteIsImportant,
    required this.noteIsRead,
    this.noteFolder,
    required this.noteCreateAt
  });

  Note copy({
    int? id,
    String? title,
    String? content,
    String? type,
    String? duration,
    bool? isImportant,
    bool? isRead,
    int? folder,
    DateTime? createAt,
  }) =>
      Note(
        noteId: id ?? noteId,
        noteIsImportant: isImportant ?? noteIsImportant,
        noteDuration: duration ?? noteDuration,
        noteTitle: title ?? noteTitle,
        noteType: type ?? noteType,
        noteIsRead: isRead ?? noteIsRead,
        noteContent: content ?? noteContent,
        noteFolder: folder ?? noteFolder,
        noteCreateAt: createAt ?? noteCreateAt,
      );

  static Note fromJson(Map<String, dynamic> json) => Note(
    noteId: json["id"],
    noteTitle: json["title"] as String,
    noteContent: json["content"] as String,
    noteType: json["type"] as String,
    noteDuration: json["duration"] as String,
    noteIsImportant: json["isImportant"] == 1,
    noteIsRead: json["isRead"] == 1,
    noteFolder: json["folder"],
    noteCreateAt: DateTime.parse(json["createAt"] as String)
  );

  Map<String, dynamic> toJson(){
    return {
      "id": noteId,
      "title": noteTitle,
      "content": noteContent,
      "type": noteType,
      "duration": noteDuration,
      "isImportant": noteIsImportant ? 1 : 0,
      "isRead": noteIsRead ? 1 : 0,
      "folder": noteFolder,
      "createAt": noteCreateAt.toIso8601String()
    };
  }

}

// speech_to_text: ^5.6.0
// clipboard: ^0.1.3
// flutter_quill: ^1.1.0
// flutter_tts: ^3.5.0
// path_provider: ^2.0.11
// flutter_audio_recorder2: ^0.0.2
// audioplayers: ^1.0.1