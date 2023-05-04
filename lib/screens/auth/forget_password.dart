import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:workes_arabic/screens/auth/singup.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late TextEditingController _forgetPasswordController =
      TextEditingController(text: '');

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController.dispose();
    _forgetPasswordController.dispose();
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

  void _forgetPasswordFCT() {}

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
                'Forget Password',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Email Address',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: TextField(
                  controller: _forgetPasswordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.pink.shade700),
                    ),
                    
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              MaterialButton(
                onPressed: () {
                  _forgetPasswordFCT();
                },
                color: Colors.pink.shade700,
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                  side: BorderSide.none,
                ),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Text(
                      'Reset now',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 10,
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
