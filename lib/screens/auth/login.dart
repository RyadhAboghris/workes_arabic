import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:workes_arabic/screens/auth/forget_password.dart';
import 'package:workes_arabic/screens/auth/singup.dart';

import '../../services/global_methods.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late TextEditingController _emailTextController =
      TextEditingController(text: '');
  late TextEditingController _passTextController =
      TextEditingController(text: '');

  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();

  bool _obscureText = true;
  final _loginFormKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController.dispose();
    _emailTextController.dispose();
    _passTextController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
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

  void submitFormOnlogin() async {
    final isValid = _loginFormKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _auth.signInWithEmailAndPassword(
            email: _emailTextController.text.toLowerCase().trim(),
            password: _passTextController.text.trim());
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
                'Login',
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
                    text: 'Don\'t have an account?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '   '),
                  TextSpan(
                    text: 'Register',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.push(
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
                key: _loginFormKey,
                child: Column(
                  children: [
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
                      textInputAction: TextInputAction.done,
                      focusNode: _passwordFocusNode,
                      onEditingComplete: submitFormOnlogin,
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
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgetPasswordScreen()));
                  },
                  child: Text(
                    'Forget password',
                    style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              _isLoading
                  ? Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : MaterialButton(
                      onPressed: () {
                        submitFormOnlogin();
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
                                'Login',
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
                              Icons.login,
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
}
