import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../Providers/HomeProvider.dart';

class GetShoppingData {
  //Get shopping data
  Future exec({required BuildContext context}) async {
    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/getShoppingData'));

    //? For the request
    Map<String, String> bundleData = {
      "user_identifier": context.read<HomeProvider>().user_identifier,
    };

    try {
      Response response = await post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
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
          // print(response.body);
          List responseData = json.decode(response.body);
          context
              .read<HomeProvider>()
              .updateRealtimeShoppingData(data: responseData);
          //? MOVE TO THE REQUEST WINDOW
          if (context.read<HomeProvider>().isThereARequestLockedIn['locked'] ==
                  false &&
              context
                      .read<HomeProvider>()
                      .isThereARequestLockedIn['makeException'] ==
                  false) //!Auto redirect to the request windhoek
          {
            //! LOCK IN REQUEST WINDOW
            context
                .read<HomeProvider>()
                .updateRequestWindowLockState(state: true);
            //...
            //Reroute to the correct page based on the ride mode
            if (responseData[0]['ride_mode'] == 'SHOPPING') {
              Navigator.of(context).pushNamed('/requestWindow');
            } else if (responseData[0]['ride_mode'] == 'RIDE') {
              Navigator.of(context).pushNamed('/RequestWindow_ride');
            } else //DELIVERY
            {
              print('Reroute to the delivery request window.');
            }
          }
        }
      } else //Has some errors
      {
        log(response.toString());
        context.read<HomeProvider>().updateRealtimeShoppingData(data: []);
      }
    } catch (e) {
      log('8');
      log(e.toString());
      context.read<HomeProvider>().updateRealtimeShoppingData(data: []);
    }
  }
}
