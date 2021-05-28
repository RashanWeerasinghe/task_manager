import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String taskName;
  String taskTime;

  DocumentReference documentReference;

  Task({this.taskName, this.taskTime});

  Task.fromMap(Map<String, dynamic> map, {this.documentReference}) {
    taskName = map["taskName"];
    taskTime = map["taskTime"];
  }

  Task.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, documentReference: snapshot.reference);

  toJson() {
    return {'taskName': taskName, 'taskTime': taskTime};
  }
}
