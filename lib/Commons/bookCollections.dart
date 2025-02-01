// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:library_management/Commons/HomeScreen.dart';
import 'package:library_management/Commons/bookDetail.dart';
import 'package:library_management/Commons/bottom_nav_bar.dart';
import 'package:library_management/firebase/loggedInUserData.dart';
import 'package:library_management/utils/colors.dart';
import 'package:library_management/utils/custom_widgets/custom_widgets.dart';
import 'package:library_management/utils/size_config.dart';
import 'package:provider/provider.dart';

class BookCollections extends StatefulWidget {
  final String category;
  const BookCollections({Key? key, required this.category}) : super(key: key);

  @override
  State<BookCollections> createState() => _BookCollectionsState();
}

class _BookCollectionsState extends State<BookCollections> {
  var generalAppUser;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    generalAppUser =
        Provider.of<userDataProvider>(context, listen: false).loggedInUserData;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore fireStore = FirebaseFirestore.instance;
    MyAppSize.config(MediaQuery.of(context));
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
      ),
      appBar: AppBar(
        title: Text(
          widget.category,
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(hintText: "Search.."),
              onChanged: (value) {
                performSearch(value);
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: fireStore.collection("books").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  print("I am in Error State in viewJob Screen");
                  return Text(snapshot.error.toString());
                } else if (snapshot.hasData) {
                  List<DocumentSnapshot> filteredBooks =
                      snapshot.data!.docs.where((doc) {
                    String title = doc['title'].toString().toLowerCase();
                    String categoryItem =
                        doc['category'].toString().toLowerCase();
                    // category
                    return title
                            .contains(searchController.text.toLowerCase()) &&
                        categoryItem.toLowerCase() ==
                            widget.category.toLowerCase();
                  }).toList();

                  return Expanded(
                    child: ListView.builder(
                      itemCount: filteredBooks.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot ds = filteredBooks[index];
                        return Padding(
                          padding: EdgeInsets.all(10.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookDetail(
                                    vatData: ds,
                                  ),
                                ),
                              );
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
                                        SizedBox(
                                          width: 10,
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
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 3.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Pieces: ${ds['pieces'].toString()}',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Itim-Regular',
                                                      fontSize: 18,
                                                    ),
                                                  ),
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

  void performSearch(String query) {
    setState(() {
      // The search logic is now inside the StreamBuilder
    });
  }
}
