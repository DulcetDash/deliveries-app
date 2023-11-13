import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dulcetdash/components/Helpers/SuperHttp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:dulcetdash/ThemesAndRoutes/AppRoutes.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import '../Providers/HomeProvider.dart';

class GetShoppingData {
  //Get shopping data
  Future exec({required BuildContext context}) async {
    //? For the request
    //! Make sure that it has the correct user_identifier
    if (context.read<HomeProvider>().user_identifier == 'empty_fingerprint') {
      context
          .read<HomeProvider>()
          .getFileSavedFingerprintBack()
          .then((state) async {
        if (mapEquals({}, state['userData']) ||
            state['userData'] == null) //?No state saved yet
        {
          // log('No state saved found');
          // print('empty_fingerprint');
        } else //Found a saved state
        {
          //! user_identifier
          String userId = state['user_identifier'] != null
              ? state['user_identifier']
              : 'empty_fingerprint';
          //...
          Map<String, String> bundleData = {
            "user_identifier": userId,
          };
          //...
          requestBlock(context: context, bundleData: bundleData);
        }
      }).catchError((err) {
        // print('empty_fingerprint');
      });
    } else //Has normally the user id
    {
      Map<String, String> bundleData = {
        "user_identifier": context.read<HomeProvider>().user_identifier,
      };

      requestBlock(context: context, bundleData: bundleData);
    }
  }

  //Request
  void requestBlock(
      {required BuildContext context,
      required Map<String, String> bundleData}) async {
    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/getShoppingData'));
    //...
    try {
      SuperHttp superHttp = SuperHttp();
      var response = await superHttp.post(mainUrl, body: bundleData);

      // log(bundleData.toString());
      // log('${context.read<HomeProvider>().bridge}/getShoppingData');

      if (response.statusCode == 200) //Got some results
      {
        // print(response.body);
        if (response.body.toString() == 'false' ||
            response.body == false) //no data
        {
          context.read<HomeProvider>().updateRealtimeShoppingData(data: []);

          //? Move back to main screen if locked
          if (context.read<HomeProvider>().isThereARequestLockedIn['locked']!) {
            //! UNLOCK IN REQUEST WINDOW
            context
                .read<HomeProvider>()
                .updateRequestWindowLockState(state: false);
            //...
            Navigator.of(context).pushNamed('/home');
          }
        } else //? Found some data
        {
          List responseData = json.decode(response.body);

          if (DeepCollectionEquality().equals(
                      responseData[0],
                      context
                              .read<HomeProvider>()
                              .requestShoppingData
                              .isNotEmpty
                          ? context.read<HomeProvider>().requestShoppingData[0]
                          : {}) ==
                  false &&
              responseData.isNotEmpty) {
            context
                .read<HomeProvider>()
                .updateRealtimeShoppingData(data: responseData);
            log('REROUTE INSIDE');
            //! LOCK IN REQUEST WINDOW
            context
                .read<HomeProvider>()
                .updateRequestWindowLockState(state: true);
            //...
            //Reroute to the correct page based on the ride mode
            if (responseData[0]['ride_mode'] == 'SHOPPING') {
              Navigator.of(context).pushNamed('/requestWindow');
            } else if (responseData[0]['ride_mode'] == 'RIDE') {
              log('REROUTE RIDE');
              Navigator.of(context).pushNamed('/RequestWindow_ride');
            } else //DELIVERY
            {
              Navigator.of(context).pushNamed('/RequestWindow_delivery');
            }
          }
        }
      } else //Has some errors
      {
        // print(response.body);
        // print(response.body.toString());
        context.read<HomeProvider>().updateRealtimeShoppingData(data: []);
      }
    } catch (e) {
      log('8 - getShoppingData');
      log(e.toString());
      context.read<HomeProvider>().updateRealtimeShoppingData(data: []);
    }
  }
}

//?2. Get user data
class GetUserData {
  //Get shopping data
  Future exec({
    required BuildContext context,
  }) async {
    //? For the request
    //! Make sure that it has the correct user_identifier
    if (context.read<HomeProvider>().user_identifier == 'empty_fingerprint') {
      context
          .read<HomeProvider>()
          .getFileSavedFingerprintBack()
          .then((state) async {
        if (mapEquals({}, state['userData']) ||
            state['userData'] == null) //?No state saved yet
        {
          // log('No state saved found');
          // print('empty_fingerprint');
        } else //Found a saved state
        {
          //! user_identifier
          String userId = state['user_identifier'] != null
              ? state['user_identifier']
              : 'empty_fingerprint';
          //...
          Map<String, String> bundleData = {
            "user_identifier": userId,
          };
          //...
          requestBlock(context: context, bundleData: bundleData);
        }
      }).catchError((err) {
        // print('empty_fingerprint');
      });
    } else //Has normally the user id
    {
      Map<String, String> bundleData = {
        "user_identifier": context.read<HomeProvider>().user_identifier,
      };

      requestBlock(context: context, bundleData: bundleData);
    }
  }

  //Request
  void requestBlock(
      {required BuildContext context,
      required Map<String, String> bundleData}) async {
    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/getGenericUserData'));

    try {
      SuperHttp superHttp = SuperHttp();
      var response = await superHttp.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        Map<String, dynamic> tmpResponse =
            json.decode(response.body)['response'];
        context.read<HomeProvider>().updateUserDataErrorless(data: tmpResponse);
      } else //Has some errors
      {
        var decodedError = json.decode(response.body);
        if (decodedError['error'] == 'ipm') {
          context.read<HomeProvider>().clearEverything();
          //..
          Navigator.of(context).pushNamed('/Entry');
        }
      }
    } catch (e) {
      log('8 - getGenericUserData');
      log(e.toString());
    }
  }
}

//?2. Get recently visited store data
class GetRecentlyVisitedStores {
  //Get shopping data
  Future exec({
    required BuildContext context,
  }) async {
    //? For the request
    //! Make sure that it has the correct user_identifier
    if (context.read<HomeProvider>().user_identifier == 'empty_fingerprint') {
      context
          .read<HomeProvider>()
          .getFileSavedFingerprintBack()
          .then((state) async {
        if (mapEquals({}, state['userData']) ||
            state['userData'] == null) //?No state saved yet
        {
          // log('No state saved found');
          // print('empty_fingerprint');
        } else //Found a saved state
        {
          //! user_identifier
          String userId = state['user_identifier'] != null
              ? state['user_identifier']
              : 'empty_fingerprint';
          //...
          Map<String, String> bundleData = {
            "user_identifier": userId,
          };
          //...
          requestBlock(context: context, bundleData: bundleData);
        }
      }).catchError((err) {
        // print('empty_fingerprint');
      });
    } else //Has normally the user id
    {
      Map<String, String> bundleData = {
        "user_identifier": context.read<HomeProvider>().user_identifier,
      };

      requestBlock(context: context, bundleData: bundleData);
    }
  }

  //Request
  void requestBlock(
      {required BuildContext context,
      required Map<String, String> bundleData}) async {
    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/getRecentlyVisitedShops'));

    try {
      SuperHttp superHttp = SuperHttp();
      var response = await superHttp.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        // log(response.body.toString());
        List tmpResponse = json.decode(response.body)['response'];
        context.read<HomeProvider>().recentlyVisitedStores(data: tmpResponse);
      } else //Has some errors
      {
        log(response.body.toString());
      }
    } catch (e) {
      log('8 - getRecentlyVisitedShops');
      log(e.toString());
    }
  }
}
