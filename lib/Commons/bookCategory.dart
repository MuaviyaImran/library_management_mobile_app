import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:library_management/Commons/HomeScreen.dart';
import 'package:library_management/Commons/bookCollections.dart';
import 'package:library_management/Commons/bottom_nav_bar.dart';
import 'package:library_management/firebase/loggedInUserData.dart';
import 'package:library_management/utils/colors.dart';
import 'package:library_management/utils/custom_widgets/custom_widgets.dart';
import 'package:library_management/utils/size_config.dart';
import 'package:provider/provider.dart';

class BookCategories extends StatefulWidget {
  const BookCategories({Key? key}) : super(key: key);

  @override
  State<BookCategories> createState() => _BookCategoriesState();
}

class _BookCategoriesState extends State<BookCategories> {
  var generalAppUser;
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
          title: const Text(
            "Book Categories",
            style: TextStyle(
                fontSize: 19, color: Colors.white, fontFamily: 'Itim-Regular'),
          ),
          centerTitle: true,
          actionsIconTheme: const IconThemeData(
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
                icon: const Icon(Icons.home))
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
                stream: fireStore.collection("books").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.connectionState ==
                          ConnectionState.active ||
                      snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      print("I am in Error State in viewJob Screen");
                      return Text(snapshot.error.toString());
                    } else if (snapshot.hasData) {
                      List<DocumentSnapshot> filteredBooks =
                          snapshot.data!.docs.where((doc) {
                        String title = doc['title'].toString().toLowerCase();
                        return title.contains('');
                      }).toList();

                      return Expanded(
                        child: ListView.builder(
                          itemCount: filteredBooks.length,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot ds = filteredBooks[index];
                            return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BookCollections(
                                            category: ds['category']
                                                .toString(), // Pass category here
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 171, 207, 172),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0,
                                                horizontal: 20.0),
                                            child: Text(
                                              ds['category'].toString(),
                                              style: const TextStyle(
                                                fontFamily: 'Itim-Regular',
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                              child: Icon(
                                                Icons.arrow_forward_ios_sharp,
                                                size: 16,
                                              ))
                                        ],
                                      ),
                                    )));
                          },
                        ),
                      );
                    } else {
                      return const Center(child: Text('No Data Found'));
                    }
                  } else {
                    return Text('State: ${snapshot.connectionState}');
                  }
                },
              ),
            ]));
  }
}
