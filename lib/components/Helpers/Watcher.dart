//Responsible for taking any function and spining it up in a specified interval.

// ignore_for_file: file_names

import 'dart:async';
import 'dart:developer';

import 'package:dulcetdash/components/Helpers/SecureStorageService.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Watcher with ChangeNotifier {
  // Duration? timerInterval = const Duration(seconds: 2);
  late Timer mainLoop;

  // Watcher({required this.actuatorFunctions, this.timerInterval});

  void startWatcher(
      {required List<dynamic> actuatorFunctions,
      Duration? timerInterval = const Duration(seconds: 10),
      required BuildContext context}) {
    //Start the timer
    mainLoop = Timer.periodic(timerInterval!, (Timer t) async {
      for (int i = 0; i < actuatorFunctions.length; i++) {
        String? permaToken =
            await SecureStorageService().getValue('permaToken');

        if (permaToken == null) {
          log('No valid context detected! - skipping timer');
          continue;
        }

        if (context.read<HomeProvider>().user_identifier ==
            'empty_fingerprint') {
          log('No valid fingerprint detected! - skipping timers');
          continue;
        }

        //? Structure
        // {name:'data fetcher name', actuator: Specific class instance child}
        //Call the tmp function
        try {
          RegExp cleanerCheck = RegExp(r"no widget", caseSensitive: false);

          if (cleanerCheck.hasMatch(context.toString()) == false) {
            switch (actuatorFunctions[i]['name']) {
              case 'LocationOpsHandler':
                actuatorFunctions[i]['actuator'].runLocationOpasHandler();
                break;
              case 'getShoppingData':
                actuatorFunctions[i]['actuator'].exec(context: context);
                break;
              case 'getUserData':
                actuatorFunctions[i]['actuator'].exec(context: context);
                break;
              case 'getRecentlyVisitedStores':
                actuatorFunctions[i]['actuator'].exec(context: context);
                break;
              default:
            }
          } else //No valid context
          {
            log('No valid context detected! - try to dispose the timer');
            mainLoop.cancel();
          }
        } catch (e) {
          log('1');
          log(e.toString());
        }
      }
    });
  }
}
