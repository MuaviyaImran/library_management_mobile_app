// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:library_management/Commons/splash_page.dart';
import 'package:library_management/firebase/loggedInUserData.dart';
import 'package:library_management/utils/appConstants.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      name: 'library-management',
      options: const FirebaseOptions(
          apiKey: "AIzaSyAuOUzr-QnlGx8BWtJ9vf_amo-ArEsxQu0",
          projectId: "library-management-a77aa",
          storageBucket: "library-management-a77aa.appspot.com",
          messagingSenderId: "646498086224",
          appId: "1:184614252379:android:1dd3cae1e377918763f47e0"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => userDataProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: APP_TITTLE,
        theme: ThemeData(primarySwatch: Colors.lightGreen),
        home: SplashPage(),
      ),
    );
  }
}
