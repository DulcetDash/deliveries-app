// ignore_for_file: file_names

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:nej/components/Helpers/PositionConverter.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';

class LocationOpsHandler with ChangeNotifier {
  //? Attributes - very important
  final BuildContext context;
  //...
  LocationOpsHandler({required this.context});
  //Location location = new Location();
  Duration intervalRecurrence = Duration(seconds: 2);

  //?1. Continuously get the location service status and permission status of the user.
  //Responsible for cheking the location service and permission status.
  Future<Map> healthCheckServiceAndPermission() async {
    if (context
            .read<HomeProvider>()
            .locationServicesStatus['isLocationServiceEnabled'] ==
        false) //Location service disabled
    {
      return {
        'isLocationServiceEnabled': context
            .read<HomeProvider>()
            .locationServicesStatus['isLocationServiceEnabled'],
        'isLocationPermissionGranted': context
            .read<HomeProvider>()
            .locationServicesStatus['isLocationPermissionGranted']
      };
    }
    //...
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission.toString() != 'LocationPermission.whileInUse' &&
        permission.toString() !=
            'LocationPermission.always') //Permission denied
    {
      return {
        'isLocationServiceEnabled': context
            .read<HomeProvider>()
            .locationServicesStatus['isLocationServiceEnabled'],
        'isLocationPermissionGranted': false
      };
    }

    //All good
    return {
      'isLocationServiceEnabled': true,
      'isLocationPermissionGranted': true
    };
  }

  //? 2. Get the  user's location details
  //Responsible for getting the user's latitude and logitude, or any other location related infos.
  Future getUserLocation({bool shouldGetNewLocation = true}) async {
    if (shouldGetNewLocation) {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
    } else //Get the last known location - useful especially when a permission is denied
    {
      Completer completer = Completer();

      completer.complete(false);
      return completer.future;
    }
  }

  //? 3. Request location permission
  void requestLocationPermission({bool isUserTriggered = false}) async {
    LocationPermission permission = await Geolocator.checkPermission();

    // log(permission.toString());

    if (permission.toString() ==
        'LocationPermission.deniedForever') //Denied forever - access settings
    {
      //UPdate the denied forever status
      context
          .read<HomeProvider>()
          .updateGPRSServiceStatusAndLocationPermissions(
              gprsServiceStatus: context
                  .read<HomeProvider>()
                  .locationServicesStatus['isLocationServiceEnabled'],
              locationPermission: context
                  .read<HomeProvider>()
                  .locationServicesStatus['isLocationPermissionGranted'],
              isDeniedForever: true);
      //....
      if (isUserTriggered) {
        //Only open the settings if the request action is user triggered.
        await Geolocator.openAppSettings();
        await Geolocator.openLocationSettings();
      }
    } else if (permission.toString() != 'LocationPermission.whileInUse' &&
        permission.toString() != 'LocationPermission.always') {
      //UPdate the denied forever status
      context
          .read<HomeProvider>()
          .updateGPRSServiceStatusAndLocationPermissions(
              gprsServiceStatus: context
                  .read<HomeProvider>()
                  .locationServicesStatus['isLocationServiceEnabled'],
              locationPermission: context
                  .read<HomeProvider>()
                  .locationServicesStatus['isLocationPermissionGranted'],
              isDeniedForever: false);
      //....
      if (context.read<HomeProvider>().didAutomaticallyAskedForGprsPerm ==
          false) //Ask only once by default
      {
        //Update the auto ask state
        context.read<HomeProvider>().updateAutoAskGprsCoords(didAsk: true);
        //...
        LocationPermission requestForPermission =
            await Geolocator.requestPermission();
        //Auto update the new values
        if (requestForPermission.toString() ==
                'LocationPermission.whileInUse' ||
            requestForPermission.toString() == 'LocationPermission.always') {
          context
              .read<HomeProvider>()
              .updateGPRSServiceStatusAndLocationPermissions(
                  gprsServiceStatus: true,
                  locationPermission: true,
                  isDeniedForever: false);
        }
      }
    } else if (permission.toString() == 'LocationPermission.whileInUse' ||
        permission.toString() == 'LocationPermission.always') {
      //Activate the platform
      context
          .read<HomeProvider>()
          .updateGPRSServiceStatusAndLocationPermissions(
              gprsServiceStatus: true,
              locationPermission: true,
              isDeniedForever: false);
    }
  }

  //? 5 . Geocode the current point
  void geocodeThisPoint(
      {required double latitude, required double longitude}) async {
    String urlString =
        '${context.read<HomeProvider>().bridge}/geocode_this_point';

    Map<String, String> bundleData = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'user_fingerprint': context.read<HomeProvider>().user_identifier
    };

    // log(urlString);
    try {
      Response response =
          await post(Uri.parse(Uri.encodeFull(urlString)), body: bundleData);

      if (response.statusCode == 200 &&
          json.decode(response.body).runtimeType != bool) {
        // log(response.body);
        if (context.toString().contains('no widget') == false) {
          context.read<HomeProvider>().updateUsersCurrentLocation(
              newCurrentLocation: json.decode(response.body));
        }
      } else //Some error
      {
        // print(response.statusCode);
      }
    } catch (e) {
      log('7');
      log(e.toString());
    }
  }

  //! Runner function
  void runLocationOpasHandler() {
    PositionConverter positionConverter = PositionConverter();

    //a. Check the permissions
    Future healthCheck = healthCheckServiceAndPermission();
    healthCheck.then((status) {
      // print(context.read<HomeProvider>().locationServicesStatus.toString());
      //? Update the state if necessary
      context
          .read<HomeProvider>()
          .updateGPRSServiceStatusAndLocationPermissions(
              gprsServiceStatus: status['isLocationServiceEnabled'],
              locationPermission: status['isLocationPermissionGranted'],
              isDeniedForever: context
                  .read<HomeProvider>()
                  .locationServicesStatus['isLocationDeniedForever']);
      //....
      if (status['isLocationServiceEnabled'] &&
          status[
              'isLocationPermissionGranted']) //Has full permission - get the coordinates
      {
        // print('All permissions approved');
        Future userPosition = getUserLocation();
        userPosition.then((value) {
          if (value != null) {
            value =
                positionConverter.parseToMap(positionString: value.toString());

            context.read<HomeProvider>().updateRidersLocationCoordinates(
                latitude: value['latitude'], longitude: value['longitude']);

            //Geocode the point
            geocodeThisPoint(
                latitude: value['latitude'], longitude: value['longitude']);
          }
        });
      } else //Is missing one Permission - get the last coordinates
      {
        print('Some permissions are missing - lock the interface');
        requestLocationPermission();
      }
    });
  }
}
