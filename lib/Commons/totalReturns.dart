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

class TotalReturns extends StatefulWidget {
  const TotalReturns({super.key});

  @override
  State<TotalReturns> createState() => _TotalReturnsState();
}

class _TotalReturnsState extends State<TotalReturns> {
  var generalAppUser;
  @override
  void initState() {
    // TODO: implement initState

    generalAppUser =
        Provider.of<userDataProvider>(context, listen: false).loggedInUserData;

    super.initState();
  }

  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    MyAppSize.config(MediaQuery.of(context));
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
      ),
      appBar: AppBar(
        title: Text(
          "Total Returns",
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
            stream: fireStore.collection("Total_Returns").snapshots(),
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
                            onTap: () {},
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
                                                  ds['actural_return_Date'] ==
                                                          DateTime.now()
                                                              .toString()
                                                              .split(' ')[0]
                                                      ? Text(
                                                          'Return Date: ${ds['actural_return_Date'].toString()}',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontFamily:
                                                                'Itim-Regular',
                                                            fontSize: 18,
                                                          ),
                                                        )
                                                      : Text(
                                                          'Return Date: ${ds['actural_return_Date'].toString()}',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Itim-Regular',
                                                            fontSize: 18,
                                                          ),
                                                        )
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 3.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Rerurned On: ${ds['returned_on'].toString()}',
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
                                                  Text(
                                                    'Returned By: ${ds['returned_by'].toString()}',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Itim-Regular',
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
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
