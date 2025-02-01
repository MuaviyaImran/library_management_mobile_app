import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:library_management/firebase/Shared_Preferences.dart';
import 'package:library_management/Commons/HomeScreen.dart';
import 'package:library_management/Commons/login_page.dart';
import 'package:library_management/firebase/DataBase.dart';
import 'package:library_management/firebase/loggedInUserData.dart';
import 'package:library_management/utils/appConstants.dart';
import 'package:library_management/utils/colors.dart';
import 'package:library_management/utils/custom_widgets/custom_widgets.dart';
import 'package:library_management/utils/custom_widgets/dailogs.dart';
import 'package:provider/provider.dart';

String? uid;
final FirebaseAuth _auth = FirebaseAuth.instance;

SharedPreferenceHelper sharedPreferences = SharedPreferenceHelper();

///Firebase Signup with Email and Password
Future<String> signUp(
    {required BuildContext context,
    required String email,
    required String name,
    required String password,
    required String phone,
    required String studentId}) async {
  CustomProgressIndicatorDialog(context: context);
  String response = "";
  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? user = result.user;

    if (user != null) {
      user.sendEmailVerification().whenComplete(() async {
        Map<String, dynamic> userInfoMap = {
          "email": email,
          "name": name,
          "createdOn": DateTime.now(),
          "uid": user.uid,
          "phone": phone,
          "studentId": studentId.toUpperCase(),
          "Books_Issued": 0,
          "fine": 0,
          "profileUrl":
              'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
        };

        DatabaseMethods()
            .addUserInfoToDBGoogle(user.uid, userInfoMap)
            .then((value) {
          Navigator.pop(context);

          showSnackBarMsg(
              context, "Account Created.Please Check Your E-mail to verify");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        });
      });
    } else {
      Navigator.of(context).pop();
    }
  } on FirebaseAuthException catch (e) {
    response = e.code;
    Navigator.of(context).pop();
  } catch (e) {
    Navigator.of(context).pop();
  }

  return response;
}

///Firebase Login with Email and Password
Future<String> login(
    {required context, required String email, required String password}) async {
  String response = "";

  try {
    CustomProgressIndicatorDialog(context: context);
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    User? user = userCredential.user;
    if (user != null && user.emailVerified) {
      SharedPreferenceHelper sp = SharedPreferenceHelper();
      DocumentSnapshot<Map<String, dynamic>> data = await FirebaseFirestore
          .instance
          .collection(ALLUSERS)
          .doc(user.uid)
          .get();
      var u = data.data();
      sp.saveUserName(u!['name']);
      sp.savePhone(u['phone'].toString());
      sp.saveUId(user.uid);
      sp.saveUserEmail(u["email"]);
      sp.savePic(u['profileUrl']);
      sp.saveBooksIssued(u['Books_Issued']);
      sp.saveFine(u['fine']);
      Map<dynamic, dynamic> loggedInUserData = {
        'email': u["email"],
        'name': u['name'],
        'phone': u['phone'],
        'UID': user.uid,
        'profileUrl': u['profileUrl'],
        'Books_Issued': u['Books_Issued'],
        'fine': u['fine']
      };
      Provider.of<userDataProvider>(context, listen: false)
          .saveUser(loggedInUserData);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DashBoard()));
    } else if (user != null && user.emailVerified == false) {
      Navigator.pop(context);
      showDialog(
          barrierDismissible: false,
          useSafeArea: true,
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.white,
              alignment: Alignment.center,
              child: Container(
                height: 200,
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 40,
                      color: MyColors.MATERIAL_LIGHT_GREEN,
                      child: Center(
                        child: Text(
                          "Email verification",
                          style: TextStyle(
                              fontFamily: ' Itim-Regular',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    Center(
                      child: leftAndRightPadding(
                        child: Text(
                          "Dear user,Your Email is not verified please check your Email and verify it.\n If you don't receive Email or Email link is expired, click on re-send link button to get new verification link",
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: MyButton(
                                borderRadius: 0,
                                height: 40,
                                fontFamily: ' Itim-Regular',
                                fontSize: 12,
                                onPressed: () {
                                  user.sendEmailVerification().whenComplete(() {
                                    Navigator.pop(context);
                                    showSnackBarMsg(context,
                                        "Email verification link send successfully.");
                                  });
                                },
                                title: "Re-Send Link",
                                color: MyColors.MATERIAL_LIGHT_GREEN,
                                textColor: Colors.white),
                          ),
                          Expanded(
                            child: MyButton(
                                borderRadius: 0,
                                height: 40,
                                fontFamily: ' Itim-Regular',
                                fontSize: 12,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                title: "Cancel",
                                color: MyColors.MATERIAL_LIGHT_GREEN,
                                textColor: Colors.white),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          });
    }
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context);
    showSnackBarMsg(context, e.code, error: true);
  } catch (e) {
    Navigator.pop(context);
    showSnackBarMsg(context, e.toString(), error: true);
  }

  return response;
}

/// Reset Password
String senResetPasswordLink(
    {required String email, required BuildContext context}) {
  CustomProgressIndicatorDialog(context: context);
  try {
    FirebaseAuth.instance.sendPasswordResetEmail(email: email).whenComplete(() {
      Navigator.pop(context);
      showSnackBarMsg(context, "Password resend link send");
    });
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context);
    showSnackBarMsg(context, e.code, error: true);
  } catch (e) {
    Navigator.pop(context);
    showSnackBarMsg(context, e.toString(), error: true);
  }

  return "";
}
