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
                : 'Finding location';

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
}
