// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:notekeeper/models/note.dart';
import 'package:notekeeper/screens/note_detail.dart';
import 'package:notekeeper/utils/database_helper.dart';
import 'package:sqflite/sqlite_api.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  final DatabaseHelper databaseHelper = DatabaseHelper.databaseHelper;
  var noteList;
  var noteCount = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = <Note>[];
      updateListView();
    }
    // updateListView();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 2), 'Add Note');
        },
        tooltip: 'Create Note',
        child: const Icon(Icons.add),
      ),
    );
  }

  getNoteListView() {
    TextStyle? titleStyle = Theme.of(context).textTheme.titleLarge;

    return ListView.builder(
        itemCount: noteCount,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getPriorityColor(noteList[position].priority),
                child: getPriorityIcon(noteList[position].priority),
              ),
              title: Text(noteList[position].title),
              subtitle: Text(noteList[position].description ??= ''),
              trailing: GestureDetector(
                child: const Icon(Icons.delete, color: Colors.grey),
                onTap: () {
                  _delete(context, noteList[position]);
                },
              ),
              onTap: () {
                navigateToDetail(noteList[position], 'Edit Note');
              },
            ),
          );
        });
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      default:
        return Colors.yellow;
    }
  }

  // Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return const Icon(Icons.play_arrow);
      case 2:
        return const Icon(Icons.keyboard_arrow_right);
      default:
        return const Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if(result) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDB();
    dbFuture.then((database) {
      var noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((currentNoteList) {
        setState(() {
          noteList = currentNoteList;
          noteCount = noteList.length;
        });
      });
    });
  }
}
