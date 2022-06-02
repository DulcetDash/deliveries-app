// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:nej/components/Cart.dart';
import 'package:nej/components/Catalogue.dart';
import 'package:nej/components/CatalogueDetailsL2.dart';
import 'package:nej/components/DelRecipients.dart';
import 'package:nej/components/DeliveryPickupLocation.dart';
import 'package:nej/components/DeliverySummary.dart';
import 'package:nej/components/Home.dart';
import 'package:nej/components/HomeScreen.dart';
import 'package:nej/components/LocationDetails.dart';
import 'package:nej/components/PaymentSetting.dart';
import 'package:nej/components/ProductView.dart';
import 'package:nej/components/Shopping/RequestWindow.dart';
import 'package:nej/components/ShoppingSummary.dart';
import 'package:nej/components/SuccessRequest.dart';
import 'package:provider/src/provider.dart';
import 'package:nej/ThemesAndRoutes/AppTheme.dart' as AppTheme;

import '../Components/Providers/RegistrationProvider.dart';

class AppGeneralEntry extends StatefulWidget {
  const AppGeneralEntry({Key? key}) : super(key: key);

  @override
  _AppGeneralEntryState createState() => _AppGeneralEntryState();
}

class _AppGeneralEntryState extends State<AppGeneralEntry> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: AppTheme.appTheme,
        initialRoute: '/DeliverySummary',
        routes: {
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
          '/DeliverySummary': (context) => const DeliverySummary()
        });
  }
}
