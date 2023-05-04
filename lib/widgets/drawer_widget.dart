import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workes_arabic/inner_screens/add_task_screen.dart';
import 'package:workes_arabic/inner_screens/profile.dart';
import 'package:workes_arabic/screens/all_workers.dart';
import 'package:workes_arabic/screens/tasks.dart';
import 'package:workes_arabic/user_state.dart';

import '../constants/constants.dart';

class DrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.cyan),
            child: Column(children: [
              Flexible(child: Image.network('')),
              SizedBox(
                height: 20,
              ),
              Flexible(
                  child: Text(
                'Work OS Arabic',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Constants.darkBlue,
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                ),
              )),
            ]),
          ),
          SizedBox(
            height: 30,
          ),
          _listTile('All tasks', () {
            _navigateToTaskScreen(context);
          }, Icons.task_outlined),
          _listTile('My account', () {
            _navigateToAllProfileScreen(context);
          }, Icons.settings_outlined),
          _listTile('Registered workes', () {
            _navigateToAllWorkersScreen(context);
          }, Icons.workspaces_outlined),
          _listTile('Add tasks', () {
            _navigateToAddTaskScreen(context);
          }, Icons.add_task_outlined),
          Divider(
            thickness: 1,
          ),
          _listTile('Logout', () {
            _logout(context);
          }, Icons.logout_outlined),
        ],
      ),
    );
  }

  void _navigateToAllProfileScreen(context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    final uid = user!.uid;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userID: uid,
        ),
      ),
    );
  }

  void _navigateToAllWorkersScreen(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AllWorkesScreen(),
      ),
    );
  }

  void _navigateToAddTaskScreen(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(),
      ),
    );
  }

  void _navigateToTaskScreen(context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TasksScreen(),
      ),
    );
  }

  void _logout(context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  '',
                  height: 20,
                  width: 20,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Sign out'),
              ),
            ]),
            content: Text(
              'Do you wanna sign out',
              style: TextStyle(
                color: Constants.darkBlue,
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (ctx) => UserState()));
                },
                child: Text(
                  'Ok',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });
  }

  Widget _listTile(String label, Function fct, IconData icon) {
    return ListTile(
      onTap: () {
        fct();
      },
      leading: Icon(
        icon,
        color: Constants.darkBlue,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: Constants.darkBlue,
          fontSize: 20,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
