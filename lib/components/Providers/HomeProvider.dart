// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dulcetdash/components/Helpers/SuperHttp.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dulcetdash/components/Helpers/DataParser.dart';
import 'package:dulcetdash/components/Helpers/MapMarkerFactory/place_to_marker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:provider/src/provider.dart';
import 'package:collection/collection.dart';

//? HOME PROVIDER
// Will hold all the home related globals - only!

class HomeProvider with ChangeNotifier {
  final String bridge = 'http://192.168.178.93:9697';
  // final String bridge = 'https://api.dulcetdash.com';

  String selectedService =
      'ride'; //! The selected service that the user selected: ride, delivery and shopping - default: ''

  String user_identifier = 'empty_fingerprint'; //The user's identifier

  Map<String, dynamic> loginPhase1Data =
      {}; //Will hold the first checking data after the phone number check
  String otp_code = ''; //Will hold globally the otp entered
  TextEditingController otpFieldController = TextEditingController();

  //? Additional data for the login completion
  String name = '';
  String surname = '';
  String gender = 'male'; //Default: male
  String email = '';
  bool is_additional_emailValid =
      false; //If the email entered above is valid or not
  //------

  bool didSelectLanguage =
      false; //If the user was already prompted to select a language.

  Map pushnotif_token = {}; //Notification token

  //! Data restoration
  bool isLoadingForDataRestoration = true; //Actively loading

  Map<String, dynamic> userData = {}; //Will hold all the dynamic user data

  //? Recently visited shops
  List recentlyVisitedShops =
      []; //Will have the list of the 2 recently visited shops.

  //! Search for items in store
  String shops_search_item_key =
      ''; //Will hold the typed key to search for items globally
  List<dynamic> shops_items_searched =
      []; //Will hold the results for the searched items
  bool isLoadingForItemsSearch =
      false; //When loading for item search in a store.

  //! Search for stores
  String stores_search_key = ''; //Will hold the typed key to search for stores
  List<dynamic> stores_searched =
      []; //Will hold the results for the searched stores.

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

  //? Note
  String noteTyped = ''; //Will hold the note typed by the user for the shopping
  String noteTyped_delivery =
      ''; //Will hold the note typed by the user for the delivery

  //? Requesting for the shopping
  bool isLoadingForRequest =
      false; //Whether or not the app is loading while making a request

  List requestShoppingData = []; //! Will hold the realtime shopping data

  Map<String, bool> isThereARequestLockedIn = {
    "locked": false,
    "makeException": false
  }; //If the app already redirected the user to the request window

  //? Recipients related
  Map<String, dynamic> delivery_pickup = {'empty': 0};
  List recipients_infos = [
    {
      'name': '',
      'phone': '',
      'dropoff_location': {'empty': 0}
    }
  ]; //Will hold all the user details array form

  int selectedRecipient_index =
      0; //The index representing the selected recipient

  //Selected country code for phone input
  Map selectedCountryCodeData = {
    "name": "Namibia",
    "flag": "🇳🇦",
    "code": "NA",
    "dial_code": "+264"
  }; //Defaults - Namibia
  String enteredPhoneNumber = ''; //Default - empty
  bool isPhoneEnteredValid =
      true; //If the phone is valid or not - default: true
  bool isGenerally_phoneNumbersValid =
      false; //If allthe phone number entered are valid

  //? RIDE RELATED
  int passengersNumber = 1; //The number of passengers selected
  bool? isGoingTheSameWay =
      false; //If the passengers are going to the same destination
  String rideStyle =
      'shared'; //The type of ride: private or shared - default: shared - economical
  String noteTyped_ride = ''; //The note typed for the driver in a ride
  int selectedLocationField_index =
      -45; //The selected field for the locations - default: -1 (pickup location)
  Map<String, dynamic> ride_location_pickup = {'item': 0}; //OLD: ride_locations

  List<Map<String, dynamic>> ride_location_dropoff = [
    {'item': 0}
  ];

  List<LatLng> routeSnapshotData =
      <LatLng>[]; //Will hold the converted route snapshot recived
  Map<PolylineId, Polyline> polylines_snapshot = <PolylineId,
      Polyline>{}; //Will contain the full form of the polyline ready to be used
  Map<MarkerId, Marker> markers_snapshot =
      <MarkerId, Marker>{}; //Will hold the markers for the snapshot route
  Map<String, dynamic> eta_informationSnap = {
    "eta": "",
    "point1": {},
    "point2": {}
  };

