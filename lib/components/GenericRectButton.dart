// ignore_for_file: file_names

import 'package:flutter/material.dart';

///Generic rectangular button
///Can receive any on press action void function
class GenericRectButton extends StatelessWidget {
  final String label;
  final double labelFontSize; //Default: 28
  final bool isArrowShow;
  final double horizontalPadding; //Default: 16
  final double verticalPadding; //Default: 16
  final actuatorFunctionl; //! The function that will be fired when the button is clicked.
  //For the trailing button
  final bool
      activateTrailing; //Whether or not to activate the trailing button - default:false
  final IconData
      trailingIcon; //Main icon for the trailing button - default: Icon.watch_later
  final actuatorTrailingFunctional; //?The function that will be fired when the trailing button is clicked - default - false
  final String?
      bottomSubtitleText; //The subtitle to display under the main label text - default:null
  final Color backgroundColor; //The background color of the button
  final Color textColor; //the text color

  GenericRectButton(
      {required this.label,
      required this.actuatorFunctionl,
      this.isArrowShow = true,
      this.horizontalPadding = 16,
      this.verticalPadding = 16,
      this.labelFontSize = 28,
      this.activateTrailing = false,
      this.trailingIcon = Icons.watch_later,
      this.bottomSubtitleText,
      this.actuatorTrailingFunctional = false,
      this.backgroundColor = Colors.black,
      this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: this.horizontalPadding, vertical: this.verticalPadding),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  // decoration: BoxDecoration(boxShadow: [
                  //   BoxShadow(
                  //       color: Colors.grey.withOpacity(0.2),
                  //       blurRadius: 2,
                  //       spreadRadius: 4)
                  // ]),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(backgroundColor)),
                    onPressed: this.actuatorFunctionl,
                    child: Padding(
                        padding: EdgeInsets.only(
                            bottom: this.bottomSubtitleText == null ? 15 : 5,
                            top: this.bottomSubtitleText == null ? 15 : 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: label == 'LOADING'
                                          ? SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                color: textColor,
                                              ))
                                          : Text(
                                              this.label,
                                              style: TextStyle(
                                                  fontFamily: 'MoveTextMedium',
                                                  fontSize:
                                                      this.bottomSubtitleText ==
                                                              null
                                                          ? this.labelFontSize
                                                          : 20,
                                                  color: textColor),
                                            ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: this.bottomSubtitleText != null
                                        ? true
                                        : false,
                                    child: Flexible(
                                      flex: 1,
                                      child: Container(
                                        child: Text(
                                            '${this.bottomSubtitleText}',
                                            style: TextStyle(
                                                color: Colors.grey.shade200,
                                                fontSize: 15)),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Visibility(
                              visible: this.isArrowShow,
                              child: Icon(Icons.arrow_forward,
                                  size: 25, color: textColor),
                            )
                          ],
                        )),
                  ),
                ),
              ),
              Visibility(
                visible: this.activateTrailing,
                child: Container(
                  child: AddTrailingButton(
                    activateTrailing: this.activateTrailing,
                    trailingIcon: this.trailingIcon,
                    actuatorTrailingFunctional: this.actuatorTrailingFunctional,
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

//Add trailing button
class AddTrailingButton extends StatelessWidget {
  final bool
      activateTrailing; //Whether or not to activate the trailing button - default:false
  final IconData
      trailingIcon; //Main icon for the trailing button - default: Icon.watch_later
  final actuatorTrailingFunctional; //! The function that will be fired when the trailing button is clicked - default - false
  const AddTrailingButton(
      {Key? key,
      required this.activateTrailing,
      required this.trailingIcon,
      required this.actuatorTrailingFunctional})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 10,
        ),
        Container(
          height: 65,
          width: 75,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.grey.shade200)),
            onPressed: this.actuatorTrailingFunctional.runtimeType != bool
                ? this.actuatorTrailingFunctional
                : () => {},
            child: Padding(
                padding: EdgeInsets.only(bottom: 15, top: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        child: Icon(this.trailingIcon,
                            size: 27, color: Colors.black),
                      ),
                    )
                  ],
                )),
          ),
        ),
      ],
    );
  }
}
