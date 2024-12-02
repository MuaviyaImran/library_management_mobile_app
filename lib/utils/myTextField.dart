// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:library_management/utils/colors.dart';

Widget MyTextField(String labletext, TextEditingController controller,
    bool obscureText,bool readOnly , context) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Container(
      width: MediaQuery.of(context).size.width - 70,
      height: 55,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly:readOnly,
        style: TextStyle(fontSize: 15, color: Colors.black),
        decoration: InputDecoration(
            labelText: labletext,
            labelStyle: TextStyle(fontSize: 17, color: Colors.black),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                    width: 1.5, color: MyColors.MATERIAL_LIGHT_GREEN)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(
                    width: 2, color: MyColors.MATERIAL_LIGHT_GREEN))),
      ),
    ),
  );
}
