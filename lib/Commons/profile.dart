// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:library_management/Commons/HomeScreen.dart';
import 'package:library_management/Commons/bottom_nav_bar.dart';
import 'package:library_management/Commons/signup_page.dart';
import 'package:library_management/firebase/loggedInUserData.dart';
import 'package:library_management/utils/appConstants.dart';
import 'package:library_management/utils/colors.dart';
import 'package:library_management/utils/custom_widgets/custom_widgets.dart';
import 'package:library_management/utils/custom_widgets/dailogs.dart';
import 'package:library_management/utils/form_validation_controller.dart';
import 'package:library_management/utils/myTextField.dart';
import 'package:library_management/utils/responsive_controller.dart';
import 'package:library_management/utils/size_config.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  var generalAppUser;

  File? imgFile;
  getImgFromGallery() async {
    try {
      var pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        imgFile = File(pickedFile!.path);
      });
    } catch (e) {
      print("Image Picker Error : ${e.toString()}");
    }
  }

  FirebaseStorage _storage = FirebaseStorage.instance;
  String? imgUrl;
  Future<String?> uploadImageToFireStore(context) async {
    CustomProgressIndicatorDialog(context: context);
    try {
      Reference storageRef = _storage.ref().child(
          "Profile_pictures/${imgFile!.path.substring(imgFile!.path.lastIndexOf('/') + 1)}");
      UploadTask uploadTask = storageRef.putFile(imgFile!);
      await uploadTask.then((e) async {
        await e.ref.getDownloadURL().then((value) {
          imgUrl = value;
        });
      });
    } catch (e) {
      print(e.toString());
    }
    return imgUrl;
  }

  ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState

    generalAppUser =
        Provider.of<userDataProvider>(context, listen: false).loggedInUserData;
    usernameController.text = generalAppUser['name'];
    emailController.text = generalAppUser['email'];
    phoneController.text = generalAppUser['phone'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MyAppSize.config(MediaQuery.of(context));
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2,
      ),
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
              fontSize: 19, color: Colors.white, fontFamily: 'Itim-Regular'),
        ),
        centerTitle: true,
        actionsIconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashBoard()),
                );
              },
              icon: Icon(Icons.home))
        ],
        elevation: 0,
        backgroundColor: MyColors.MATERIAL_LIGHT_GREEN,
      ),
      drawer: drawer(context, generalAppUser),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            InkWell(
              onTap: () {
                getImgFromGallery();
              },
              child: generalAppUser['profileUrl'] == ''
                  ? CircleAvatar(
                      radius: 60, // Increased size from 42 to 60
                      backgroundImage: AssetImage(NOIMAGE),
                    )
                  : CircleAvatar(
                      radius: 60, // Increased size from 42 to 60
                      backgroundImage:
                          NetworkImage(generalAppUser['profileUrl']),
                    ),
            ),
            if (imgFile != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Profile Picture Picked',
                  style: TextStyle(
                      fontFamily: ' Itim-Regular',
                      color: Colors.red,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
            MyTextField("Name", usernameController, false, false, context),
            MyTextField("Email", emailController, false, true, context),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                width: MediaQuery.of(context).size.width - 70,
                height: 75,
                child: TextFormField(
                  controller: phoneController,
                  obscureText: false,
                  readOnly: false,
                  maxLength: 10,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontFamily: ' Itim-Regular',
                  ),
                  decoration: InputDecoration(
                      labelText: 'Phone',
                      labelStyle: TextStyle(fontSize: 17, color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                              width: 1.5,
                              color: MyColors.MATERIAL_LIGHT_GREEN)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                              width: 2, color: MyColors.MATERIAL_LIGHT_GREEN))),
                ),
              ),
            ),
            if (generalAppUser['fine'] != 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "You Have total fine of Rs.${generalAppUser['fine'].toString()}",
                      style: TextStyle(
                          fontFamily: ' Itim-Regular',
                          color: Colors.red,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 35.0, vertical: 15),
              child: InkWell(
                onTap: () {
                  CustomProgressIndicatorDialog(context: context);
                  uploadImageToFireStore(context).then((value) async {
                    try {
                      await fireStore
                          .collection(ALLUSERS)
                          .doc(generalAppUser["UID"])
                          .update({
                        'name': usernameController.text,
                        'phone': phoneController.text,
                        'profileUrl': imgUrl != null
                            ? imgUrl
                            : generalAppUser["profileUrl"]
                      }).whenComplete(() {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DashBoard()));
                        showSnackBarMsg(context, "Profile Updated");
                      });
                    } on FirebaseAuthException catch (e) {
                      Navigator.pop(context);
                      showSnackBarMsg(context, e.code, error: true);
                    } catch (e) {
                      Navigator.pop(context);
                      showSnackBarMsg(context, e.toString(), error: true);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: MyColors.MATERIAL_LIGHT_GREEN,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Update Profile",
                            style: TextStyle(
                                fontFamily: ' Itim-Regular',
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 35.0, vertical: 15),
              child: InkWell(
                onTap: () {
                  CustomProgressIndicatorDialog(context: context);
                  try {
                    FirebaseAuth.instance
                        .sendPasswordResetEmail(email: emailController.text)
                        .whenComplete(() {
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
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: MyColors.MATERIAL_LIGHT_GREEN,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Change Password",
                            style: TextStyle(
                                fontFamily: ' Itim-Regular',
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
