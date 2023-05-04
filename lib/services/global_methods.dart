import 'package:flutter/material.dart';

import '../constants/constants.dart';

class GlobalMethods {
  static void showErrorDialog(
      {required String error, required BuildContext context}) {
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
                child: Text('Error Occured'),
              ),
            ]),
            content: Text(
              error,
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
                child: Text(
                  'Ok',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });
  }
}
