// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:workes_arabic/inner_screens/task_details.dart';
import 'package:workes_arabic/services/global_methods.dart';

class TasksWidget extends StatefulWidget {
  final String taskTitle, taskDescription, taskId, uploadedBy;
  bool isDone;
  TasksWidget({
    required this.taskTitle,
    required this.taskDescription,
    required this.taskId,
    required this.uploadedBy,
    required this.isDone,
  });

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetails(
                taskId: widget.taskId,
                uploadedBy: widget.uploadedBy,
              ),
            ),
          );
        },
        onLongPress: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  actions: [
                    TextButton(
                        onPressed: () {
                          final User? user = _auth.currentUser;
                          String _uid = user!.uid;
                          if (_uid == widget.uploadedBy) {
                            FirebaseFirestore.instance
                                .collection('tasks')
                                .doc(widget.taskId)
                                .delete();
                          } else {
                            GlobalMethods.showErrorDialog(
                                error:
                                    'you don\' have access to delete this task',
                                context: context);
                          }
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ))
                  ],
                );
              });
        },
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(width: 1),
            ),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 20,
            child: Image.network(widget.isDone ? '' : ''),
          ),
        ),
        title: Text(
          widget.taskTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.linear_scale,
                color: Colors.pink.shade800,
              ),
              Text(
                widget.taskDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ]),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          size: 30,
          color: Colors.pink[800],
        ),
      ),
    );
  }
}
