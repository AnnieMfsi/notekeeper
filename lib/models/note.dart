/*
* Model class to define the Note database & table property
* */

class Note {

  int? _id;
  String _title;
  String? _description;
  String _date;
  int _priority;

  Note(this._title, this._date, this._priority, [this._description]);
  Note.withID(this._id, this._title, this._date, this._priority, [this._description]);

  int? get id => _id;
  String get title => _title;
  String? get description => _description;
  String get date => _date;
  int get priority => _priority;

  set title(String newTitle) {
    if(newTitle.length <= 225) {
      _title = newTitle;
    }
  }

  set description(String? newDescription) {
    if (newDescription !=null && newDescription.length <= 255) {
      _description = newDescription;
    }
  }

  set priority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 2) {
      _priority = newPriority;
    }
  }

  set date(String newDate) {
    _date = newDate;
  }

  // Convert note data to map object
  Map<String, dynamic> toMap() {

    var noteMap = Map<String, dynamic>();
    if (id != 0) {
      noteMap['id'] = _id;
    }
    noteMap['title'] = _title;
    noteMap['description'] = _description;
    noteMap['priority'] = _priority;
    noteMap['date'] = _date;

    return noteMap;
  }

}
