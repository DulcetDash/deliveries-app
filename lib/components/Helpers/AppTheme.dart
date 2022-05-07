import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AppTheme {
  //1. Get the primary color
  Color getPrimaryColor() {
    return HexColor('#06C167');
  }

  //2. Get the error color
  Color getErrorColor() {
    return Colors.red.shade400;
  }
}
