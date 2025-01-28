// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:library_management/Commons/HomeScreen.dart';
import 'package:library_management/Commons/bookCategory.dart';
import 'package:library_management/firebase/Shared_Preferences.dart';
import 'package:library_management/firebase/loggedInUserData.dart';
import 'package:library_management/utils/appConstants.dart';
import 'package:library_management/utils/colors.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:library_management/utils/custom_widgets/custom_widgets.dart';
import 'package:library_management/utils/custom_widgets/dailogs.dart';
import 'package:provider/provider.dart';

class BookDetail extends StatefulWidget {
  BookDetail({required this.vatData, super.key});
  var vatData;
  @override
  State<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  var generalAppUser;
  bool isAlreadyAssigned = false;
  @override
  void initState() {
    // TODO: implement initState
    generalAppUser =
        Provider.of<userDataProvider>(context, listen: false).loggedInUserData;
    super.initState();
    final vatDataMap = widget.vatData.data() as Map<String, dynamic>;
    isAlreadyAssigned =
        (vatDataMap['assignedTo'] as List).contains(generalAppUser['UID']);
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore fireStore = FirebaseFirestore.instance;

    assignMe() async {
      try {
        // Check if the widget is still mounted before proceeding.

        // Perform Firebase update to decrease pieces and assign the book to the user.
        await fireStore.collection("books").doc(widget.vatData.id).update({
          'pieces': widget.vatData['pieces'] - 1,
          'assignedTo': FieldValue.arrayUnion([generalAppUser['UID']])
        }).then((value) async {
          // Update the user with the number of books issued.
          await fireStore
              .collection(ALLUSERS)
              .doc(generalAppUser['UID'])
              .update({
            'Books_Issued': generalAppUser['Books_Issued'] + 1
          }).then((value) async {
            // Save the updated number of books issued in SharedPreferences.
            SharedPreferenceHelper sp = SharedPreferenceHelper();
            sp.saveBooksIssued(generalAppUser['Books_Issued'] + 1);

            // Prepare book information for user's issued books collection.
            Map<String, dynamic> bookInfo = {
              "title": widget.vatData['title'],
              "issued_on": DateTime.now().toString().split(' ')[0],
              "return_Date": DateTime.now()
                  .add(Duration(days: 5))
                  .toString()
                  .split(' ')[0],
              "author": widget.vatData['author'],
              "image": widget.vatData['image'],
              "category": widget.vatData['category'],
            };

            // Add the book to the user's issued books collection.
            await fireStore
                .collection(ALLUSERS)
                .doc(generalAppUser['UID'])
                .collection("Issued_Books")
                .doc(widget.vatData.id)
                .set(bookInfo);
            fireStore.collection('payments').add({
              'UID': generalAppUser['UID'],
              'paidby': generalAppUser['email'],
              'amount': 20,
              'reason': 'Security Fee',
              'time': DateTime.now(),
            });
            // Update the logged-in user's data in the provider.
            Map<dynamic, dynamic> loggedInUserData = {
              'email': generalAppUser["email"],
              'name': generalAppUser['name'],
              'phone': generalAppUser['phone'],
              'UID': generalAppUser['UID'],
              'profileUrl': generalAppUser['profileUrl'],
              'Books_Issued': (generalAppUser['Books_Issued'] + 1),
              'fine': generalAppUser['fine']
            };
            Provider.of<userDataProvider>(context, listen: false)
                .saveUser(loggedInUserData);

            // Record the security fee payment in Firestore.

            showSnackBarMsg(context, "Book Issued");
          });
        });
      } catch (e) {
        print(e);
      }
    }

    void _assignMe() {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("Security Fee"),
                content: const Text(
                    "You need to pay the security fee before issuing this book i.e 20 Rs."),
                actions: <Widget>[
                  TextButton(
                    child: Text("No"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text("Yes"),
                    onPressed: () {
                      assignMe();
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookCategories()),
                      );
                    },
                  ),
                ],
              ));
    }

    return Scaffold(
      appBar: AppBar(
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
        title: Text(
          'Book Details',
          style: TextStyle(
              color: Colors.white,
              fontFamily: 'Itim-Regular',
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFFFDEE9BF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, right: 10, left: 10, bottom: 15),
              child: Row(
                children: [
                  Column(
                    children: [
                      Image.network(
                        widget.vatData['image'],
                        height: 120,
                        width: 120,
                      )
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Text(
                          widget.vatData['title'].toString(),
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontFamily: ' Itim-Regular',
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          children: [
                            Text(
                              "Author : ",
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Itim-Regular',
                              ),
                            ),
                            Text(
                              widget.vatData['author'].toString(),
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Itim-Regular',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7.0),
              child: Divider(
                thickness: 4,
                color: MyColors.MATERIAL_LIGHT_GREEN,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5),
              child: Row(
                children: [
                  Text(
                    'Details',
                    style: TextStyle(
                      fontFamily: ' Itim-Regular',
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 3.0, horizontal: 25),
              child: Row(
                children: [
                  Text(
                    "Category : ",
                    style: TextStyle(
                      fontFamily: ' Itim-Regular',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.vatData['category'],
                    style: TextStyle(
                      fontFamily: ' Itim-Regular',
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 3.0, horizontal: 25),
              child: Row(
                children: [
                  Text(
                    'Pieces : ',
                    style: TextStyle(
                      fontFamily: ' Itim-Regular',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.vatData['pieces'].toString(),
                    style: TextStyle(
                      fontFamily: ' Itim-Regular',
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5),
              child: Row(
                children: [
                  Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: ' Itim-Regular',
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 3.0, horizontal: 25),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.vatData['description'].toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 15,
                      softWrap: false,
                      style: TextStyle(
                        fontFamily: ' Itim-Regular',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
              child: InkWell(
                onTap: (() async {
                  if (isAlreadyAssigned == false) {
                    if (generalAppUser['Books_Issued'] != ADMIN_EMAIL) {
                      CustomProgressIndicatorDialog(context: context);
                      if (widget.vatData['pieces'] == 0) {
                        showSnackBarMsg(context,
                            "The Book ${widget.vatData['title']} is not available");
                      } else {
                        if (generalAppUser['Books_Issued'] >= 5) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BookCategories()),
                          );
                          showSnackBarMsg(
                              context, "You already have exceeded the limit");
                        } else {
                          _assignMe();
                        }
                      }
                    }
                  } else {
                    showSnackBarMsg(context, "Book Already Issued");
                  }
                }),
                child: Container(
                  decoration: BoxDecoration(
                      color: MyColors.MATERIAL_LIGHT_GREEN,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isAlreadyAssigned ? "Already Issued" : "Issue Me",
                            style: TextStyle(
                                fontFamily: ' Itim-Regular',
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                          ),
                          Icon(Icons.arrow_forward_ios)
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
