// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:library_management/Commons/allUsers.dart';
import 'package:library_management/Commons/bookCategory.dart';
import 'package:library_management/Commons/returnBook.dart';
import 'package:library_management/Commons/totalReturns.dart';
import 'package:library_management/Commons/uploadBook.dart';
import 'package:library_management/firebase/loggedInUserData.dart';
import 'package:library_management/Commons/bottom_nav_bar.dart';
import 'package:library_management/utils/appConstants.dart';
import 'package:library_management/utils/custom_widgets/custom_widgets.dart';
import 'package:library_management/utils/responsive_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/colors.dart';
import '../../utils/size_config.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DashBoard extends StatefulWidget {
  @override
  DashBoard({
    Key? key,
  }) : super(key: key) {}

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  bool loading = false;
  var generalAppUser;
  setUser() async {
    var UID;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UID = prefs.getString("UID");
    DocumentSnapshot<Map<String, dynamic>> data =
        await FirebaseFirestore.instance.collection(ALLUSERS).doc(UID).get();
    var u = data.data();
    Map<dynamic, dynamic> loggedInUserData = {
      'email': u!["email"],
      'name': u['name'],
      'phone': u['phone'],
      'UID': UID,
      'profileUrl': u['profileUrl'],
      'Books_Issued': u['Books_Issued'],
      'fine': u['fine'],
    };
    Provider.of<userDataProvider>(context, listen: false)
        .saveUser(loggedInUserData);
  }

  @override
  void initState() {
    setState(() {
      loading = true;
    });
    // TODO: implement initState
    setUser();
    generalAppUser =
        Provider.of<userDataProvider>(context, listen: false).loggedInUserData;
    setState(() {
      generalAppUser = Provider.of<userDataProvider>(context, listen: false)
          .loggedInUserData;
      loading = false;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MyAppSize.config(MediaQuery.of(context));
    return Consumer<userDataProvider>(
        builder: (context, user, child) => Scaffold(
              bottomNavigationBar: BottomNavBar(
                selectedIndex: 0,
              ),
              appBar: AppBar(
                title: Text(
                  "Dashboard",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'Itim-Regular'),
                ),
                centerTitle: true,
                actions: [],
                elevation: 0,
                backgroundColor: MyColors.MATERIAL_LIGHT_GREEN,
              ),
              drawer: drawer(context, generalAppUser),
              body: Responsive(
                mobile: mobile(context, generalAppUser),
                web: webUI(),
                tablet: tabletUI(),
              ),
            ));
  }

  ///Sliver AppBar
  SliverAppBar myDashboardAppBar(
      {required String title, required generalAppUser}) {
    return SliverAppBar(
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
            fontSize: 18, color: Colors.white, fontFamily: 'Itim-Regular'),
      ),
      pinned: false,
      elevation: 5,
      automaticallyImplyLeading: false,
      actions: [],
      expandedHeight: 10,
      backgroundColor: MyColors.MATERIAL_LIGHT_GREEN,
      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [],
        ),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  ///generate card Data List
  List<MyDashboardCardData> adminCardData() {
    return <MyDashboardCardData>[
      MyDashboardCardData(
          title: "Books Collection",
          imgPath: "assets/images/book-png-15363.png"),
      MyDashboardCardData(
          title: "All Users", imgPath: "assets/images/allusers.png"),
      MyDashboardCardData(
          title: "Upload Book", imgPath: "assets/images/uploadBook.png"),
      MyDashboardCardData(
          title: "Total Returns", imgPath: "assets/images/returnbooks.png"),
    ];
  }

  List<MyDashboardCardData> userCardData() {
    return <MyDashboardCardData>[
      MyDashboardCardData(
          title: "Books Collection",
          imgPath: "assets/images/book-png-15363.png"),
      MyDashboardCardData(
          title: "Book Return", imgPath: "assets/images/returnbooks.png"),
    ];
  }

  /// Dashboard Grid
  SliverGrid myDashboardGrid(appUser) {
    List<MyDashboardCardData> gridCardData =
        appUser.loggedInUserData['email'] == ADMIN_EMAIL
            ? adminCardData()
            : userCardData();
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 250,
          mainAxisSpacing: 4,
          crossAxisSpacing: 8),
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Card(
            elevation: 3,
            shadowColor: Colors.green,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              splashColor: MyColors.MATERIAL_LIGHT_GREEN,
              onTap: () {
                if (gridCardData[index].title == "Books Collection") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookCategories()));
                } else if (gridCardData[index].title == "Book Return") {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ReturnBook()));
                } else if (gridCardData[index].title == 'All Users') {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AllUsers()));
                } else if (gridCardData[index].title == 'Upload Book') {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UploadBook()));
                } else if (gridCardData[index].title == 'Total Returns') {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TotalReturns()));
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      flex: 4,
                      child: Image(
                          image: AssetImage(gridCardData[index]._imgPath))),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      gridCardData[index]._title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: MyColors.DARK_BROWN,
                          fontFamily: ' Itim-Regular',
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500),
                    ),
                  ))
                ],
              ),
            ),
          ),
        );
      }, childCount: gridCardData.length),
    );
  }

  ///Mobile UI
  Widget mobile(BuildContext context, appUser) {
    return Consumer<userDataProvider>(
        builder: (context, user, child) => CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                myDashboardAppBar(
                    title:
                        "Hello ${user.loggedInUserData['name']}! How is Life Going..",
                    generalAppUser: appUser),
                SliverPadding(
                  padding: EdgeInsets.only(
                      left: MyAppSize.width! * 0.05,
                      right: MyAppSize.width! * 0.05,
                      bottom: MyAppSize.height! * 0.05),
                  sliver: myDashboardGrid(user),
                )
              ],
            ));
  }
}

///Clas To Hold Card Data
class MyDashboardCardData {
  late final String _imgPath;
  late final String _title;

  MyDashboardCardData({required String imgPath, required String title}) {
    this._imgPath = imgPath;
    this._title = title;
  }

  String get title => _title;

  String get imgPath => _imgPath;
}
