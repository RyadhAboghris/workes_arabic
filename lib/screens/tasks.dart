import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:workes_arabic/constants/constants.dart';

import '../widgets/drawer_widget.dart';
import '../widgets/tasks_widget.dart';

class TasksScreen extends StatefulWidget {
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String? taskCategory;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        // leading: Builder(
        //   builder: ((ctx) => IconButton(
        //         icon: Icon(
        //           Icons.menu_outlined,
        //           color: Colors.red,
        //         ),
        //         onPressed: () {
        //           Scaffold.of(ctx).openDrawer();
        //         },
        //       )),
        // ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Tasks',
          style: TextStyle(color: Colors.pink),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showTaskCategoryDialog(context, size);
              },
              icon: Icon(
                Icons.filter_list_outlined,
                color: Colors.black,
              ))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('taskCategory', isEqualTo: taskCategory)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data!.docs.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return TasksWidget(
                      taskTitle: snapshot.data!.docs[index]['taskTitle'],
                    taskDescription: snapshot.data!.docs[index]
                        ['taskDescription'],
                    taskId: snapshot.data!.docs[index]['taskId'],
                    uploadedBy: snapshot.data!.docs[index]['upLoadedBy'],
                    isDone: snapshot.data!.docs[index]['isDone'],
                    // taskTitle: snapshot.data!.docs[index]['taskTitle'],
                    // taskDescription: snapshot.data!.docs[index]
                    //     ['taskDescription'],
                    // taskId: snapshot.data!.docs[index]['taskId'],
                    // uploadedBy: snapshot.data!.docs[index]['uploadedBy'],
                    // isDone: snapshot.data!.docs[index]['isDone'],
                  );
                },
              );
            } else {
              return Center(
                child: Text('No tasks has been uploaded'),
              );
            }
          }
          return Center(
            child: Text('Something went wroxng'),
          );
        },
      ),
    );
  }

  void showTaskCategoryDialog(context, size) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Task category',
              style: TextStyle(
                color: Colors.pink.shade300,
                fontSize: 20,
              ),
            ),
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Constants.taskCategoryList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        taskCategory = Constants.taskCategoryList[index];
                      });
                      Navigator.canPop(context) ? Navigator.pop(context) : null;
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.red[200],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            Constants.taskCategoryList[index],
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF00325A),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    taskCategory = null;
                  });
                },
                child: Text('Cancel filter'),
              ),
            ],
          );
        });
  }
}
