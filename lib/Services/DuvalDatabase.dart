
import 'package:duvalsx/Models/Folder.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../Models/Note.dart';

class DuvalDatabase{
  static final DuvalDatabase instance = DuvalDatabase._init();
  final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  final textType = 'TEXT NOT NULL';
  final boolType = 'BOOLEAN NOT NULL';
  final integerType = 'INTEGER NOT NULL';
  final integerTypeNull = 'INTEGER';

  static Database? _database;

  DuvalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB, singleInstance: false);
  }

  Future _createDB(Database db, int version) async{
        await db.execute('''
        CREATE TABLE $tableFolders ( 
      ${FolderFields.id} $idType,
      ${FolderFields.name} $textType,
      ${FolderFields.createAt} $textType
      )
        ''');
        await db.execute('''
        CREATE TABLE $tableNotes ( 
      ${NoteFields.id} $idType,
      ${NoteFields.title} $textType,
      ${NoteFields.content} $textType,
      ${NoteFields.type} $textType,
      ${NoteFields.duration} $textType,
      ${NoteFields.isImportant} $boolType,
      ${NoteFields.isRead} $boolType,
      ${NoteFields.folder} $integerTypeNull,
      ${NoteFields.createAt} $textType
      )
        ''');

  }

  Future<Note> create(Note note) async{
    final db = await instance.database;
    final id = await db.insert(tableNotes, note.toJson());
    return note.copy(id: id);
  }

  Future<Folder> createFolder(Folder folder) async{
    final db = await instance.database;
    final id = await db.insert(tableFolders, folder.toJson());
    return folder.copy(id: id);
  }

  Future<List<Note>> readFolder(int id) async {
    final db = await instance.database;

    const orderBy = '${NoteFields.createAt} ASC';

    final result = await db.query(
        tableNotes,
        where: '${NoteFields.folder} = ? AND ${NoteFields.type} = ?',
        whereArgs: [id, NoteType.text.toString()],
        orderBy: orderBy);

    return result.map((json) => Note.fromJson(json)).toList();
  }

  Future<Note> readNote(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableNotes,
      columns: NoteFields.values,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Note>> readAllNotes(String type) async {
    final db = await instance.database;

    const orderBy = '${NoteFields.createAt} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(
        tableNotes,
        where: '${NoteFields.type} = ?',
        whereArgs: [type],
        orderBy: orderBy);

    return result.map((json) => Note.fromJson(json)).toList();
  }

  Future<List<Folder>> readAllFolder() async {
    final db = await instance.database;

    const orderBy = '${FolderFields.createAt} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(
        tableFolders,
        orderBy: orderBy);

    return result.map((json) => Folder.fromJson(json)).toList();
  }

  Future<int> update(Note note) async {
    final db = await instance.database;

    return db.update(
      tableNotes,
      note.toJson(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.noteId],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableNotes,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

}