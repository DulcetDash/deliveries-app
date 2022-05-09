//Responsible for taking any function and spining it up in a specified interval.

// ignore_for_file: file_names

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

class Watcher with ChangeNotifier {
  // Duration? timerInterval = const Duration(seconds: 2);
  late Timer mainLoop;

  // Watcher({required this.actuatorFunctions, this.timerInterval});

  void startWatcher(
      {required List<dynamic> actuatorFunctions,
      Duration? timerInterval = const Duration(seconds: 2),
      required BuildContext context}) {
    //Start the timer
    mainLoop = Timer.periodic(timerInterval!, (Timer t) {
      for (int i = 0; i < actuatorFunctions.length; i++) {
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
