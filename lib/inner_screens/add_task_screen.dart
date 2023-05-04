import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:workes_arabic/services/global_methods.dart';
import 'package:workes_arabic/widgets/drawer_widget.dart';

import '../constants/constants.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  TextEditingController _categoryController =
      TextEditingController(text: 'Task Category');
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  TextEditingController _deadlineDateController =
      TextEditingController(text: 'pick up a date');
  final _formKey = GlobalKey<FormState>();
  DateTime? picked;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Timestamp? _deadlineDateTimeStamp;

  @override
  void dispose() {
    super.dispose();
    _categoryController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _deadlineDateController.dispose();
  }

  void uploadFct() async {
    User? user = _auth.currentUser;
    String _uid = user!.uid;
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      if (_deadlineDateController.text == 'pick up a date' ||
          _categoryController.text == 'Task Category') {
        GlobalMethods.showErrorDialog(
            error: 'Please pick up everything', context: context);
        return;
      }
      setState(() {
        _isLoading = true;
      });
      final taskID = Uuid().v4();
      try {
        await FirebaseFirestore.instance.collection('tasks').doc(taskID).set({
          'taskId': taskID,
          'upLoadedBy': _uid,
          'taskTitle': _titleController.text,
          'taskDescription': _descriptionController.text,
          'deadlineDate': _deadlineDateController.text,
          'deadlineDateTimeStamp': _deadlineDateTimeStamp,
          'taskCategory': _categoryController.text,
          'taskComments': [],
          'isDone': false,
          'createdAt': Timestamp.now(),
        });
        Fluttertoast.showToast(
            msg: "Task has been uploaded successfuly",
            toastLength: Toast.LENGTH_SHORT,
            // gravity: ToastGravity.CENTER,
            // timeInSecForIosWeb: 1,
            // backgroundColor: Colors.red,
            // textColor: Colors.white,
            fontSize: 16.0);
        // _categoryController.clear();
        _descriptionController.clear();
        _titleController.clear();

        setState(() {
          _categoryController.text = 'Task Category';
          _deadlineDateController.text = 'pick up a date';
        });
      } catch (error) {
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('form not valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Constants.darkBlue),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      drawer: DrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Card(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'All field are required',
                    style: TextStyle(
                      fontSize: 25,
                      color: Constants.darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Divider(
                thickness: 1,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textsWidget(textLabel: 'Task category'),
                      _textFormFields(
                          vlaueKey: 'TaskCategory',
                          contrller: _categoryController,
                          enabled: false,
                          fct: () {
                            showTaskCategoryDialog(size);
                          },
                          maxLength: 100),
                      textsWidget(textLabel: 'Task title'),
                      _textFormFields(
                          vlaueKey: 'TaskTitle',
                          contrller: _titleController,
                          enabled: true,
                          fct: () {},
                          maxLength: 100),
                      textsWidget(textLabel: 'Task Description'),
                      _textFormFields(
                          vlaueKey: 'TaskDescription',
                          contrller: _descriptionController,
                          enabled: true,
                          fct: () {},
                          maxLength: 1000),
                      textsWidget(textLabel: 'Task Deadline date'),
                      _textFormFields(
                          vlaueKey: 'DeadlineDate',
                          contrller: _deadlineDateController,
                          enabled: false,
                          fct: () {
                            _pickDate();
                          },
                          maxLength: 100),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : MaterialButton(
                                  onPressed: () {
                                    uploadFct();
                                  },
                                  color: Colors.pink.shade700,
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    side: BorderSide.none,
                                  ),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14.0),
                                          child: Text(
                                            'Upload',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.upload_file,
                                          color: Colors.white,
                                        ),
                                      ]),
                                ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                    ],
                  ))
            ],
          )),
        ),
      ),
    );
  }

  void _pickDate() async {
    picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(Duration(days: 0)),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        _deadlineDateTimeStamp = Timestamp.fromMicrosecondsSinceEpoch(
            picked!.microsecondsSinceEpoch);
        _deadlineDateController.text =
            '${picked!.year}-${picked!.month}-${picked!.day}';
      });
    }
  }

  textsWidget({String? textLabel}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        textLabel!,
        style: TextStyle(
          fontSize: 18,
          color: Colors.pink.shade800,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void showTaskCategoryDialog(size) {
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
                        _categoryController.text =
                            Constants.taskCategoryList[index];
                      });
                      Navigator.pop(context);
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
            ],
          );
        });
  }

  _textFormFields({
    required String vlaueKey,
    required TextEditingController contrller,
    required bool enabled,
    required Function fct,
    required int maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          fct();
        },
        child: TextFormField(
          controller: contrller,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Field is missing';
            }
            return null;
          },
          enabled: enabled,
          key: ValueKey(vlaueKey),
          style: TextStyle(
            color: Constants.darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
          maxLines: vlaueKey == 'TaskDescription' ? 3 : 1,
          maxLength: maxLength,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
              color: Colors.white,
            )),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
              color: Colors.red,
            )),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
              color: Colors.pink.shade800,
            )),
            // focusedErrorBorder:OutlineInputBorder(
            //     borderSide: BorderSide(
            //   color: Colors.red,
            // )),
          ),
        ),
      ),
    );
  }
}
