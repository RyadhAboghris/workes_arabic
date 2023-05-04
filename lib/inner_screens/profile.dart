import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workes_arabic/constants/constants.dart';
import 'package:workes_arabic/services/global_methods.dart';

import '../user_state.dart';
import '../widgets/drawer_widget.dart';

class ProfileScreen extends StatefulWidget {
  final String userID;

  const ProfileScreen({required this.userID});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var titelTextStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.normal,
  );

  bool _isLoading = false;
  String phoneNumber = '';
  String email = '';
  String name = '';
  String job = '';
  String? imageUrl;
  String joinedAt = '';
  bool _isSameUser = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  void getUserData() async {
    _isLoading = true;
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .get();

      if (userDoc == null) {
        return;
      } else {
        setState(() {
          email = userDoc.get('email');
          name = userDoc.get('name');
          phoneNumber = userDoc.get('phoneNumber');
          job = userDoc.get('positionInCompany');
          imageUrl = userDoc.get('userImageUrl');
          Timestamp joinedAtTimestamp = userDoc.get('createdAt');
          var joinedDate = joinedAtTimestamp.toDate();
          joinedAt = '${joinedDate.year}-${joinedDate.month}-${joinedDate.day}';
        });
        User? user = _auth.currentUser;
        String _uid = user!.uid;
        setState(() {
          _isSameUser = _uid == widget.userID;
        });
      }
    } catch (error) {
      GlobalMethods.showErrorDialog(error: '$error', context: context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _isLoading
          ? Center(
              child: Text(
              'Fetching data',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ))
          : SingleChildScrollView(
              child: Center(
                child: Stack(
                  children: [
                    // SizedBox(height: 20,),
                    Card(
                      margin: EdgeInsets.all(30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 80,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(name, style: titelTextStyle),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '$job Since joined $joinedAt',
                                  style: TextStyle(
                                    color: Constants.darkBlue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Divider(
                                thickness: 1,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text('Contact Info', style: titelTextStyle),
                              SizedBox(
                                height: 20,
                              ),
                              socialInfo(label: 'Email', content: email),
                              SizedBox(
                                height: 10,
                              ),
                              socialInfo(
                                  label: 'Phone number', content: phoneNumber),
                              SizedBox(
                                height: 30,
                              ),
                              _isSameUser
                                  ? Container()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        socialButtons(
                                            color: Colors.green,
                                            icon: Icons.message_outlined,
                                            fct: () {
                                              _openWhatsAppChat();
                                            }),
                                        socialButtons(
                                            color: Colors.red,
                                            icon: Icons.mail_outline_outlined,
                                            fct: () {
                                              _mailTo();
                                            }),
                                        socialButtons(
                                            color: Colors.green,
                                            icon: Icons.call_outlined,
                                            fct: () {
                                              _callPhoneNumber();
                                            }),
                                      ],
                                    ),
                              SizedBox(
                                height: 20,
                              ),
                              _isSameUser
                                  ? Container()
                                  : Divider(
                                      thickness: 1,
                                    ),
                              SizedBox(
                                height: 20,
                              ),
                              !_isSameUser
                                  ? Container()
                                  : Center(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: MaterialButton(
                                          onPressed: () async {
                                            await _auth.signOut();
                                            Navigator.of(context)
                                                .pushReplacement(
                                                    MaterialPageRoute(
                                                        builder: (ctx) =>
                                                            UserState()));
                                          },
                                          color: Colors.pink.shade700,
                                          elevation: 10,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13),
                                            side: BorderSide.none,
                                          ),
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.logout,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 14.0),
                                                  child: Text(
                                                    'Logout',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ]),
                                        ),
                                      ),
                                    ),
                            ]),
                      ),
                    ),
                    Positioned(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: size.width * 0.26,
                            height: size.width * 0.26,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  width: 10,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                ),
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(
                                    imageUrl ?? '',
                                  ),
                                  fit: BoxFit.fill,
                                )),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  void _openWhatsAppChat() async {
    var url = 'https://wa.me/$phoneNumber?text=HelloWorld';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Error occured coulnd\'t open link';
    }
  }

  void _mailTo() async {
    var url = 'mailto:$email';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Error occured coulnd\'t open link';
    }
  }

  void _callPhoneNumber() async {
    var url = 'tel://$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Error occured coulnd\'t open link';
    }
  }

  Widget socialInfo({required String label, required String content}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            content,
            style: TextStyle(
              color: Constants.darkBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget socialButtons(
      {required Color color, required IconData icon, required Function fct}) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
        radius: 23,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(
            icon,
            color: color,
          ),
          onPressed: () {
            fct();
          },
        ),
      ),
    );
  }
}
