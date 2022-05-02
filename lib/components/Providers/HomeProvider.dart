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

  Map selected_store = {
    "store_fp": "kfc9537807322322",
    "structured": "true",
    "name": "KFC"
  }; //The selected store id

  List mainStores = []; //Will hold the names of all the main stores.

  Map catalogueData_level1_structured =
      {}; //Will hold the catalogue data level1 - Stuctured

  List catalogueData_level2_structured =
      []; //Will hold the catalogue data level2 - Stuctured

  Map<String, String> selectedDataL2ToShow = {
    "store": "kfc9537807322322",
    "name": "KFC",
    "fd_name": "KFC",
    "category": "BUCKETS",
    // "subcategory": "BUCKETS"
  }; //Will hold the data l1 - structured that will be shown for more

  Map<String, dynamic> selectedProduct = {
    "index": 159,
    "name": "PnP Salad Dressing Honey Mustard 340ml",
    "price": "N\$2199",
    "pictures": [
      "https://cdn-prd-02.pnp.co.za/sys-master/images/h9d/hbd/10656924991518/silo-product-image-v2-22Jan2022-180103-6001007222260-front-2834200-726_515Wx515H",
      "https://cdn-prd-02.pnp.co.za/sys-master/images/h0b/h64/10656928923678/silo-product-image-v2-22Jan2022-180103-6001007222260-up-2834290-713_515Wx515H"
    ],
    "sku": "000000000000458088_EA",
    "meta": {
      "category": "FRESH FRUIT & VEGETABLES",
      "subcategory": "FRESH FRUIT & VEGETABLES",
      "store": "PICK N PAY",
      "store_fp": "picknpay8837887322322",
      "structured": "true"
    }
  }; //Hold the product that the user selected for a closup

  //Updaters
  //?1. Update the main stores
  void updateMainStores({required List data}) {
    mainStores = data;
    notifyListeners();
  }

  //?2. Update the catalogue level 1 data - structured
  void updateCatalogueLevel1_structured({required Map data}) {
    catalogueData_level1_structured = data;
  }

  //?2.b Update the catalogue level 2 data - structured
  void updateCatalogueLevel2_structured({required List data}) {
    catalogueData_level2_structured = data;
  }

  //?3. Update the the selected store's data
  void updateSelectedStoreData({required Map data}) {
    selected_store = data;
    notifyListeners();
  }

  //?4. Update selected data l2 to show
  void updateSelectedDataL2ToShow({required Map<String, String> data}) {
    selectedDataL2ToShow = data;
    notifyListeners();
  }

  //?5. Update  the selected product to show
  void updateSelectedProduct({required Map<String, dynamic> data}) {
    selectedProduct = data;
    notifyListeners();
  }
}
