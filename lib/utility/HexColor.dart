import 'dart:ui';

import 'package:flutter/material.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  // static var primarycolor="D8A531";
  // static var primarycolor="911E5F";
  static var primarycolor = "66C6CE";
  static var accentcolor = "FF6600";
  // static var primary_s = "1870FE";
  static var primary_s = "66C6CE";
  static var logo = "66C6CE";
  static var white = "ffffff";
  static var black = "000000";
  static var red_color = "EC3237";
  static var blue_color = "0097E6";
  static var yello = "FA9E10";
  static var yello1 = "EF9118";
  static var gray_line = "5b7586";
  static var gray = "B9B9B9";
  static var new_gray = "C9CBDB";
  static var gray_glash = "D2D3CE";
  static var gray_text = "5b7586";
  static var green_txt = "34A853";
  static var green1 = "71AB45";
  static var pink = "FF679D";
  static var medium_light_gray = "BCC4C5";
  static var transperent = "D8FFFFFF";
  static var gray_activity_background = "F7F7F7";
  static var gray_calender = "436183";
  static var gray_calender2 = "55657F";
  static var gray_light = "F2F2F2";

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
