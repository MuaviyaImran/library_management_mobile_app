import 'package:flutter/material.dart';
import 'package:library_management/utils/colors.dart';
import 'package:library_management/utils/custom_widgets/custom_widgets.dart';
import 'package:library_management/utils/responsive_controller.dart';
import 'package:library_management/utils/size_config.dart';

import '../../firebase/firebase_auth_controller.dart' as firebase_auth;

TextEditingController resetPasswordEmailController = TextEditingController();

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  @override
  Widget build(BuildContext context) {
    MyAppSize.config(MediaQuery.of(context));
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: MyColors.MATERIAL_LIGHT_GREEN,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Responsive(
        mobile: mobile(context),
        tablet: tabletUI(),
        web: webUI(),
      ),
    );
  }

  ///MOBILE
  Widget mobile(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MyAppSize.width,
          child: Image(
            image: AssetImage("assets/images/rectDesign.png"),
            alignment: Alignment.topRight,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
              left: MyAppSize.width! * 0.05, right: MyAppSize.width! * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                  width: 90,
                  height: 80,
                  image: AssetImage("assets/images/lock.png")),
              SizedBox(
                height: 20,
              ),
              Text(
                "Forgot Your Password?",
                style: TextStyle(
                    fontFamily: ' Itim-Regular',
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Enter Your Email Bellow To Reset Your Password",
                style: TextStyle(
                  fontFamily: ' Itim-Regular',
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 50,
              ),
              TextField(
                controller: resetPasswordEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: textFieldDecorationWithIcon(
                    hint: "Enter Your Email", icon: Icons.voicemail),
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    minWidth: 193,
                    height: 39,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      firebase_auth.senResetPasswordLink(
                          context: context,
                          email: resetPasswordEmailController.text);
                    },
                    textColor: Colors.black,
                    child: Text(
                      "Submit",
                      style: TextStyle(
                          fontFamily: ' Itim-Regular',
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    color: MyColors.MATERIAL_LIGHT_GREEN,
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
