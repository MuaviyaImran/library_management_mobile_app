// ignore_for_file: use_build_context_synchronously, prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:library_management/Commons/HomeScreen.dart';
import 'package:library_management/Commons/login_page.dart';
import 'package:library_management/firebase/loggedInUserData.dart';
import 'package:library_management/utils/size_config.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  var UID;
  getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UID = prefs.getString("UID");
    if (UID != null) {
      Map<dynamic, dynamic> loggedInUserData = {
        'email': prefs.getString("USEREMAILKEY"),
        'name': prefs.getString("USERNAMEKEY"),
        'phone': prefs.getString("USERPHONE"),
        'UID': prefs.getString("UID"),
        'profileUrl': prefs.getString('PROFILEPIC'),
        'Books_Issued': prefs.getInt('Books_Issued'),
        'fine': prefs.getInt('FINE'),
      };
      Provider.of<userDataProvider>(context, listen: false)
          .saveUser(loggedInUserData);
    }
  }

  @override
  void initState() {
    getPrefs();
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    Timer(Duration(seconds: 4), () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
        return UID != null ? DashBoard() : LoginScreen();
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData data = MediaQuery.of(context);
    MyAppSize.config(data);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("assets/images/logo_with_text.jpg"),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14.0),
              child: Text(
                "Lib Online System",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: ' Itim-Regular',
                  fontSize: 22,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
