import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: unused_import
import 'package:flutter/services.dart';

import './models/task.dart';

void main() => runApp(TaskApp());

class TaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'test',
      home: TaskFirebaseDemo(),
    );
  }
}

class TaskFirebaseDemo extends StatefulWidget {
  TaskFirebaseDemo() : super();

  final String appTitle = "Task DB";
  @override
  _TaskFirebaseDemoState createState() => _TaskFirebaseDemoState();
}

class _TaskFirebaseDemoState extends State<TaskFirebaseDemo> {
  TextEditingController taskNameController = TextEditingController();
  TextEditingController taskManagerController = TextEditingController();

  bool isEditing = false;

  bool textFeildVisibility = false;

  String firestoreCollectionName = "Task";

  Task currentTask;

  gettAllTask() {
    return Firestore.instance.collection(firestoreCollectionName).snapshots();
  }

  addTask() async {
    Task task = Task(
        taskName: taskNameController.text,
        taskTime: taskManagerController.text);

    try {
      Firestore.instance.runTransaction((Transaction transaction) async {
        await Firestore.instance
            .collection(firestoreCollectionName)
            .document()
            .setData(task.toJson());
      });
    } catch (e) {
      print(e.toString());
    }
  }

  updateTask(Task task, String taskName, String taskTime) {
    try {
      Firestore.instance.runTransaction((transaction) async {
        await transaction.update(task.documentReference,
            {'taskName': taskName, 'taskTime': taskTime});
      });
    } catch (e) {
      print(e.toString());
    }
  }

  updateIfEditing() {
    if (isEditing) {
      //update
      updateTask(
          currentTask, taskNameController.text, taskManagerController.text);

      setState(() {
        isEditing = false;
      });
    }
  }

  deleteTask(Task task) {
    Firestore.instance.runTransaction((Transaction transaction) async {
      await transaction.delete(task.documentReference);
    });
  }

  Widget buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: gettAllTask(),
      // ignore: missing_return
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }
        if (snapshot.hasData) {
          print("Document -> ${snapshot.data.documents.length}");
          return buildList(context, snapshot.data.documents);
        }
      },
    );
  }

  Widget buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      children: snapshot.map((data) => listItemBuild(context, data)).toList(),
    );
  }

  Widget listItemBuild(BuildContext context, DocumentSnapshot data) {
    final task = Task.fromSnapshot(data);

    return Padding(
      key: ValueKey(task.taskName),
      padding: EdgeInsets.symmetric(vertical: 19, horizontal: 1),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(4),
        ),
        child: SingleChildScrollView(
          child: ListTile(
            title: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.book,
                      color: Colors.yellow,
                    ),
                    Text(task.taskName),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.person,
                      color: Colors.purple,
                    ),
                    Text(task.taskName),
                  ],
                )
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              onPressed: () {
                deleteTask(task);
              },
            ),
            onTap: () {
              setUpdateUI(task);
            },
          ),
        ),
      ),
    );
  }

  setUpdateUI(Task task) {
    taskNameController.text = task.taskName;
    taskManagerController.text = task.taskTime;

    setState(() {
      textFeildVisibility = true;
      isEditing = true;
      currentTask = task;
    });
  }

  button() {
    return SizedBox(
      width: double.infinity,
      // ignore: deprecated_member_use
      child: OutlineButton(
        child: Text(isEditing ? "UPDATE" : "ADD"),
        onPressed: () {
          if (isEditing == true) {
            updateIfEditing();
          } else {
            addTask();
          }

          setState(() {
            textFeildVisibility = false;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.appTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                textFeildVisibility = !textFeildVisibility;
              });
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            textFeildVisibility
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        children: [
                          TextFormField(
                            controller: taskNameController,
                            decoration: InputDecoration(
                                labelText: "Task Name",
                                hintText: "Enter Task Name"),
                          ),
                          TextFormField(
                            controller: taskManagerController,
                            decoration: InputDecoration(
                                labelText: "Task Time",
                                hintText: "Enter Task Time"),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      button()
                    ],
                  )
                : Container(),
            SizedBox(
              height: 20,
            ),
            Text(
              "Tasks",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SizedBox(
              height: 20,
            ),
            Flexible(
              child: buildBody(context),
            )
          ],
        ),
      ),
    );
  }
}
