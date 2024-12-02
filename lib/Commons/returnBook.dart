// ignore_for_file: prefer_const_constructors, unnecessary_brace_in_string_interps, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:library_management/Commons/HomeScreen.dart';
import 'package:library_management/Commons/bookDetail.dart';
import 'package:library_management/Commons/bottom_nav_bar.dart';
import 'package:library_management/firebase/loggedInUserData.dart';
import 'package:library_management/utils/appConstants.dart';
import 'package:library_management/utils/colors.dart';
import 'package:library_management/utils/custom_widgets/custom_widgets.dart';
import 'package:library_management/utils/custom_widgets/dailogs.dart';
import 'package:library_management/utils/size_config.dart';
import 'package:provider/provider.dart';

class ReturnBook extends StatefulWidget {
  const ReturnBook({super.key});

  @override
  State<ReturnBook> createState() => _ReturnBookState();
}

class _ReturnBookState extends State<ReturnBook> {
  var generalAppUser;
  @override
  void initState() {
    // TODO: implement initState

    generalAppUser =
        Provider.of<userDataProvider>(context, listen: false).loggedInUserData;

    super.initState();
  }

  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  void _returnBook(data, id) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                  "Do you really want to return book with title ${data['title']}"),
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
                    returnBook(data, id);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  bool returnOnTime = true;
  returnBook(data, id) async {
    CustomProgressIndicatorDialog(context: context);
    String returnDateString = data['return_Date'];
    DateTime returnDate = DateTime.parse(returnDateString);
    DateTime today = DateTime.now();

    if (returnDate.isBefore(today)) {
      // returnDate is before today's date
      returnOnTime = false;
      try {
        DocumentSnapshot<Map<String, dynamic>> userData = await fireStore
            .collection(ALLUSERS)
            .doc(generalAppUser["UID"])
            .get();
        await fireStore.collection(ALLUSERS).doc(generalAppUser["UID"]).update({
          'fine': (userData['fine'] + 500),
          'Books_Issued': userData['Books_Issued'] - 1
        }).whenComplete(() async {
          await fireStore
              .collection(ALLUSERS)
              .doc(generalAppUser["UID"])
              .collection('Issued_Books')
              .doc(id)
              .delete();
          DocumentSnapshot<Map<String, dynamic>> bookData =
              await fireStore.collection("books").doc(id).get();
          await fireStore
              .collection("books")
              .doc(id)
              .update({'pieces': (bookData['pieces'] + 1)});

          showSnackBarMsg(context, "You Have been Fined for RS.500");
        });
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        showSnackBarMsg(context, e.code, error: true);
      } catch (e) {
        Navigator.pop(context);
        showSnackBarMsg(context, e.toString(), error: true);
      }

      print('returnDate is in the past');
    } else if (returnDate.isAfter(today)) {
      // returnDate is after today's date
      try {
        await fireStore
            .collection(ALLUSERS)
            .doc(generalAppUser["UID"])
            .collection('Issued_Books')
            .doc(id)
            .delete();
        DocumentSnapshot<Map<String, dynamic>> userData = await fireStore
            .collection(ALLUSERS)
            .doc(generalAppUser["UID"])
            .get();
        await fireStore
            .collection(ALLUSERS)
            .doc(generalAppUser["UID"])
            .update({'Books_Issued': userData['Books_Issued'] - 1});
        DocumentSnapshot<Map<String, dynamic>> bookData =
            await fireStore.collection("books").doc(id).get();
        await fireStore
            .collection("books")
            .doc(id)
            .update({'pieces': (bookData['pieces'] + 1)});

        showSnackBarMsg(context, "Book Returned on time");
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        showSnackBarMsg(context, e.code, error: true);
      } catch (e) {
        Navigator.pop(context);
        showSnackBarMsg(context, e.toString(), error: true);
      }

      returnOnTime = true;
      print('returnDate is in the future');
    }
    await fireStore.collection("Total_Returns").doc().set({
      'image': data['image'],
      'author': data['author'],
      'issued_on': data['issued_on'],
      'title': data['title'],
      'category': data['category'],
      'actural_return_Date': data['return_Date'],
      'returned_on': DateTime.now().toString().split(' ')[0],
      'returned_by': generalAppUser["name"],
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => DashBoard()));
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore fireStore = FirebaseFirestore.instance;
    MyAppSize.config(MediaQuery.of(context));
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
      ),
      appBar: AppBar(
        title: Text(
          "Returns",
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: fireStore
                .collection(ALLUSERS)
                .doc(generalAppUser['UID'])
                .collection('Issued_Books')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  print("I am in Error State in viewJob Screen");
                  return Text(snapshot.error.toString());
                } else if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot ds = snapshot.data!.docs[index];
                        return Padding(
                          padding: EdgeInsets.all(10.0),
                          child: InkWell(
                            onTap: () {
                              _returnBook(ds, ds.id);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 171, 207, 172),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(13.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          children: [
                                            Image.network(
                                              ds['image'],
                                              height: 120,
                                              width: 120,
                                            )
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 3.0),
                                              child: Text(
                                                ds['title'].toString(),
                                                style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontFamily: 'Itim-Regular',
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 3.0),
                                              child: Text(
                                                ds['category'].toString(),
                                                style: TextStyle(
                                                  fontFamily: 'Itim-Regular',
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 3.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      "Author : ${ds['author']}",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Itim-Regular',
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 3.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Issued Date: ${ds['issued_on'].toString()}',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Itim-Regular',
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 3.0),
                                              child: Row(
                                                children: [
                                                  ds['return_Date'] ==
                                                          DateTime.now()
                                                              .toString()
                                                              .split(' ')[0]
                                                      ? Text(
                                                          'Return Date: ${ds['return_Date'].toString()}',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontFamily:
                                                                'Itim-Regular',
                                                            fontSize: 18,
                                                          ),
                                                        )
                                                      : Text(
                                                          'Return Date: ${ds['return_Date'].toString()}',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Itim-Regular',
                                                            fontSize: 18,
                                                          ),
                                                        )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Center(child: Text('No Data Found'));
                }
              } else {
                return Text('State: ${snapshot.connectionState}');
              }
            },
          ),
        ],
      ),
    );
  }
}
