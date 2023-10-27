// ignore_for_file: file_names

class PositionConverter {
  //Parse to Map
  //The user position in the form Latitude: 17.081047,  Longitude: -22.570695
  Map<String, double> parseToMap({required positionString}) {
    List tmpList = positionString.split(',');
    List tmpLatitude = tmpList[0].split(':'); //Latitude
    List tmpLongitude = tmpList[1].split(':'); //Longitude

    Map<String, double> finalPosition = new Map();
    finalPosition[tmpLatitude[0].toString().trim().toLowerCase()] =
        double.parse(tmpLatitude[1]); //Latitude
    finalPosition[tmpLongitude[0].toString().trim().toLowerCase()] =
        double.parse(tmpLongitude[1]); //Longitude

    return finalPosition;
  }
}
