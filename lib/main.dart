import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workes_arabic/screens/auth/login.dart';
import 'package:workes_arabic/screens/tasks.dart';
import 'package:workes_arabic/user_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _appInitialization = Firebase.initializeApp();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _appInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                    child: Text(
                  'App is loading',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ),
            );
          } else if (snapshot.hasError) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                    child: Text(
                  'An error has been occured',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                )),
              ),
            );
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              scaffoldBackgroundColor: Color(0xFFEDE7DC),
              primarySwatch: Colors.blue,
            ),
            home: UserState(),
          );
        });
  }
}
