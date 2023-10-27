import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AppTheme {
  //1. Get the primary color
  Color getPrimaryColor() {
    // return HexColor('#CD8600');
    // return Color.fromRGBO(9, 110, 212, 1);
    return HexColor('#11A05A');
  }

  //1b. Get the secondary color
  Color getSecondaryColor() {
    // return Color.fromRGBO(9, 110, 212, 1);
    // return HexColor('#339900');
    return Color.fromRGBO(9, 110, 212, 1);
  }

  //2. Get the error color
  Color getErrorColor() {
    return Color.fromRGBO(178, 34, 34, 1);
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

  //5.b Generic  grey
  Color getGenericGrey() {
    return Colors.grey.shade400;
  }

  //6. Generic faded opacity value
  double getFadedOpacityValue() {
    return 0.3;
  }

  //7. Get gold color
  Color getGoldColor() {
    return Colors.yellow.shade800;
  }

  //8. Get header pages title size
  double getHeaderPagesTitleSize() {
    return 25.0;
  }
}
