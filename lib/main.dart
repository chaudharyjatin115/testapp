import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:myknott/Services/Services.dart';
import 'package:myknott/Services/auth.dart';
import 'package:myknott/Screens/NoInternetScreen.dart';
import 'package:myknott/Views/homePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Config/CustomColors.dart';
import 'Views/home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   if (message.data['type'] == 1 || message.data['type'] == '1') {
//     if (message.data['action'] == 'revoked') {
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.clear();
//       FirebaseAuth.instance.signOut();
//     }
//   }
//   return Future<void>.value();
// }

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage m) {
  return Future<void>.value();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isInternet = true;
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    isInternet = false;
  } else {
    await Firebase.initializeApp();
    try {
      await NotaryServices().getToken();
    } catch (e) {}
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    var messaging = FirebaseMessaging.instance;
    try {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    } catch (e) {
      print("errror Meseg :" + e.toString());
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {}
    });
  }

  runApp(MyApp(
    isInternet: isInternet,
  ));
}

class MyApp extends StatelessWidget {
  final bool isInternet;

  const MyApp({Key key, @required this.isInternet}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Notary App',
      theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          accentColor: Colors.white,
          primarySwatch: CustomColor().appBarColor,
          fontFamily: "Whitney"),
      home: isInternet ? HomeScreen() : NoInternetScreen(),
      builder: EasyLoading.init(),
    );
  }
}
