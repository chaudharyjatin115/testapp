// import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myknott/Config/CustomColors.dart';
import 'package:myknott/Services/Services.dart';
import 'package:myknott/Views/AuthScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'homePage.dart';
import 'package:linkify/linkify.dart';

class UserProfile extends StatefulWidget {
  final String notaryId;

  const UserProfile({Key key, this.notaryId}) : super(key: key);
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with AutomaticKeepAliveClientMixin<UserProfile> {
  Map userInfo = {};
  final Color blueColor = CustomColor().blueColor;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    userInfo = await NotaryServices().getUserProfileInfo(notaryId); //notaryId

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print("user info 41 userprofile ");
    loginUserInfo.forEach((k, v) => print("key :$k, value :$v\n"));
    return Scaffold(
        backgroundColor: Colors.white,
        body: loginUserInfo.isNotEmpty
            ? SingleChildScrollView(
                child: SafeArea(
                child: Container(
                  // color: Colors.amberAccent,
                  height: MediaQuery.of(context).size.height - 80,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                "assets/userr.png",
                                height: 80,
                                width: 80,
                              ),
                              //  CachedNetworkImage(
                              //   imageUrl: loginUserInfo['photoURL'],
                              //   width: 80,
                              //   height: 80,
                              // )

                              //  Image.network(
                              //   loginUserInfo['photoURL'],
                              //   width: 80,
                              //   height: 80,
                              // )
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              loginUserInfo["username"] + " ",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                          ])),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          // color: Colors.amberAccent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "First Name",
                                style: TextStyle(fontSize: 16.5),
                              ),
                              TextFormField(
                                enabled: false,
                                decoration: InputDecoration(
                                    disabledBorder: InputBorder.none),
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                                initialValue: loginUserInfo['firstName'],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Email",
                                style: TextStyle(fontSize: 16.5),
                              ),
                              TextFormField(
                                enabled: false,
                                decoration: InputDecoration(
                                    disabledBorder: InputBorder.none),
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                                initialValue: loginUserInfo['email'],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              MaterialButton(
                                height: 40,
                                hoverElevation: 0,
                                focusElevation: 0,
                                highlightElevation: 0,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                onPressed: () async {
                                  SharedPreferences res =
                                      await SharedPreferences.getInstance();
                                  res.clear();
                                  await FlutterSecureStorage().deleteAll();
                                  FirebaseAuth.instance.signOut();
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration: Duration(seconds: 0),
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          AuthScreen(),
                                    ),
                                  );
                                },
                                color: Colors.yellow,
                                child: Center(
                                  child: Text(
                                    "Logout",
                                    style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Linkify(
                                onOpen: _onOpen,
                                text:
                                    "Note: To edit other details, Please log in from your webbrowser. visit www.notarizeddocs.com/notary",
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ))
            : Center(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 17,
                      width: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Please Wait ...",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ));
  }
  //

  @override
  bool get wantKeepAlive => true;
}

Future<void> _onOpen(LinkableElement link) async {
  if (await canLaunchUrl(Uri.parse(link.url))) {
    await launchUrl(Uri.parse(link.url));
  } else {
    print("Could not launch url 203 userProfile");
  }
}
