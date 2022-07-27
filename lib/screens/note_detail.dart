// ignore_for_file: no_logic_in_create_state

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper/models/note.dart';
import 'package:notekeeper/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  const NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  final _priorities = ['High', 'Low'];

  final Note note;
  String appBarTitle;
  DatabaseHelper databaseHelper = DatabaseHelper.databaseHelper;

  NoteDetailState(this.note, this.appBarTitle);

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = Theme.of(context).textTheme.titleMedium;

    titleController.text = note.title;
    descController.text = note.description ??= '';

    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
          return Future.value(true);
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                },
              ),
            ),
            body: Padding(
                padding:
                    const EdgeInsets.only(top: 35.0, left: 10.0, right: 10.0),
                child: ListView(children: <Widget>[
                  ListTile(
                    title: DropdownButton(
                      items: _priorities
                          .map((String dropDownItem) =>
                              DropdownMenuItem<String>(
                                  value: dropDownItem,
                                  child: Text(dropDownItem)))
                          .toList(),
                      style: textStyle,
                      value: getPriorityAsString(note.priority),
                      onChanged: (userSelectedPriority) {
                        setState(() {
                          updatePriorityAsInt(userSelectedPriority.toString());
                        });
                      },
                    ),
                  ),
                  // Second Element
                  Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: TextField(
                      controller: titleController,
                      style: textStyle,
                      onChanged: (value) {
                        updateTitle();
                      },
                      decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: textStyle,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    ),
                  ),

                  // Third Element
                  Padding(
                    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: TextField(
                      controller: descController,
                      style: textStyle,
                      onChanged: (value) {
                        updateDescription();
                      },
                      decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: textStyle,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    ),
                  ),

                  // Fourth Element
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).primaryColor),
                                textStyle: MaterialStateProperty.all(
                                    const TextStyle(color: Colors.white))),
                            child: const Text(
                              'Save',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              setState(() {
                                _save();
                              });
                            },
                          ),
                        ),
                        Container(
                          width: 5.0,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Theme.of(context).primaryColor),
                                textStyle: MaterialStateProperty.all(
                                    const TextStyle(color: Colors.white))),
                            child: const Text(
                              'Delete',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              setState(() {
                                _delete();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ]))));
  }

  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  getPriorityAsString(int value) {
    switch (value) {
      case 1:
        return _priorities[0]; // 'High'
      case 2:
        return _priorities[1]; // 'Low'
    }
  }

  // Update the title of Note object
  void updateTitle() {
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descController.text;
  }

  // Save data to database
  void _save() async {

    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {  // Case 1: Update operation
      result = await databaseHelper.updateNote(note);
    } else { // Case 2: Insert Operation
      result = await databaseHelper.insertNote(note);
    }

    if (result != 0) {  // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {  // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }

  }


  void _delete() async {

    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {

    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }
}
