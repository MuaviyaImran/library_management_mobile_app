// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:library_management/Commons/HomeScreen.dart';
import 'package:library_management/Commons/bookCollections.dart';
import 'package:library_management/Commons/profile.dart';
import 'package:library_management/utils/colors.dart';

class BottomNavBar extends StatefulWidget {
  BottomNavBar({Key? key ,required this.selectedIndex}) : super(key: key);
int selectedIndex;
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.collections,
            ),
            label: "Collection"),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: "Me"),
      ],
      currentIndex: widget.selectedIndex,
      selectedItemColor: MyColors.GREEN,
      unselectedItemColor: Colors.grey,
      unselectedLabelStyle: TextStyle(color: Colors.grey),
      onTap: (index) {
        setState(() {
           widget.selectedIndex = index;
          if ( widget.selectedIndex == 0) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => DashBoard()));
          } else if ( widget.selectedIndex == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => BookCollections()));
          } else if ( widget.selectedIndex == 2) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Profile()));
          }
        });
      },
    );
  }
}
