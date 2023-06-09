import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workes_arabic/constants/constants.dart';

import '../widgets/all_workers_widget.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/tasks_widget.dart';

class AllWorkesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'All workers',
          style: TextStyle(color: Colors.pink),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
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
                  return AllWorkersWidget(
                    userID: snapshot.data!.docs[index]['id'],
                    userName: snapshot.data!.docs[index]['name'],
                    userEmail: snapshot.data!.docs[index]['email'],
                    positionInCompany: snapshot.data!.docs[index]
                        ['positionInCompany'],
                    phoneNumber: snapshot.data!.docs[index]['phoneNumber'],
                    userImageUrl: snapshot.data!.docs[index]['userImageUrl'],
                  );
                },
              );
            } else {
              return Center(
                child: Text('No user found'),
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
}
