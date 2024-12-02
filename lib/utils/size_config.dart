import 'package:flutter/material.dart';

class MyAppSize {
  static Size? size;
  static double? height;
  static double? width;
  static Orientation? orientation;

  MyAppSize.config(MediaQueryData mediaQueryData) {
    size = mediaQueryData.size;
    orientation = mediaQueryData.orientation;
    height = size?.height;
    width = size?.width;
  }
}
