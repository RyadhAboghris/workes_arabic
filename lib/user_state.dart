import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workes_arabic/screens/auth/login.dart';
import 'package:workes_arabic/screens/tasks.dart';

class UserState extends StatelessWidget {
  const UserState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.data == null) {
            return LoginScreen();
          } else if (userSnapshot.hasData) {
            return TasksScreen();
          } else if (userSnapshot.hasError) {
            return Center(
                child: Text(
              'An error has been occured',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ));
          }
          return Scaffold(
            body: Center(
                child: Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            )),
          );
        });
  }
}
