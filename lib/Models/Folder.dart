const String tableFolders = 'folder';


class FolderFields {
  static final List<String> values = [
    /// Add all fields
    id,name,createAt
  ];

  static const String id = 'id';
  static const String name = 'name';
  static const String createAt = 'createAt';
}

class Folder{
  final int? folderId;
  final String folderName;
  final DateTime folderCreateAt;

  const Folder({
   this.folderId,
    required this.folderName,
    required this.folderCreateAt
  });


  Folder copy({
    int? id,
    String? name,
    DateTime? createAt,
  }) =>
      Folder(
        folderId: id ?? folderId,
        folderName: name ?? folderName,
        folderCreateAt: createAt ?? folderCreateAt,
      );

  static Folder fromJson(Map<String, dynamic> json) => Folder(
      folderId: json["id"],
      folderName: json["name"] as String,
      folderCreateAt: DateTime.parse(json["createAt"] as String)
  );

  Map<String, dynamic> toJson(){
    return {
      "id": folderId,
      "name": folderName,
      "createAt": folderCreateAt.toIso8601String()
    };
  }
}