  List pricing_computed = []; //Will hold the pricing data in bulk
  Map<String, dynamic> selected_pricing_model =
      {}; //The selected pricing vehicle
  bool isLoadingFor_fareComputation =
      true; //Whether the app is loading for fare computation

  //?CUSTOM FARES
  //For the custom fare inputs
  final double maximumPercentageCustomFareUpLimit = 0.85; //85%
  double? customFareEntered; //The custom fare entered by the rider
  double? definitiveCustomFare; //The unchanging custom fare after validatiion
  bool isCustomFareConsidered =
      false; //Whether or not a custom fare was applied by the user.

  int voucherAmountToPurchase = 0;

  bool isLoadingPurchaseVoucher = false;

  Map<String, dynamic> walletData = {"balance": 0, "transactionHistory": []};

  //The higher order absolute class
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  //The full file path
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/NejHomeProvider.txt');
  }

  //Write to file
  Future<File> writeStateToFile(String state) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(state);
  }

  //Read file
  Future<Map<String, dynamic>> readStateFile() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return json.decode(contents);
    } catch (e) {
      // log('6');
      // log(e.toString());
      // If encountering an error, return 0
      return {};
    }
  }

  //! Restore data map
  void restoreStateData({required BuildContext context}) {
    // print('Restore registration provider state');
    Future<Map<String, dynamic>> restoredState = readStateFile();
    restoredState.then((state) {
      if (mapEquals({}, state['userData']) ||
          state['userData'] == null) //?No state saved yet
      {
        // log('No state saved found');
        //? Close loader
        isLoadingForDataRestoration = false;
        //! Go to the select language page
        // Navigator.of(context).pushNamed('/Language');
        Navigator.of(context).pushNamed('/Entry');
        //?....
        notifyListeners();
      } else //Found a saved state
      {
        isLoadingForDataRestoration = false;

        // print(state);

        //! user_identifier
        user_identifier = state['user_identifier'] != null
            ? state['user_identifier']
            : 'empty_fingerprint';

        //! userData
        userData = state['userData'] != null ? state['userData'] : {};
        //! Notification token
        pushnotif_token =
            state['pushnotif_token'] != null ? state['pushnotif_token'] : {};

        //! Language selector driver
        didSelectLanguage = state['didSelectLanguage'] != null
            ? state['didSelectLanguage']
            : false;
        //?....
        //Reroute
        if (userData['account_state'] != null) //Has a state
        {
          if (user_identifier != 'empty_fingerprint' &&
              user_identifier.length > 10 &&
              userData['account_state'] == 'full') //logged in
          {
            Navigator.of(context).pushNamed('/home');
          } else //Not logged in
          {
            Navigator.of(context).pushNamed('/Entry');
          }
        } else //No state - not logged in
        {
          Navigator.of(context).pushNamed('/Entry');
        }

        notifyListeners();
      }
    });
  }

  //! Get fingerprint back
  Future<Map<String, dynamic>> getFileSavedFingerprintBack() {
    Future<Map<String, dynamic>> restoredState = readStateFile();
    return restoredState;
  }

  //! Persist data map
  void peristDataMap() {
    Map<String, dynamic> globalStateData = toMap();
    // print(globalStateData);
    String stateString = json.encode(globalStateData).toString();

    //Write
    writeStateToFile(stateString);
  }

  //! Convert class to Map
  Map<String, dynamic> toMap() {
    //? Intelligently figure out the correct user_identifier
    String user_identifier_deduced = loginPhase1Data['userData'] != null
        ? loginPhase1Data['userData']['user_identifier']
        : loginPhase1Data['response'] != null
            ? loginPhase1Data['response']['user_identifier']
            : user_identifier;

    return {
      "user_identifier": user_identifier_deduced,
      "userData": userData,
      "pushnotif_token": pushnotif_token,
      "didSelectLanguage": didSelectLanguage
    };
  }

  //! Clear everything
  void clearEverything() {
    user_identifier = 'empty_fingerprint';
    userData = {};
    pushnotif_token = {};
    //...
    peristDataMap();
    //...
    //notifyListeners();
  }

  //! Clear every related to requests
  void clearEveryRequestsRelatedData() {
    shops_search_item_key = '';
    shops_items_searched = [];
    isLoadingForItemsSearch = false;
    stores_search_key = '';
    stores_searched = [];
    selected_store = {};
    catalogueData_level1_structured = {};
    catalogueData_level2_structured = [];
    selectedDataL2ToShow = {};
    selectedProduct = {};
    tmp_selectedProduct = {};
    CART = [];
    manuallySettedCurrentLocation_pickup = {};
    manuallySettedCurrentLocation_dropoff = {};
    typedSearchLocation = '';
    suggestedLocationSearches = [];
    isLoadingForSearch = false;
    noteTyped = '';
    noteTyped_delivery = '';
    noteTyped_ride = '';
    isLoadingForRequest = false;
    requestShoppingData = [];
    delivery_pickup = {'empty': 0};
    recipients_infos = [
      {
        'name': '',
        'phone': '',
        'dropoff_location': {'empty': 0}
      }
    ];
    selectedRecipient_index = 0;
    enteredPhoneNumber = '';
    isPhoneEnteredValid = true;
    isGenerally_phoneNumbersValid = false;
    passengersNumber = 1;
    isGoingTheSameWay = false;
    // selectedLocationField_index = -1;
    ride_location_pickup = {'item': 0};
    ride_location_dropoff = [
      {'item': 0}
    ];
    routeSnapshotData = [];
    polylines_snapshot = {};
    markers_snapshot = {};
    eta_informationSnap = {"eta": "", "point1": {}, "point2": {}};
    pricing_computed = [];
    selected_pricing_model = {};
    isLoadingFor_fareComputation = true;
    customFareEntered = null;
    definitiveCustomFare = null;
    isCustomFareConsidered = false;
    //....
    notifyListeners();
  }
  //!-----------------

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
    catalogueData_level2_structured.addAll(data);
  }

  void clearProductsData() {
    catalogueData_level2_structured = [];
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
    // print(CART);
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

  //?6.c Clear the cart
  void clearCart() {
    CART = [];
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

    return total.ceil().toStringAsFixed(2);
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
      return (number * multiplier).toStringAsFixed(2);
    } else {
      //Get the number
      double number = double.parse(
          currentPrice.replaceAll('N\$', '').trim().replaceAll(',', ''));
      //...
      return (number * multiplier).toStringAsFixed(2);
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
        "country": userLocationDetails['country'] != null
            ? userLocationDetails['country']
            : 'Namibia',
        "city": userLocationDetails['city'] != null
            ? userLocationDetails['city']
            : 'Windhoek',
        "state": userLocationDetails['state'] != null
            ? userLocationDetails['state']
            : "Khomas",
        "user_fp": user_identifier
      };

      try {
        SuperHttp superHttp = SuperHttp();
        var response = await superHttp.post(mainUrl, body: bundleData);

        if (response.statusCode == 200) //Got some results
        {
          if (response.body.toString() == 'false') //No data
          {
            updateRealtimeLocationSuggestions(data: []);
          } else //Got some data
          {
            List<dynamic> tmpData = json.decode(response.body)['result'];
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
      userLocationDetails['coordinates'] =
          userLocationCoords; //? Very important
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
      log(location.toString());
      notifyListeners();
    } else if (location_type == 'dropoff') {
      manuallySettedCurrentLocation_dropoff = location;
      notifyListeners();
    }
  }

  //?16b. Update the manual location for the user - pickup or drop off - DELIVERY
  void updateManualPickupOrDropoff_delivery(
      {required String location_type, required Map<String, dynamic> location}) {
    if (location_type == 'pickup') {
      delivery_pickup = location;
      log(location.toString());
      notifyListeners();
    } else if (location_type == 'dropoff') {
      recipients_infos[selectedRecipient_index]['dropoff_location'] = location;
      notifyListeners();
    }
  }

  //?16c. Update the manual location for the user - pickup or drop off - RIDE
  //Index is the corresponding index for the drop off element
  void updateManualPickupOrDropoff_ride(
      {required String location_type, required Map<String, dynamic> location}) {
    if (location_type == 'pickup' || selectedRecipient_index == -1) {
      ride_location_pickup = location;
      notifyListeners();
    } else if (location_type == 'dropoff') {
      //! More passengers going the same way
      if (isGoingTheSameWay! && passengersNumber > 1) {
        ride_location_dropoff = []; //RESET

        for (var i = 0; i < passengersNumber; i++) {
          ride_location_dropoff.add(location);
        }
        notifyListeners();
      } else //Just 1 passenger
      {
        ride_location_dropoff[selectedLocationField_index] = location;
        notifyListeners();
      }
    }
  }

  //?16d. Clear the ride drop off, ride pickup location
  void clearPickupAndDropoffs() {
    ride_location_dropoff = [
      {'item': 0}
    ];
    ride_location_pickup = userLocationDetails;
    manuallySettedCurrentLocation_dropoff = {};
    manuallySettedCurrentLocation_pickup = {};
    //...
    notifyListeners();
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

  //?17b. Get manual location data - DELIVERY
  Map<String, dynamic> getManualLocationSetted_delivery(
      {required String location_type}) {
    if (location_type == 'pickup') {
      return delivery_pickup;
    } else {
      return recipients_infos[selectedRecipient_index]['dropoff_location'];
    }
  }

  //?17c. Get manual location data - RIDE
  //Index is the index of the corresponding drop off dield
  String getManualLocationSetted_ride(
      {required String location_type, int? index}) {
    DataParser _dataParser = DataParser();
    //...
    if (location_type == 'pickup') {
      // return ride_location_pickup;
      //! Auto initialize pickup location to current location if not set.
      ride_location_pickup = ride_location_pickup['street'] != null
          ? ride_location_pickup
          : userLocationDetails;
      //!.....
      return typedSearchLocation.isNotEmpty && selectedLocationField_index == -1
          ? typedSearchLocation
          : ride_location_pickup['street'] != null
              ? _dataParser
                      .getRealisticPlacesNames(
                          locationData: ride_location_pickup)['location_name']!
                      .isNotEmpty
                  ? _dataParser.getRealisticPlacesNames(
                      locationData: ride_location_pickup)['location_name']
                  : _dataParser.getRealisticPlacesNames(
                      locationData: ride_location_pickup)['suburb']
              : userLocationDetails['street'] != null
                  ? userLocationDetails['street'].toString().isNotEmpty
                      ? ''
                      : userLocationDetails['suburb']
                  : '';
    } else {
      if (index != null) {
        Map<String, dynamic> dropoff_data = ride_location_dropoff[index];
        //...
        return (typedSearchLocation.isNotEmpty &&
                    selectedLocationField_index == index
                ? typedSearchLocation
                : dropoff_data['street'] != null
                    ? _dataParser
                            .getRealisticPlacesNames(
                                locationData: dropoff_data)['location_name']!
                            .isNotEmpty
                        ? _dataParser.getRealisticPlacesNames(
                            locationData: dropoff_data)['location_name']
                        : _dataParser.getRealisticPlacesNames(
                            locationData: dropoff_data)['suburb']
                    : '')
            .toString();
      } else {
        return '';
      }
    }
  }

  //?18. Is manual pickup equal to the auto location
  bool isManualLocationEqualToTheAuto() {
    return mapEquals(manuallySettedCurrentLocation_pickup, userLocationDetails);
  }

  //?18b. Is manual pickup equal to the auto location
  bool isManualLocationEqualToTheAuto_ride() {
    return mapEquals(ride_location_pickup, userLocationDetails);
  }

  //?19. Update the typed note by the user
  void updateTypedUserNoteShopping({required String data}) {
    noteTyped = data;
    notifyListeners();
  }

  //?19b. Update the typed note by the user
  void updateTypedUserNoteDelivery({required String data}) {
    noteTyped_delivery = data;
    notifyListeners();
  }

  //! 20. GET TOTALS - SHOPPING
  Map<String, String> getTotals() {
    double cart = double.parse(getCartTotal().replaceAll('N\$', ''));
    double service_fee = 50.0;
    double cash_pickup_fee = paymentMethod == 'cash' ? 0 : 0;
    //...
    double total = (cart + service_fee + cash_pickup_fee).ceilToDouble();

    return {
      'cart': cart.toStringAsFixed(2),
      'service_fee': service_fee.toStringAsFixed(2),
      'cash_pickup_fee': cash_pickup_fee.toStringAsFixed(2),
      'total': total.toStringAsFixed(2),
    };
  }

  //! 20. GET TOTALS - DELIVERY
  Map<String, String> getTotals_delivery() {
    double unitPrice_delivery = 50;

    double delivery_fee = unitPrice_delivery * recipients_infos.length;
    double service_fee = 0;
    //...
    double total = (delivery_fee + service_fee).ceilToDouble();

    return {
      'delivery_fee': delivery_fee.toStringAsFixed(2),
      'service_fee': service_fee.toStringAsFixed(2),
      'total': total.toStringAsFixed(2),
    };
  }

  //?21. Update request loading status
  void updateLoadingRequestStatus({required bool status}) {
    isLoadingForRequest = status;
    notifyListeners();
  }

  //?22. Update realtime shopping data
  void updateRealtimeShoppingData({required List data}) {
    requestShoppingData = data;
    notifyListeners();
  }

  //?23. Lock request window state
  void updateRequestWindowLockState({required bool state}) {
    isThereARequestLockedIn['locked'] = state;
  }

  //?23.b Lock request window state - make an exception
  void updateRequestWindowLockState_makeException({required bool state}) {
    isThereARequestLockedIn['makeException'] = state;
  }

  //?24. Get recipient details based on the index and the nature of the data (name, phone or location)
  List getRecipientDetails_indexBased(
      {required int index, required String nature_data}) {
    switch (nature_data) {
      case 'name':
        String name = recipients_infos[index]['name'];
        return [name];
      case 'dropoff_location':
        Map location = recipients_infos[index]['dropoff_location'];
        return [location];
      default:
        return [];
    }
  }

  //? 25. Update selected country code
  void updateSelectedCountryCode({required Map dialData}) {
    selectedCountryCodeData = dialData;
    // log(dialData.toString());
    notifyListeners();
  }

  //? 26. Update entered phone number
  void updateEnteredPhoneNumber({required String phone}) {
    enteredPhoneNumber = phone;
    notifyListeners();
  }

  //?27. Update phone number status
  void updatePhoneNumberStatus() async {
    try {
      if (enteredPhoneNumber.isNotEmpty) {
        String phoneNumber =
            '${selectedCountryCodeData['dial_code']}${enteredPhoneNumber}';

        PhoneNumber plugin =
            PhoneNumber.parse(phoneNumber, callerCountry: IsoCode.NA);

        bool isValid = plugin.isValid();

        isPhoneEnteredValid = enteredPhoneNumber.isEmpty ? true : isValid;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  //?27b. Update phone number status - with a precise phone number
  void updatePhoneNumberStatus_custom({required String phone_custom}) async {
    try {
      String phoneNumber = phone_custom;

      if (phoneNumber.isNotEmpty) {
        PhoneNumber plugin =
            PhoneNumber.parse(phoneNumber, callerCountry: IsoCode.NA);

        bool isValid = plugin.isValid();
        isGenerally_phoneNumbersValid = isValid;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  //?28. Update the recipient index
  void updateSelected_recipient_index({required int index}) {
    selectedRecipient_index = index;
    notifyListeners();
  }

  //?29. Validate individual recipient data - not relative to the whole pack.
  Map<String, dynamic> validateRecipient_data_isolated({int? index = null}) {
    Map recipient = index != null
        ? recipients_infos[index]
        : recipients_infos[selectedRecipient_index];

    //!check the phone number
    updatePhoneNumberStatus();

    return recipient['name'].toString().isNotEmpty &&
            isPhoneEnteredValid &&
            recipient['dropoff_location']['street'] != null
        ? {'opacity': 1.0, 'actuator': 'back'}
        : {'opacity': 0.3, 'actuator': 'none'};
  }

  //?29b. Validate individual recipient data - Bulk
  Map<String, dynamic> validateRecipient_data_bulk() {
    List invalidRecipients = List.from(recipients_infos);

    invalidRecipients.removeWhere((element) {
      updatePhoneNumberStatus_custom(phone_custom: element['phone']);

      return element['name'].toString().isNotEmpty &&
          isGenerally_phoneNumbersValid &&
          element['dropoff_location']['street'] != null;
    });

    // print(invalidRecipients);

    return invalidRecipients.isEmpty
        ? {'opacity': 1.0, 'actuator': 'back'}
        : {'opacity': 0.3, 'actuator': 'none'};
  }

  //?30. Update the selected recipient name
  void updateSelected_recipientName({required String name}) {
    recipients_infos[selectedRecipient_index]['name'] = name;
    // notifyListeners();
  }

  //?31. Update the phone number of the selected recipient
  void updateSelectedRecipient_phone() {
    if (enteredPhoneNumber.isNotEmpty) {
      String phoneNumber =
          '${selectedCountryCodeData['dial_code']}${enteredPhoneNumber}';

      recipients_infos[selectedRecipient_index]['phone'] = phoneNumber;
    }
  }

  //?32. Clear the entered phone number
  void clearEnteredPhone_number() {
    enteredPhoneNumber = '';
    notifyListeners();
  }

  //?33. Add new receciver
  void addNewReceiver_delivery() {
    recipients_infos.add({
      'name': '',
      'phone': '',
      'dropoff_location': {'empty': 0}
    });
    //...
    notifyListeners();
  }

  //?34. Remove receiver if > 1
  void removeReceiver_delivery({required int index}) {
    recipients_infos.removeAt(index);
    notifyListeners();
  }

  //?35. Validate delivery pickup location
  Map<String, dynamic> validateDelivery_pickupLocation() {
    return delivery_pickup['street'] != null
        ? {'opacity': 1.0, 'actuator': 'back'}
        : {'opacity': 0.3, 'actuator': 'none'};
  }

  //!36. Update the selected service: ride, delivery and shopping
  void updateSelectedService({required String service}) {
    selectedService = service;
    notifyListeners();
  }

  //RIDE
  //?37. Update the passengers number
  void updatePassengersNumber({required int no}) {
    passengersNumber = no;
    //! Update the dropoff array for ride accordingly
    List<Map<String, dynamic>> newEls =
        List.generate(passengersNumber, (index) => {'item': index});
    //...
    ride_location_dropoff = newEls;

    notifyListeners();
  }

  //?38. Update if going the same way or not
  void updateGoingSameDestinationOrNot({required bool? value}) {
    isGoingTheSameWay = value;
    notifyListeners();
  }

  //?39. Update rise style: private or shared
  void updateRideStyle({required String value}) {
    rideStyle = value;
    notifyListeners();
  }

  //?40. Update typed note for driver - ride
  void updateTypedNote_ride({required String value}) {
    noteTyped_ride = value;
    notifyListeners();
  }

  //?41. Update the selected field for the location
  void updateSelectedLocationField_index({required int index}) {
    selectedLocationField_index = index;
    notifyListeners();
  }

  //?42. Get clean payment method name
  Map<String, String> getCleanPaymentMethod_nameAndImage({String? payment}) {
    if (payment != null) {
      return {
        'name': payment == 'cash' ? 'Cash' : 'Ewallet',
        'image': payment == 'mobile_money'
            ? 'assets/Images/mobile_payment.png'
            : 'assets/Images/banknote.png'
      };
    }

    return {
      'name': paymentMethod == 'cash' ? 'Cash' : 'Ewallet',
      'image': paymentMethod == 'mobile_money'
          ? 'assets/Images/mobile_payment.png'
          : 'assets/Images/banknote.png'
    };
  }

  //?43. Update route snapshot and eta
  void updateRouteSnaphotData({required Map<String, dynamic> rawSnap}) async {
    //? Convert the route point to be compatible with google maps
    List<LatLng> points = <LatLng>[];
    List snapsPoints = rawSnap['routePoints'];
    snapsPoints.forEach((e) {
      points.add(createLatLng(e[1], e[0]));
    });
    //...save
    routeSnapshotData = points;

    final String polylineIdVal = 'polyline_id_route_snapshot';
    final PolylineId polylineId = PolylineId(polylineIdVal);

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.black,
      endCap: Cap.buttCap,
      width: 4,
      zIndex: 100,
      points: points,
      onTap: () {
        // print(polylineId);
      },
    );
    //! Update
    polylines_snapshot[polylineId] = polyline;

    //   //? Create custom markers for origin and destination
    final originIcon = await placeToMarker(
        ride_location_pickup['location_name'].toString().length > 22
            ? '${ride_location_pickup['location_name'].toString().substring(0, 15)}...'
            : ride_location_pickup['location_name'].toString(),
        null);
    final destinationIcon = await placeToMarker(
      ride_location_dropoff[0]['location_name'].toString().length > 22
          ? '${ride_location_dropoff[0]['location_name'].toString().substring(0, 15)}...'
          : ride_location_dropoff[0]['location_name'].toString(),
      int.parse(rawSnap['eta'].toString().split(' ')[0]) *
          (rawSnap['eta'].toString().split(' ')[1] == 'min' ? 60 : 1),
    );

    const originId = MarkerId('origin');
    const destinationId = MarkerId('destination');

    final originMarker = Marker(
      markerId: originId,
      position: LatLng(double.parse(rawSnap['origin']['latitude']),
          double.parse(rawSnap['origin']['longitude'])),
      icon: originIcon,
      anchor: const Offset(1, 1.2),
    );

    final destinationMarker = Marker(
      markerId: destinationId,
      position: LatLng(double.parse(rawSnap['destination']['latitude']),
          double.parse(rawSnap['destination']['longitude'])),
      icon: destinationIcon,
      anchor: const Offset(0, 1.2),
    );

    //...Save
    markers_snapshot[originId] = originMarker;
    markers_snapshot[destinationId] = destinationMarker;

    //? Update the eta and origin & destination points
    eta_informationSnap['eta'] =
        rawSnap['eta'].toString().replaceAll(' away', '');
    eta_informationSnap['point1'] = rawSnap['origin'];
    eta_informationSnap['point2'] = rawSnap['destination'];
    //...
    notifyListeners();
  }

  LatLng createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }

  //?44. Update the pricing data in bulk
  void updatePricingData_bulk({required List data}) {
    pricing_computed = data;
    notifyListeners();
  }

  //?45. Update the selected pricing model
  void updateSelectedPricing_model({required Map<String, dynamic> data}) {
    selected_pricing_model = data;
    notifyListeners();
  }

  //?46. Update fare computation status
  void updateFareComputation_status({required bool status}) {
    isLoadingFor_fareComputation = status;
    notifyListeners();
  }

  //?47. Get the prices range in which the custom fare should lie in.
  Map getCustomFareRange() {
    //The maximum custom fare should be = base fare + (based Fare)*60%
    //The minimum custom fare should be = base fare + 1
    double baseFare =
        double.parse(selected_pricing_model['base_fare'].toString());
    double maximumCustomFare =
        baseFare + (baseFare * maximumPercentageCustomFareUpLimit);

    return {'max': maximumCustomFare.round(), 'min': baseFare.round() + 1};
  }

  //?48. Set custom fare value
  Map setCustomFareValue() {
    if (customFareEntered != null) //Good
    {
      //Check that the custom fare is within the acceptable range
      Map fareRange = getCustomFareRange();
      if (fareRange['min'] <= customFareEntered &&
          fareRange['max'] >= customFareEntered) //Clear
      {
        definitiveCustomFare = customFareEntered; //!Crucial
        isCustomFareConsidered = true;
        notifyListeners();
        return {'response': true};
      } else //Out of Range
      {
        notifyListeners();
        return {'response': 'out_of_range'};
      }
    } else //No value provided
    {
      notifyListeners();
      return {'response': 'no_change'};
    }
  }

  //?49. Remove custom fare previously set
  void removeCustomFare() {
    definitiveCustomFare = null; //!crucial
    customFareEntered = null;
    isCustomFareConsidered = false;
    notifyListeners();
  }

  //?50. Update the custom fare value on change
  void updateCustomFareValueOnChange({required double customFareValue}) {
    try {
      if (customFareValue > 0) {
        customFareEntered = customFareValue;
      } else //Set to null
      {
        customFareEntered = null;
      }
    } catch (e) {
      customFareEntered = customFareValue;
    }
    notifyListeners();
  }

  //?51. Update the typed key to search for items in shops
  void updateShopsKeyItemsSearch({required String value}) {
    shops_search_item_key = value;
    // print(value);
    notifyListeners();
  }

  //?52. Update the items searched results for shops
  void updateItemsSearchResults({required List<dynamic> value}) {
    shops_items_searched = value;
    notifyListeners();
  }

  //?53. Update loading items search in a store status
  void updateLoaderStatusItems_shop({required bool status}) {
    isLoadingForItemsSearch = status;
  }

  //?54. Update the typed key to search for stores
  void updateStoresKeyItemsSearch({required String value}) {
    stores_search_key = value;

    //!Filter the array
    List filteredStored = List.from(mainStores);
    filteredStored.removeWhere((el) =>
        el['name'].toString().toLowerCase().contains(value.toLowerCase()) ==
        false);
    //? Update the searched stores
    stores_searched = filteredStored;
    // print(filteredStored);

    notifyListeners();
  }

  //?55. Update the user data only if has no errors
  void updateUserDataErrorless({required Map<String, dynamic> data}) {
    if (data['user_identifier'] != null &&
        data['user_identifier'] != 'empty_fingerprint' &&
        DeepCollectionEquality().equals(data, userData) == false) //!Errorless
    {
      user_identifier = data['user_identifier'];
      userData = data;
      peristDataMap(); //! Paramount
      notifyListeners();
    }
  }

  //?56. Update login phase 1 data
  void updateLoginPhase1Data({required Map<String, dynamic> data}) {
    loginPhase1Data = data;
    //...
    notifyListeners();
  }

  //?57. Update the otp code
  void updateOTPCode({required String data}) {
    otp_code = data;
    notifyListeners();
  }

  //?58. Update additional new account infos
  void updateAdditionalAccountInfos(
      {required String data, required String type}) {
    switch (type) {
      case 'name':
        name = data;
        notifyListeners();
        break;
      case 'surname':
        surname = data;
        notifyListeners();
        break;
      case 'gender':
        gender = data;
        notifyListeners();
        break;
      case 'email':
        email = data;
        //! validate
        is_additional_emailValid = DataParser().isEmailValid(email: data);
        // print(is_additional_emailValid);
        notifyListeners();
        break;
      default:
    }
  }

  //!60. Update the general user indetifier
  void updateGeneral_userIdenfier({required String data}) {
    user_identifier = data;
    notifyListeners();
  }

  //?61. Update recently visited stores data
  void recentlyVisitedStores({required List data}) {
    recentlyVisitedShops = data;
    notifyListeners();
  }

  //?62. Update the pushnotif_token
  void updatePushnotification_token({required var data}) async {
    // log(data.toString());
    pushnotif_token = data;
    // peristDataMap();
    //...Upload
    Uri mainUrl =
        Uri.parse(Uri.encodeFull('$bridge/receivePushNotification_token'));

    Map<String, String> bundleData = {
      'pushnotif_token': json.encode(pushnotif_token).toString(),
      'user_identifier': user_identifier
    };

    try {
      SuperHttp superHttp = SuperHttp();
      var response = await superHttp.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        log(response.body.toString());
      } else //Has some errors
      {
        log(response.toString());
      }
    } catch (e) {
      log('8');
      log(e.toString());
    }
  }

  void requestBlockPushNotifToken() async {
    Uri mainUrl =
        Uri.parse(Uri.encodeFull('$bridge/receivePushNotification_token'));

    Map<String, String> bundleData = {
      'pushnotif_token': json.encode(pushnotif_token).toString(),
      'user_identifier': user_identifier
    };

    try {
      SuperHttp superHttp = SuperHttp();
      var response = await superHttp.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        log(response.body.toString());
      } else //Has some errors
      {
        log(response.toString());
      }
    } catch (e) {
      log('8');
      log(e.toString());
    }
  }

  //?37. Check if the driver has completed the delivery list - delivery
  bool isTheDeliveryListCompleted({required List packagesList}) {
    List newList = List.from(packagesList);
    newList.removeWhere((element) => element['isCompleted'] != null);

    return newList.isEmpty;
  }

  //?38. Check if the driver has completed the delivery list - shopping
  bool isTheShoppingListCompleted({required List packagesList}) {
    List newList = List.from(packagesList);
    newList.removeWhere((element) =>
        element['isCompleted'] != null || element['isNotFound'] != null);

    return newList.isEmpty;
  }

  //Check if the shopping list contains some items that are not found
  bool isTheShoppingListContainsItemsNotFound({required List packagesList}) {
    List newList = List.from(packagesList);
    newList.removeWhere((element) => element['isNotFound'] != true);

    return newList.isNotEmpty;
  }

  void updateVoucherAmountToPurchase({required int voucher}) {
    voucherAmountToPurchase = voucher;
  }

  void updateIsLoadingPurchaseVoucher({required bool isLoading}) {
    isLoadingPurchaseVoucher = isLoading;
    notifyListeners();
  }

  void updateWalletData(
      {required Map<String, dynamic> data, bool reset = false}) {
    if (!reset) {
      walletData = data;
    } else {
      walletData = {"balance": 0, "transactionHistory": []};
    }
    notifyListeners();
  }
}
