// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:nej/components/Delivery/RequestWindow_delivery.dart';
import 'package:nej/components/Helpers/LocationOpsHandler.dart';
import 'package:nej/components/Helpers/Networking.dart';
import 'package:nej/components/Helpers/Watcher.dart';
import 'package:nej/components/Login/CreateAccount.dart';
import 'package:nej/components/Login/Entry.dart';
import 'package:nej/components/Login/NewAccountAddiDetails.dart';
import 'package:nej/components/Login/OTPCheck.dart';
import 'package:nej/components/Login/PhoneInput.dart';
import 'package:nej/components/Login/SplashScreen.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:nej/components/Ride/FareDisplay.dart';
import 'package:nej/components/Ride/RequestWindow_ride.dart';
import 'package:nej/components/Ride/RideSummary.dart';
import 'package:nej/components/Settings/Settings.dart';
import 'package:nej/components/Share/Share.dart';
import 'package:nej/components/Shopping/Catalogue.dart';
import 'package:nej/components/Shopping/CatalogueDetailsL2.dart';
import 'package:nej/components/Delivery/DelRecipients.dart';
import 'package:nej/components/Delivery/DeliveryPickupLocation.dart';
import 'package:nej/components/Delivery/DeliverySummary.dart';
import 'package:nej/components/Shopping/ShoppingSummary.dart';
import 'package:nej/components/Ride/InitialPassengers.dart';
import 'package:nej/components/Shopping/Cart.dart';
import 'package:nej/components/Shopping/Home.dart';
import 'package:nej/components/HomeScreen.dart';
import 'package:nej/components/Shopping/LocationDetails.dart';
import 'package:nej/components/PaymentSetting.dart';
import 'package:nej/components/Shopping/ProductView.dart';
import 'package:nej/components/Shopping/RequestWindow.dart';
import 'package:nej/components/SuccessRequest.dart';
import 'package:nej/components/Support/Support.dart';
import 'package:nej/components/YourRides/YourRides.dart';
import 'package:provider/src/provider.dart';
import 'package:nej/ThemesAndRoutes/AppTheme.dart' as AppTheme;

import '../Components/Providers/RegistrationProvider.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class AppGeneralEntry extends StatefulWidget {
  const AppGeneralEntry({Key? key}) : super(key: key);

  @override
  _AppGeneralEntryState createState() => _AppGeneralEntryState();
}

class _AppGeneralEntryState extends State<AppGeneralEntry> {
  // Create a new networking instance
  late LocationOpsHandler locationOpsHandler;
  GetShoppingData _getShoppingData = GetShoppingData();
  GetUserData _getUserData = GetUserData();
  GetRecentlyVisitedStores _getRecentlyVisitedStores =
      GetRecentlyVisitedStores();
  Watcher watcher = Watcher();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //Start with the timers
    //Location operation handlers
    locationOpsHandler = LocationOpsHandler(context: context);
    //Ask once for the location permission
    locationOpsHandler.requestLocationPermission();
    //globalDataFetcher.getCoreDate(context: context);
    watcher.startWatcher(context: context, actuatorFunctions: [
      {'name': 'LocationOpsHandler', 'actuator': locationOpsHandler},
      {'name': 'getShoppingData', 'actuator': _getShoppingData},
      {'name': 'getUserData', 'actuator': _getUserData},
      {
        'name': 'getRecentlyVisitedStores',
        'actuator': _getRecentlyVisitedStores
      }
    ]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locationOpsHandler.dispose();
    watcher.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        theme: AppTheme.appTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          //Login
          '/Entry': (context) => const Entry(),
          '/PhoneInput': (context) => const PhoneInput(),
          '/OTPCheck': (context) => const OTPCheck(),
          '/CreateAccount': (context) => const CreateAccount(),
          '/NewAccountDetails': (context) => const NewAccountAddiDetails(),
          //Core
          '/home': (context) => const HomeScreen(),
          '/shopping': (context) => const Home(),
          '/catalogue': (context) => const Catalogue(),
          '/catalogue_details_l2': (context) => const CatalogueDetailsL2(),
          '/product_view': (context) => const ProductView(),
          '/cart': (context) => const Cart(),
          '/paymentSetting': (context) =>
              const PaymentSetting(), //? SHARED PAGE
          '/locationDetails': (context) => const LocationDetails(),
          '/ShoppingSummary': (context) => const ShoppingSummary(),
          '/successfulRequest': (context) => const SuccessRequest(),
          '/requestWindow': (context) => const RequestWindow(),
          //Delivery
          '/delivery_recipients': (context) => const DelRecipients(),
          '/delivery_pickupLocation': (context) =>
              const DeliveryPickupLocation(),
          '/DeliverySummary': (context) => const DeliverySummary(),
          '/RequestWindow_delivery': (context) =>
              const RequestWindow_delivery(),
          //Ride
          '/PassengersInput': (context) => const InitialPassengers(),
          '/FareDisplay': (context) => const FareDisplay(),
          '/RideSummary': (context) => const RideSummary(),
          '/RequestWindow_ride': (context) => const RequestWindow_ride(),
          //Share
          '/Share': (context) => const Share(),
          //Support
          '/Support': (context) => const Support(),
          //YourRides
          '/YourRides': (context) => const YourRides(),
          //Settings
          '/Settings': (context) => const Settings()
        });
  }
}
