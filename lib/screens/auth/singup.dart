import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/constants.dart';
import '../../services/global_methods.dart';

class SingUpScreen extends StatefulWidget {
  const SingUpScreen({Key? key}) : super(key: key);

  @override
  State<SingUpScreen> createState() => _SingUpScreenState();
}

class _SingUpScreenState extends State<SingUpScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late TextEditingController _fullNameTextController =
      TextEditingController(text: '');
  late TextEditingController _emailTextController =
      TextEditingController(text: '');
  late TextEditingController _passTextController =
      TextEditingController(text: '');
  late TextEditingController _phoneTextController =
      TextEditingController(text: '');
  late TextEditingController _positionCPTextController =
      TextEditingController(text: '');

  FocusNode _fullNameFocusNode = FocusNode();
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  FocusNode _phoneFocusNode = FocusNode();
  FocusNode _positionFocusNode = FocusNode();

  bool _obscureText = true;
  final _SingUpFormKey = GlobalKey<FormState>();
  File? imageFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? url;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _fullNameTextController.dispose();
    _animationController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _phoneTextController.dispose();
    _positionCPTextController.dispose();
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _phoneFocusNode.dispose();
    _positionFocusNode.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 20));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((animationStatus) {
            if (animationStatus == AnimationStatus.completed) {
              _animationController.reset();
              _animationController.forward();
            }
          });
    _animationController.forward();
  }

  void submitFormOnSingUp() async {
    final isValid = _SingUpFormKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      if (imageFile == null) {
        GlobalMethods.showErrorDialog(
            error: 'Please pick up an image', context: context);
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        await _auth.createUserWithEmailAndPassword(
            email: _emailTextController.text.toLowerCase().trim(),
            password: _passTextController.text.trim());
        final User? user = _auth.currentUser;
        final _uid = user!.uid;
        final ref = FirebaseStorage.instance
            .ref()
            .child('userImages')
            .child(_uid + '.jpg');
        await ref.putFile(imageFile!);
        url = await ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('users').doc(_uid).set({
          'id': _uid,
          'name': _fullNameTextController.text,
          "email": _emailTextController.text,
          'userImageUrl': url,
          'phoneNumber': _phoneTextController.text,
          'positionInCompany': _positionCPTextController.text,
          'createdAt': Timestamp.now(),
        });
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      } catch (error) {
        setState(() {
          _isLoading = false;
        });

        GlobalMethods.showErrorDialog(
            error: error.toString(), context: context);
        print('error occyred $error');
      }
    } else {
      setState(() {
        _isLoading = false;
      });

      print('form not valid');
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Stack(
      children: [
        CachedNetworkImage(
          imageUrl:
              "https://wathefty.com/jobs/wp-content/uploads/2022/09/pexels-aleksandar-pasaric-2044434.jpg",
          placeholder: (context, url) =>
              Image.asset('assets/images/wallpaper.jpg', fit: BoxFit.fill),
          errorWidget: (context, url, error) => Icon(Icons.error),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          alignment: FractionalOffset(_animation.value, 0),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView(
            children: [
              SizedBox(
                height: size.height * 0.1,
              ),
              Text(
                'Register',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 9,
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'Already have an account?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '   '),
                  TextSpan(
                    text: 'Login',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SingUpScreen())),
                    style: TextStyle(
                        color: Colors.blue.shade300,
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ]),
              ),
              SizedBox(
                height: size.height * 0.05,
              ),
              Form(
                key: _SingUpFormKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            focusNode: _fullNameFocusNode,
                            onEditingComplete: () => FocusScope.of(context)
                                .requestFocus(_emailFocusNode),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Field can\'t be missing';
                              }
                              return null;
                            },
                            controller: _fullNameTextController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Full name',
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.pink.shade700),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                            child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: size.width * 0.24,
                                height: size.width * 0.24,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(16)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: imageFile == null
                                      ? Image.network('', fit: BoxFit.fill)
                                      : Image.file(imageFile!,
                                          fit: BoxFit.fill),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () {
                                  _showImageDialog();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.pink,
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.white,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      imageFile == null
                                          ? Icons.add_a_photo
                                          : Icons.edit_outlined,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ))
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      focusNode: _emailFocusNode,
                      onEditingComplete: () => FocusScope.of(context)
                          .requestFocus(_passwordFocusNode),
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Please enter a valid Email address';
                        }
                        return null;
                      },
                      controller: _emailTextController,
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink.shade700),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    //password textfield
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      focusNode: _passwordFocusNode,
                      onEditingComplete: () =>
                          FocusScope.of(context).requestFocus(_phoneFocusNode),
                      validator: (value) {
                        if (value!.isEmpty || value.length < 7) {
                          return 'Please enter a valid password';
                        }
                        return null;
                      },
                      obscureText: _obscureText,
                      controller: _passTextController,
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                          ),
                        ),
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink.shade700),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      focusNode: _phoneFocusNode,
                      onEditingComplete: () => FocusScope.of(context)
                          .requestFocus(_positionFocusNode),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Field can\'t be missing';
                        }
                        return null;
                      },
                      onChanged: (v) {},
                      controller: _phoneTextController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Phone number',
                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink.shade700),
                        ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    GestureDetector(
                      onTap: () {
                        showJobsDialog(size);
                      },
                      child: TextFormField(
                        enabled: false,
                        textInputAction: TextInputAction.done,
                        focusNode: _positionFocusNode,
                        onEditingComplete: submitFormOnSingUp,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Field can\'t be missing';
                          }
                          return null;
                        },
                        controller: _positionCPTextController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Position in the company',
                          hintStyle: TextStyle(color: Colors.white),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.pink.shade700),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              SizedBox(
                height: 40,
              ),
              _isLoading
                  ? Center(
                      child: Container(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : MaterialButton(
                      onPressed: () {
                        submitFormOnSingUp();
                      },
                      color: Colors.pink.shade700,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                        side: BorderSide.none,
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14.0),
                              child: Text(
                                'Register',
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
                              Icons.person_add,
                              color: Colors.white,
                            ),
                          ]),
                    ),
            ],
          ),
        ),
      ],
    ));
  }

  void _pickImageWithCamera() async {
    try {
      PickedFile? pickedFile = await ImagePicker().getImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      // setState(() {
      //   imageFile = File(pickedFile!.path);
      // });
      _cropImage(pickedFile!.path);
    } catch (error) {
      GlobalMethods.showErrorDialog(error: '$error', context: context);
    }

    Navigator.pop(context);
  }

  void _pickImageWithGallery() async {
    try {
      PickedFile? pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      // setState(() {
      //   imageFile = File(pickedFile!.path);
      // });
      _cropImage(pickedFile!.path);
    } catch (error) {
      GlobalMethods.showErrorDialog(error: '$error', context: context);
    }
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    File? cropImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    if (cropImage != null) {
      setState(() {
        imageFile = cropImage;
      });
    }
  }

  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Please choose an option'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              InkWell(
                onTap: _pickImageWithCamera,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.camera,
                        color: Colors.purple,
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Text('Camera',
                          style: TextStyle(
                            color: Colors.purple,
                          ))
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: _pickImageWithGallery,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.image,
                        color: Colors.purple,
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      Text('Gallery',
                          style: TextStyle(
                            color: Colors.purple,
                          ))
                    ],
                  ),
                ),
              ),
            ]),
          );
        });
  }

  void showJobsDialog(size) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Jobs',
              style: TextStyle(
                color: Colors.pink.shade300,
                fontSize: 20,
              ),
            ),
            content: Container(
              width: size.width * 0.9,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Constants.jobsList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _positionCPTextController.text =
                            Constants.jobsList[index];
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
                            Constants.jobsList[index],
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
                onPressed: () {},
                child: Text('Cancel filter'),
              ),
            ],
          );
        });
  }
}
