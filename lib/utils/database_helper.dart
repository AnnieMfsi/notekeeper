import 'dart:async';
import 'dart:io';

import 'package:notekeeper/models/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  DatabaseHelper._createInstance();
  static final DatabaseHelper databaseHelper = DatabaseHelper._createInstance(); // Singleton


  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  static Database? _database;

  Future<Database?> get database async {
    _database ??= await initializeDB();
    return _database;
  }

  Future<Database> initializeDB() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}notes.db';

    // open/crete db in the path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  // Get all notes
  Future<List<Note>> getNoteList() async {
    Database? db = await database;
    List<Map<String, dynamic>> resultMap = await db!.query(noteTable, orderBy: '$colPriority ASC');

    return List.generate(resultMap.length, (index) {
      // Converting the map object to Note object properties and sending as parameters
      return Note.withID(
          resultMap[index]['id'],
          resultMap[index]['title'],
          resultMap[index]['date'],
          resultMap[index]['priority'],
          resultMap[index]['description']);
    });
  }

  // Insert a note
  Future<int> insertNote(Note newNote) async {
    Database? db = await database;
    var result = await db!.insert(noteTable, newNote.toMap());
    return result;
  }

  // Update a note
  Future<int> updateNote(Note note) async {
    Database? db = await database;
    var result = await db!.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Delete a note
  Future<int> deleteNote(int? id) async {
    Database? db = await database;
    int result =
        await db!.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  // Get the count for the number of notes
  getNoteCount() async {
    Database? db = await database;
    List<Map<String, dynamic>> x =
        await db!.rawQuery('SELECT COUNT * from $noteTable');
    return Sqflite.firstIntValue(x);
  }

}
