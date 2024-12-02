// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:library_management/Commons/HomeScreen.dart';
import 'package:library_management/Commons/bottom_nav_bar.dart';
import 'package:library_management/firebase/loggedInUserData.dart';
import 'package:library_management/utils/appConstants.dart';
import 'package:library_management/utils/colors.dart';
import 'package:library_management/utils/custom_widgets/custom_widgets.dart';
import 'package:library_management/utils/size_config.dart';
import 'package:provider/provider.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({super.key});

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  var generalAppUser;
  var users;
  getUsers() async {
    var document = await FirebaseFirestore.instance.collection(ALLUSERS);
    document.get().then((document) {
      setState(() {
        users = document.docs;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    generalAppUser =
        Provider.of<userDataProvider>(context, listen: false).loggedInUserData;
    getUsers();
    super.initState();
  }

  List userListData = [];
  void _showUserImage(String name, imgUrl) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                name,
                style:
                    TextStyle(color: Colors.black, fontFamily: 'Itim-Regular'),
              ),
              content: imgUrl != ''
                  ? Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(NOIMAGE),
            ));
  }

  @override
  Widget build(BuildContext context) {
    MyAppSize.config(MediaQuery.of(context));
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 0,
      ),
      appBar: AppBar(
        title: Text(
          "App Users",
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
      body: users == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(0.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        // the number of items in the list
                        itemCount: users.length,

                        // display each item of the product list
                        itemBuilder: (context, index) {
                          var createdAt = users[index]['createdOn']
                              .toDate()
                              .toString()
                              .split(' ')[0];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5),
                            child: Card(
                              color: Color.fromARGB(255, 171, 207, 172),
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 15),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            _showUserImage(users[index]['name'],
                                                users[index]['profileUrl']);
                                          },
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundImage: users[index]
                                                        ['profileUrl'] !=
                                                    ''
                                                ? Image.network(users[index]
                                                        ['profileUrl'])
                                                    .image
                                                : AssetImage(
                                                    'assets/images/use1.jpg'),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          users[index]['name'],
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                              fontFamily: 'Itim-Regular'),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 20),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Email : ",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                                fontFamily: 'Itim-Regular'),
                                          ),
                                          Text(
                                            users[index]['email'],
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                                fontFamily: 'Itim-Regular'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 20),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Books Issued : ",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                                fontFamily: 'Itim-Regular'),
                                          ),
                                          Text(
                                            users[index]['Books_Issued']
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                                fontFamily: 'Itim-Regular'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 20),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Contact # : 0",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                                fontFamily: 'Itim-Regular'),
                                          ),
                                          Text(
                                            users[index]['phone'],
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                                fontFamily: 'Itim-Regular'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Created On : ",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                                fontFamily: 'Itim-Regular'),
                                          ),
                                          Text(
                                            createdAt,
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black,
                                                fontFamily: 'Itim-Regular'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  )
                ],
              ),
            ),
    );
  }
}
