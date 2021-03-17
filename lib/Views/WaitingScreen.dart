import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WaitingScreen extends StatelessWidget {
  adjustStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark),
    );
  }

  @override
  Widget build(BuildContext context) {
    adjustStatusBar();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 30,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "notarized",
                          style: TextStyle(
                              color: Colors.yellow.shade600,
                              fontSize: 50,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "docs",
                          style: TextStyle(
                              color: Colors.blue.shade800,
                              fontSize: 50,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Text(
                        "Pays Attention to the smallest Details.",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 160,
                    width: 160,
                    child: Image.asset(
                      "assets/quality.png",
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Pending Approval",
                    style: TextStyle(
                        fontSize: 16.5,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 13,
                  ),
                  Text(
                    "We will notify you once your account is live.",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "In case of any query, please write to us.",
                    style: TextStyle(
                        fontSize: 15, color: Colors.black.withOpacity(0.7)),
                  ),
                  Text(
                    "support@notarizeddocs.com",
                    style: TextStyle(
                        fontSize: 15, color: Colors.black.withOpacity(0.7)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
