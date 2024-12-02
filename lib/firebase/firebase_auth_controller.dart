import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:library_management/utils/custom_widgets/custom_widgets.dart';
import 'package:library_management/utils/custom_widgets/dailogs.dart';

String? uid;

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
