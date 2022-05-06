// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart';
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

  Map<String, dynamic> tmp_selectedProduct =
      {}; //To save the state of the intermediary selected product for a very fluid experience

  List<Map<String, dynamic>> CART = []; //Will hold all the cart data

  String paymentMethod =
      'mobile_money'; //The method used to pay: mobile_money or cash

  //? LOCATION RELATED
  Map<String, dynamic> manuallySettedCurrentLocation_pickup =
      {}; //The manually entered location of the user - PICKUP
  Map<String, dynamic> manuallySettedCurrentLocation_dropoff =
      {}; //The manually entered location of the user - DROP OFF

  String typedSearchLocation = ''; //The seached query
  List suggestedLocationSearches =
      []; //The list of realtime location suggestions
  bool isLoadingForSearch = false; //When loading for the search of suggestions

  Map<dynamic, dynamic> locationServicesStatus = {
    'isLocationServiceEnabled': true,
    'isLocationPermissionGranted': true,
    'isLocationDeniedForever': false
  }; //Will hold the status of the GPRS service and the one of the location permission.
  late Map userLocationCoords = {}; //The user location coordinates: lat/long
  bool didAutomaticallyAskedForGprsPerm =
      false; //To know whether to ask for permission again or not.

  Map<String, dynamic> userLocationDetails =
      {}; //The details of the user location: city, location name

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

  //?6. Add product to cart
  void addProductToCart({required Map<String, dynamic> product}) {
    //! Add the item number if not set
    product['items'] = product['items'] != null ? product['items'] : 1;
    //...
    CART.add(product);
    print(CART);
    notifyListeners();
  }

  //?6.b Remove product from cart
  void removeProductFromCart({required Map<String, dynamic> product}) {
    CART.removeWhere(((element) =>
        element['name'] == product['name'] &&
        element['sku'] == product['sku'] &&
        element['meta']['store_fp'] == product['meta']['store_fp']));
    //...
    notifyListeners();
  }

  //?7. Check if a product is in the cart
  bool isProductInCart({required Map<String, dynamic> product}) {
    // print(CART.contains(product));
    Map<String, dynamic> checker = CART.firstWhere(
        (element) =>
            element['name'] == product['name'] &&
            element['sku'] == product['sku'] &&
            element['meta']['store_fp'] == product['meta']['store_fp'],
        orElse: () => {});
    //...
    return checker['name'] != null;
  }

  //?8. Get cart total sum
  String getCartTotal() {
    double total = 0;

    CART.forEach((element) {
      double tmpPrice = double.parse(
          pricingToolbox(currentPrice: element['price'], multiplier: 1)
              .toString()
              .replaceFirst('N\$', ''));
      total += tmpPrice;
    });

    return 'N\$${total.ceil().toStringAsFixed(2)}';
  }

  //Pricing toolbox
  String pricingToolbox(
      {required String currentPrice, required int multiplier}) {
    if (currentPrice.split(',').length > 1 &&
        currentPrice.split(',')[1].length == 2) //Remove and divide by 100
    {
      //Get the number
      double number = double.parse(
              currentPrice.replaceAll('N\$', '').trim().replaceAll(',', '')) /
          100;
      //...
      return 'N\$${(number * multiplier).toStringAsFixed(2)}';
    } else {
      //Get the number
      double number = double.parse(
          currentPrice.replaceAll('N\$', '').trim().replaceAll(',', ''));
      //...
      return 'N\$${(number * multiplier).toStringAsFixed(2)}';
    }
  }

  //?9. Update  the tmp selected product to show
  void updateTMPSelectedProduct({required Map<String, dynamic> data}) {
    tmp_selectedProduct = data;
    notifyListeners();
  }

  //?10. Update payment method
  void updatePaymentMethod({required String data}) {
    paymentMethod = data;
    notifyListeners();
  }

  //?11. Update the typed search for locations
  void updateTypedSeachQueries({required String data}) {
    typedSearchLocation = data;
    isLoadingForSearch = true;
    notifyListeners();
    //! Search for suggestions
    getSuggestions(querySearch: data);
  }

  //! Complementary function
  Future getSuggestions({required String querySearch}) async {
    if (querySearch.isNotEmpty) {
      Uri mainUrl = Uri.parse(Uri.encodeFull('$bridge/getSearchedLocations'));

      //Assemble the bundle data
      //* @param type: the type of request (past, scheduled, business)
      Map<String, String> bundleData = {
        "query": querySearch,
        "country": userLocationDetails['country'],
        "city": userLocationDetails['city'],
        "state": "Khomas",
        "user_fp": user_identifier
      };

      try {
        Response response = await post(mainUrl, body: bundleData);

        if (response.statusCode == 200) //Got some results
        {
          // log(response.body.toString());
          if (response.body.toString() == 'false') //No data
          {
            updateRealtimeLocationSuggestions(data: []);
          } else //Got some data
          {
            List<dynamic> tmpData =
                json.decode(response.body)['result']['result'];
            // print(tmpData);
            updateRealtimeLocationSuggestions(data: tmpData);
          }
        } else //Has some errors
        {
          log(response.toString());

          updateRealtimeLocationSuggestions(data: []);
        }
      } catch (e) {
        log('8');
        log(e.toString());

        updateRealtimeLocationSuggestions(data: []);
      }
    } else //Empty search
    {
      updateRealtimeLocationSuggestions(data: []);
    }
  }

  //! Update the realtime location suggestions
  void updateRealtimeLocationSuggestions({required List<dynamic> data}) {
    suggestedLocationSearches = data;
    isLoadingForSearch = false;
    notifyListeners();
  }

  //?12. Update the GPRS service status and the location permission
  void updateGPRSServiceStatusAndLocationPermissions(
      {required bool gprsServiceStatus,
      required bool locationPermission,
      bool isDeniedForever = false}) {
    // print(locationServicesStatus.toString());

    if (gprsServiceStatus !=
            locationServicesStatus['isLocationServiceEnabled'] ||
        locationPermission !=
            locationServicesStatus['isLocationPermissionGranted'] ||
        locationServicesStatus['isLocationDeniedForever'] !=
            isDeniedForever) //new values received
    {
      locationServicesStatus['isLocationServiceEnabled'] = gprsServiceStatus;
      locationServicesStatus['isLocationPermissionGranted'] =
          locationPermission;
      locationServicesStatus['isLocationDeniedForever'] = isDeniedForever;
      //...Update
      // print('UPDATED GLOBAL STATE FOR LOCATION SERVICE STATUS');
      notifyListeners();
    }
  }

  //? 13. Update the automatic asking for gprs coordinate
  void updateAutoAskGprsCoords({required bool didAsk}) {
    if (didAutomaticallyAskedForGprsPerm != didAsk) //New data
    {
      // print('UPDATING AUTO ASK FOR GPRS COORDS.');
      didAutomaticallyAskedForGprsPerm = didAsk;
    }
  }

  //?14. Update user's current location
  void updateUsersCurrentLocation(
      {required Map<String, dynamic> newCurrentLocation}) {
    //Replace name by location_name
    newCurrentLocation['location_name'] = newCurrentLocation['street'];
    if (!mapEquals(newCurrentLocation, userLocationDetails)) //New data received
    {
      userLocationDetails = newCurrentLocation;
      notifyListeners();
    }
  }

  //?15. Update the rider's location coordinates
  void updateRidersLocationCoordinates(
      {required double latitude, required double longitude}) {
    if (userLocationCoords['latitude'] != latitude &&
        userLocationCoords['longitude'] != longitude) //new Data received
    {
      userLocationCoords['latitude'] = latitude;
      userLocationCoords['longitude'] = longitude;
      // print('Updated location with new ones');
      //..
      notifyListeners();
    }
  }

  //?16. Update the manual location for the user - pickup or drop off
  void updateManualPickupOrDropoff(
      {required String location_type, required Map<String, dynamic> location}) {
    if (location_type == 'pickup') {
      manuallySettedCurrentLocation_pickup = location;
      notifyListeners();
    } else if (location_type == 'dropoff') {
      manuallySettedCurrentLocation_dropoff = location;
      notifyListeners();
    }
  }

  //?17. Get manual location data
  Map<String, dynamic> getManualLocationSetted(
      {required String location_type}) {
    if (location_type == 'pickup') {
      return manuallySettedCurrentLocation_pickup;
    } else {
      return manuallySettedCurrentLocation_dropoff;
    }
  }
}
