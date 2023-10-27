// ignore_for_file: file_names

import 'package:flutter/material.dart';

final ThemeData appTheme = _buildAppTheme();

ThemeData _buildAppTheme() {
  final ThemeData base = ThemeData.light();

  return base.copyWith(textTheme: _appTextTheme(base.textTheme));
}

TextTheme _appTextTheme(TextTheme base) {
  return base.apply(fontFamily: 'MoveTextRegular', bodyColor: Colors.black);
}
