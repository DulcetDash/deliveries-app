// ignore_for_file: file_names

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dulcetdash/components/Delivery/RequestWindow_delivery.dart';
import 'package:dulcetdash/components/Helpers/LocationOpsHandler.dart';
import 'package:dulcetdash/components/Helpers/Networking.dart';
import 'package:dulcetdash/components/Helpers/Watcher.dart';
import 'package:dulcetdash/components/Login/CreateAccount.dart';
import 'package:dulcetdash/components/Login/Entry.dart';
import 'package:dulcetdash/components/Login/Language.dart';
import 'package:dulcetdash/components/Login/NewAccountAddiDetails.dart';
import 'package:dulcetdash/components/Login/OTPCheck.dart';
import 'package:dulcetdash/components/Login/PhoneInput.dart';
import 'package:dulcetdash/components/Login/SplashScreen.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:dulcetdash/components/Ride/FareDisplay.dart';
import 'package:dulcetdash/components/Ride/RequestWindow_ride.dart';
import 'package:dulcetdash/components/Ride/RideSummary.dart';
import 'package:dulcetdash/components/Settings/OTPCheckChange.dart';
import 'package:dulcetdash/components/Settings/PhoneInputChange.dart';
import 'package:dulcetdash/components/Settings/Settings.dart';
import 'package:dulcetdash/components/Share/Share.dart';
import 'package:dulcetdash/components/Shopping/Catalogue.dart';
import 'package:dulcetdash/components/Shopping/CatalogueDetailsL2.dart';
import 'package:dulcetdash/components/Delivery/DelRecipients.dart';
import 'package:dulcetdash/components/Delivery/DeliveryPickupLocation.dart';
import 'package:dulcetdash/components/Delivery/DeliverySummary.dart';
import 'package:dulcetdash/components/Shopping/ShoppingSummary.dart';
import 'package:dulcetdash/components/Ride/InitialPassengers.dart';
import 'package:dulcetdash/components/Shopping/Cart.dart';
import 'package:dulcetdash/components/Shopping/Home.dart';
import 'package:dulcetdash/components/HomeScreen.dart';
import 'package:dulcetdash/components/Shopping/LocationDetails.dart';
import 'package:dulcetdash/components/PaymentSetting.dart';
import 'package:dulcetdash/components/Shopping/ProductView.dart';
import 'package:dulcetdash/components/Shopping/RequestWindow.dart';
import 'package:dulcetdash/components/SuccessRequest.dart';
import 'package:dulcetdash/components/Support/Support.dart';
import 'package:dulcetdash/components/YourRides/YourRides.dart';
import 'package:provider/src/provider.dart';
import 'package:dulcetdash/ThemesAndRoutes/AppTheme.dart' as AppTheme;

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
  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).viewInsets.bottom;

    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: MaterialApp(
          // debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
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
            '/Language': (context) => const Language(),
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
            '/Settings': (context) => const Settings(),
            '/PhoneInputChange': (context) => const PhoneInputChange(),
            '/OTPCheckChange': (context) => const OTPCheckChange()
          }),
    );
  }
}
