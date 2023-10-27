// ignore_for_file: file_names

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:provider/src/provider.dart';

class RequestCardHelper {
  //?1. Fit destination widgets to List
  List<Widget> fitLocationWidgetsToList(
      {required BuildContext context,
      required List<dynamic> locationData,
      String fontFamily = 'MoveTextMedium',
      double fontSize = 16}) {
    List<Widget> finalCompilation = [];

    for (int i = 0; i < locationData.length; i++) {
      //? Essentials
      if (locationData[i] == null) continue;
      //1. Suburb
      String suburb = locationData[i]['suburb'] != false &&
              locationData[i]['suburb'] != 'false' &&
              locationData[i]['suburb'] != null
          ? locationData[i]['suburb']
          : locationData[i]['location_name'] != false &&
                  locationData[i]['location_name'] != 'false' &&
                  locationData[i]['location_name'] != null
              ? locationData[i]['location_name']
              : locationData[i]['street_name'] != false &&
                      locationData[i]['street_name'] != 'false' &&
                      locationData[i]['street_name'] != null
                  ? locationData[i]['street_name']
                  : 'Unclear location';

      //2. Location name
      String location_name = locationData[i]['location_name'] != false &&
              locationData[i]['location_name'] != 'false' &&
              locationData[i]['location_name'] != null
          ? locationData[i]['location_name'] != suburb
              ? locationData[i]['location_name']
              : ''
          : locationData[i]['street_name'] != false &&
                  locationData[i]['street_name'] != 'false' &&
                  locationData[i]['street_name'] != null
              ? locationData[i]['street_name']
              : '';

      //3. Street name
      String street_name = locationData[i]['street_name'] != false &&
              locationData[i]['street_name'] != 'false' &&
              locationData[i]['street_name'] != null
          ? locationData[i]['street_name'] != suburb &&
                  locationData[i]['street_name'] != location_name
              ? locationData[i]['street_name']
              : ''
          : '';

      //? ---
      Widget tempPass = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: locationData.length > 1,
            child: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Text('${i + 1}.',
                  style: TextStyle(
                      color: AppTheme().getSecondaryColor(), fontSize: 17)),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Text(suburb,
                        style: TextStyle(
                            fontFamily: fontFamily, fontSize: fontSize)),
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                          '$location_name${location_name.isNotEmpty && street_name.isNotEmpty ? ', ' : ''}$street_name',
                          style: const TextStyle(
                              fontSize: 15, fontFamily: 'MoveTextLight')))
                ],
              ),
            ),
          )
        ],
      );

      //Save
      finalCompilation.add(tempPass);
    }
    //DONE
    return finalCompilation;
  }

  //Get the realistic names for the location name, suburb and street name
  Map<String, String> getRealisticPlacesNames({required Map locationData}) {
    //? Essentials
    //1. Suburb
    String suburb = locationData['suburb'] != false &&
            locationData['suburb'] != 'false' &&
            locationData['suburb'] != null
        ? locationData['suburb']
        : locationData['location_name'] != false &&
                locationData['location_name'] != 'false' &&
                locationData['location_name'] != null
            ? locationData['location_name']
            : locationData['street_name'] != false &&
                    locationData['street_name'] != 'false' &&
                    locationData['street_name'] != null
                ? locationData['street_name']
                : 'Unclear location';

    //2. Location name
    String location_name = locationData['location_name'] != false &&
            locationData['location_name'] != 'false' &&
            locationData['location_name'] != null
        ? locationData['location_name'] != suburb
            ? locationData['location_name']
            : ''
        : locationData['street_name'] != false &&
                locationData['street_name'] != 'false' &&
                locationData['street_name'] != null
            ? locationData['street_name']
            : '';

    //3. Street name
    String street_name = locationData['street_name'] != false &&
            locationData['street_name'] != 'false' &&
            locationData['street_name'] != null
        ? locationData['street_name'] != suburb &&
                locationData['street_name'] != location_name
            ? locationData['street_name']
            : ''
        : '';

    //? ---

    return {
      'location_name': location_name,
      'street_name': street_name,
      'suburb': suburb
    };
  }
}

class DisplayCarInformation extends StatelessWidget {
  EdgeInsetsGeometry padding;
  final String plateNumber;
  final String carBrand;
  final String carImageURL;

  DisplayCarInformation(
      {Key? key,
      this.padding = EdgeInsets.zero,
      required this.plateNumber,
      required this.carBrand,
      required this.carImageURL})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ListTile(
        // contentPadding: EdgeInsets.zero,
        leading: Container(
          width: MediaQuery.of(context).size.width * 0.3,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
              border:
                  Border.all(width: 1, color: Colors.grey.withOpacity(0.2))),
          child: Image.network(
            carImageURL,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width * 0.3,
              alignment: Alignment.center,
              child: Image.asset('assets/Images/normalTaxiEconomy.jpeg'),
            ),
          ),
        ),
        title: Text(
          plateNumber,
          style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 17),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(carBrand),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Row(
                  children: [
                    Icon(Icons.shield,
                        size: 13, color: Color.fromRGBO(9, 134, 74, 1)),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      "utils.checked".tr(),
                      style: TextStyle(color: Color.fromRGBO(9, 134, 74, 1)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
