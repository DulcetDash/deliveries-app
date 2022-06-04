import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SnackBarMother {
  final BuildContext context; //The build context of the parentt
  final Widget snackChild; //The Widget to display in the snack bar
  final Color snackTextColor; //The color of the snack text
  final Color
      snackBackgroundcolor; //The color of the background of the entire snackbar
  final double snackPaddingBottom; //THe bottom padding for the snackbar

  late final SnackBar
      snackBarMotherInstance; //The main snack bar instance variable
  bool isSnackBarInitialized =
      false; //Whether or not the snackbar was initialized - default: false

  SnackBarMother(
      {required this.context,
      required this.snackChild,
      this.snackTextColor = Colors.white,
      this.snackBackgroundcolor = const Color.fromRGBO(14, 132, 145, 1),
      this.snackPaddingBottom = 0});

  void initSnackBar() {
    if (this.isSnackBarInitialized == false) {
      this.snackBarMotherInstance = SnackBar(
          duration: Duration(seconds: 2),
          padding:
              EdgeInsets.only(bottom: this.snackPaddingBottom - 15, top: 0),
          backgroundColor: Colors.black.withOpacity(0),
          elevation: 0,
          content: Container(
            decoration: BoxDecoration(color: this.snackBackgroundcolor),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 15, bottom: 15),
              child: Row(
                children: [
                  Icon(Icons.info, size: 15, color: this.snackTextColor),
                  SizedBox(
                    width: 5,
                  ),
                  this.snackChild,
                ],
              ),
            ),
          ));
      this.isSnackBarInitialized = true;
    }
  }

  void showSnackBarMotherChild() {
    this.hideSnackBar();
    this.initSnackBar();
    ScaffoldMessenger.of(this.context)
        .showSnackBar(this.snackBarMotherInstance);
  }

  void hideSnackBar() {
    ScaffoldMessenger.of(this.context).hideCurrentSnackBar();
  }
}
