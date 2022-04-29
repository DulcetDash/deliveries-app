// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';

//? HOME PROVIDER
// Will hold all the home related globals - only!

class HomeProvider with ChangeNotifier {
  final String bridge = 'http://localhost:9697';
  // final String bridge = 'https://taxiconnectnanetwork.com:9999';

  String user_identifier = 'abc'; //The user's identifier

  List mainStores = []; //Will hold the names of all the main stores.

  //Updaters
  //?1. Update the main stores
  void updateMainStores({required List data}) {
    mainStores = data;
    notifyListeners();
  }
}
