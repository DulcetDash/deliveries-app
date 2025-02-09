import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class DataParser {
  //Get the realistic names for the location name, suburb and street name
  Map<String, String> getRealisticPlacesNames({required Map locationData}) {
    //? Essentials
    //! Autocomplete
    locationData['location_name'] = locationData['location_name'] != null
        ? locationData['location_name']
        : locationData['name'];
    locationData['street_name'] = locationData['street_name'] != null
        ? locationData['street_name']
        : locationData['street'];
    locationData['suburb'] = locationData['suburb'] != null
        ? locationData['suburb']
        : locationData['district'];
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
                : 'Finding your location';

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
      'suburb': suburb,
      'city': locationData['city'] != null ? locationData['city'] : '...'
    };
  }

  //Get a generic location String
  //! Should get a location parsed format ONLY!
  String getGenericLocationString({required Map<String, dynamic> location}) {
    String tmpFinal = location['location_name'].toString().isNotEmpty
        ? '${location['location_name']}, '
        : '';
    tmpFinal += location['street_name'].toString().isNotEmpty
        ? '${location['street_name']}, '
        : '';
    tmpFinal += location['suburb'].toString().isNotEmpty
        ? '${location['suburb']}, '
        : '';
    tmpFinal +=
        location['city'].toString().isNotEmpty ? '${location['city']}' : '';
    //...
    return tmpFinal;
  }

  //? Only upper the first char
  String ucFirst(String text) {
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  }

  //?. Get normal readable time
  String getReadableTime({required String dateString}) {
    DateTime dateTime = DateTime.parse(dateString);

    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  //? Get normal readable date
  String getReadableDate({required String dateString}) {
    DateTime dateTime = DateTime.parse(dateString);

    return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} at ${getReadableTime(dateString: dateString)}';
  }

  //? Validate email
  bool isEmailValid({required String email}) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  String capitalizeWords(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

class PhoneNumberCaller {
  static void callNumber({required String phoneNumber}) async {
    await FlutterPhoneDirectCaller.callNumber(phoneNumber);
  }
}
