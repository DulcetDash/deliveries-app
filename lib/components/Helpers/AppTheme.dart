import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AppTheme {
  //1. Get the primary color
  Color getPrimaryColor() {
    return HexColor('#639f62');
    // return Colors.blue;
  }

  //1b. Get the secondary color
  Color getSecondaryColor() {
    return Colors.blue;
  }

  //2. Get the error color
  Color getErrorColor() {
    return Colors.red.shade400;
  }

  //3. Universal arrow back size
  double getArrowBackSize() {
    return 30.0;
  }

  //4. Main big title 1
  double getMainBigTitle1Size() {
    return 24.0;
  }

  //5. Generic dark grey
  Color getGenericDarkGrey() {
    return Colors.grey.shade600;
  }

  //6. Generic faded opacity value
  double getFadedOpacityValue() {
    return 0.3;
  }
}
