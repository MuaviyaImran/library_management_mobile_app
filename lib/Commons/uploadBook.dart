// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:library_management/Commons/HomeScreen.dart';
import 'package:library_management/Commons/bottom_nav_bar.dart';
import 'package:library_management/firebase/loggedInUserData.dart';
import 'package:library_management/utils/colors.dart';
import 'package:library_management/utils/custom_widgets/custom_widgets.dart';
import 'package:library_management/utils/custom_widgets/dailogs.dart';
import 'package:library_management/utils/size_config.dart';
import 'package:provider/provider.dart';

class UploadBook extends StatefulWidget {
  const UploadBook({super.key});

  @override
  State<UploadBook> createState() => _UploadBookState();
}

class _UploadBookState extends State<UploadBook> {
  var generalAppUser;

  @override
  void initState() {
    // TODO: implement initState

    generalAppUser =
        Provider.of<userDataProvider>(context, listen: false).loggedInUserData;

    super.initState();
  }

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _authorController = TextEditingController();
  TextEditingController _piecesController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
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

  String? imgUrl;

  Future<String?> uploadImageToCloudinary(
    context,
  ) async {
    CustomProgressIndicatorDialog(context: context);
    try {
      const cloudName = 'dmmip8ojz'; // Replace with your Cloudinary cloud name
      const uploadPreset = 'library'; // Replace with your unsigned preset name

      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      // Prepare the request
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imgFile!.path));

      // Send the request
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final jsonResponse = json.decode(responseData.body);
        imgUrl = jsonResponse[
            'secure_url']; // The Cloudinary URL for the uploaded image
      } else {
        print('Image upload failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
    } finally {
      Navigator.pop(context); // Hide the progress indicator
    }

    return imgUrl;
  }

  ImagePicker imagePicker = ImagePicker();
  @override
  Widget build(BuildContext context) {
    MyAppSize.config(MediaQuery.of(context));
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
      ),
      appBar: AppBar(
        title: Text(
          "Upload a Book",
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
      body: SingleChildScrollView(
        child: leftAndRightPadding(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 50,
              ),
              Center(
                child: Image.asset(
                  "assets/images/add_blog_logo.png",
                  height: 120,
                  width: 120,
                ),
              ),
              SizedBox(
                height: 20,
              ),

              ///Add Title TextField
              Text(
                "Title",
                style: TextStyle(
                    fontFamily: ' Itim-Regular',
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyColors.GREEN40, width: 0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyColors.GREEN40, width: 0)),
                    hintText: "Book Title",
                    filled: true,
                    fillColor: MyColors.GREEN40),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Author",
                style: TextStyle(
                    fontFamily: ' Itim-Regular',
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyColors.GREEN40, width: 0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyColors.GREEN40, width: 0)),
                    hintText: "Book Author",
                    filled: true,
                    fillColor: MyColors.GREEN40),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Category",
                style: TextStyle(
                    fontFamily: ' Itim-Regular',
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyColors.GREEN40, width: 0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyColors.GREEN40, width: 0)),
                    hintText: "Book Category",
                    filled: true,
                    fillColor: MyColors.GREEN40),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Pieces",
                style: TextStyle(
                    fontFamily: ' Itim-Regular',
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: _piecesController,
                decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyColors.GREEN40, width: 0)),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: MyColors.GREEN40, width: 0)),
                    hintText: "No. of Books available",
                    filled: true,
                    fillColor: MyColors.GREEN40),
              ),
              SizedBox(
                height: 5,
              ),

              ///Add blog Content
              Text(
                "Book Description",
                style: TextStyle(
                    fontFamily: ' Itim-Regular',
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                color: MyColors.GREEN40,
                height: 170,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: TextFormField(
                    controller: _descController,
                    textAlign: TextAlign.start,
                    maxLines: 7,
                    maxLength: 1500,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: MyColors.GREEN40, width: 0)),
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: MyColors.GREEN40, width: 0)),
                      hintText: "Book Description",
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),

              ///Add Image
              Text(
                "Upload a picture",
                style: TextStyle(
                    fontFamily: ' Itim-Regular',
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () {
                  getImgFromGallery();
                },
                child: Container(
                  color: MyColors.GREEN40,
                  height: 100,
                  child: Center(
                    child: imgFile?.path == null
                        ? Icon(Icons.add_a_photo)
                        : Image(image: FileImage(imgFile!), fit: BoxFit.cover),
                  ),
                ),
              ),

              SizedBox(
                height: 20,
              ),
              MyButton(
                  onPressed: () async {
                    CustomProgressIndicatorDialog(context: context);
                    if (_descController.text.isNotEmpty &&
                        _titleController.text.isNotEmpty &&
                        _authorController.text.isNotEmpty &&
                        _categoryController.text.isNotEmpty &&
                        _piecesController.text.isNotEmpty &&
                        imgFile?.path != null) {
                      if (RegExp(r'^[0-9]+$')
                          .hasMatch(_piecesController.text)) {
                        uploadImageToCloudinary(context).then((value) {
                          if (imgUrl!.isNotEmpty) {
                            Map<String, dynamic> bookInfo = {
                              "title": _titleController.text,
                              "author": _authorController.text,
                              "createdOn": FieldValue.serverTimestamp(),
                              "image": imgUrl,
                              "pieces": int.tryParse(_piecesController.text),
                              "category": _categoryController.text,
                              "description": _descController.text,
                              "assignedTo": [],
                            };
                            FirebaseFirestore.instance
                                .collection("books")
                                .doc()
                                .set(bookInfo)
                                .then((value) => {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DashBoard()),
                                      )
                                    });
                          } else {
                            Navigator.pop(context);

                            showSnackBarMsg(context, "Something went wrong");
                          }
                        });
                      } else {
                        Navigator.pop(context);

                        showSnackBarMsg(context, "Invalid Number of books");
                      }
                    } else {
                      Navigator.pop(context);

                      showSnackBarMsg(context, "Empty Fields Found");
                    }
                  },
                  title: "Upload Book",
                  color: MyColors.GREEN_LIGHT_SHADE,
                  textColor: Colors.black,
                  borderRadius: 0)
            ],
          ),
        ),
      ),
    );
  }
}
