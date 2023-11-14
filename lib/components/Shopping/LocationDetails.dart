import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:dulcetdash/components/GenericRectButton.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Helpers/DataParser.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';

class LocationDetails extends StatefulWidget {
  const LocationDetails({Key? key}) : super(key: key);

  @override
  State<LocationDetails> createState() => _LocationDetailsState();
}

class _LocationDetailsState extends State<LocationDetails> {
  DataParser _dataParser = DataParser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(
          children: [
            Header(),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: ListView(
                    children: [
                      LocationChoice(
                          title: 'delivery.whereAreYouTitle'.tr(),
                          subtitle: context
                                          .watch<HomeProvider>()
                                          .manuallySettedCurrentLocation_pickup[
                                      'street'] !=
                                  null
                              ? _dataParser.getGenericLocationString(
                                  location: _dataParser.getRealisticPlacesNames(
                                      locationData: context
                                          .watch<HomeProvider>()
                                          .manuallySettedCurrentLocation_pickup))
                              : 'generic_text.enterAddress_label'.tr(),
                          checked: context
                                      .watch<HomeProvider>()
                                      .manuallySettedCurrentLocation_pickup[
                                  'street'] !=
                              null,
                          actuator: () => showMaterialModalBottomSheet(
                                backgroundColor: Colors.white,
                                bounce: true,
                                duration: Duration(milliseconds: 250),
                                context: context,
                                builder: (context) => LocalModal(
                                  scenario: 'pickup',
                                ),
                              )),
                      Divider(
                        height: 40,
                      ),
                      LocationChoice(
                          title: 'delivery.deliveryLocation_label'.tr(),
                          subtitle: context
                                          .watch<HomeProvider>()
                                          .manuallySettedCurrentLocation_dropoff[
                                      'street'] !=
                                  null
                              ? _dataParser.getGenericLocationString(
                                  location: _dataParser.getRealisticPlacesNames(
                                      locationData: context
                                          .watch<HomeProvider>()
                                          .manuallySettedCurrentLocation_dropoff))
                              : 'delivery.whereToDropOff_description'.tr(),
                          checked: context
                                      .watch<HomeProvider>()
                                      .manuallySettedCurrentLocation_dropoff[
                                  'street'] !=
                              null,
                          actuator: () => showMaterialModalBottomSheet(
                                backgroundColor: Colors.white,
                                bounce: true,
                                duration: Duration(milliseconds: 250),
                                context: context,
                                builder: (context) => LocalModal(
                                  scenario: 'dropoff',
                                ),
                              )),
                      Divider(
                        height: 40,
                      ),
                      LocationChoice(
                        title: 'delivery.addNote'.tr(),
                        subtitle:
                            context.read<HomeProvider>().noteTyped.isNotEmpty
                                ? context.read<HomeProvider>().noteTyped
                                : 'shopping.shoppingNotePlaceholder'.tr(),
                        actuator: () => showMaterialModalBottomSheet(
                          backgroundColor: Colors.white,
                          bounce: true,
                          duration: Duration(milliseconds: 250),
                          context: context,
                          builder: (context) => LocalModal(
                            scenario: 'note',
                          ),
                        ),
                        tracked: false,
                      ),
                    ],
                  )),
            ),
            Opacity(
              opacity: isDataAllowingNex(context: context) ? 1 : 0.3,
              child: GenericRectButton(
                  label: 'generic_text.next'.tr(),
                  labelFontSize: 22,
                  actuatorFunctionl: isDataAllowingNex(context: context)
                      ? () {
                          Navigator.of(context).pushNamed('/ShoppingSummary');
                        }
                      : () {}),
            )
          ],
        )));
  }

  //? Is data allowing next
  bool isDataAllowingNex({required BuildContext context}) {
    return context
                .watch<HomeProvider>()
                .manuallySettedCurrentLocation_pickup['street'] !=
            null &&
        context
                .watch<HomeProvider>()
                .manuallySettedCurrentLocation_dropoff['street'] !=
            null;
  }
}

//Header
class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 20, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back,
                          size: AppTheme().getArrowBackSize()),
                      SizedBox(
                        width: 4,
                      ),
                      Text('new_account.fewMoteThings'.tr(),
                          style: TextStyle(
                              fontFamily: 'MoveTextBold', fontSize: 24))
                    ],
                  ),
                )
              ],
            ),
            Divider(
              height: 40,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}

//Location choice
class LocationChoice extends StatelessWidget {
  final String title;
  final String subtitle;
  final actuator;
  final bool tracked;
  final bool checked;

  const LocationChoice(
      {Key? key,
      required this.title,
      this.subtitle = '',
      required this.actuator,
      this.tracked = true,
      this.checked = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        // color: Colors.red,
        alignment: Alignment.centerLeft,
        child: ListTile(
          onTap: actuator,
          contentPadding: EdgeInsets.zero,
          horizontalTitleGap: -5,
          leading: tracked
              ? Icon(
                  Icons.check_circle,
                  color: checked ? AppTheme().getPrimaryColor() : Colors.grey,
                )
              : Text(''),
          title: Text(
            title,
            style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 18),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              subtitle,
              style: TextStyle(
                  fontSize: 16,
                  color: checked
                      ? AppTheme().getPrimaryColor()
                      : Colors.grey.shade500),
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: checked ? Colors.grey : AppTheme().getPrimaryColor(),
          ),
        ));
  }
}

//Local modal
class LocalModal extends StatelessWidget {
  final String scenario;

  const LocalModal({Key? key, required this.scenario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (scenario == 'pickup') {
      //! 1. Pickup location
      return SafeArea(
        child: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                HeaderSearch(
                  location_type: 'pickup',
                ),
                SearchResultsRenderer(
                  location_type: 'pickup',
                )
              ],
            )),
      );
    } else if (scenario == 'dropoff') {
      //! 1. Dropoff location
      return SafeArea(
        child: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                HeaderSearch(
                  location_type: 'dropoff',
                ),
                SearchResultsRenderer(
                  location_type: 'dropoff',
                )
              ],
            )),
      );
    } else if (scenario == 'note') {
      //Shopping note
      return SafeArea(
        child: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [HeaderNote()],
            )),
      );
    } else {
      return Container(
        child: SizedBox.shrink(),
      );
    }
  }
}

//Results renderer
class SearchResultsRenderer extends StatelessWidget {
  final DataParser _dataParser = DataParser();
  final String location_type;

  SearchResultsRenderer({Key? key, required this.location_type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, String> locationData = _dataParser.getRealisticPlacesNames(
        locationData: context.watch<HomeProvider>().userLocationDetails);

    context.read<HomeProvider>().isManualLocationEqualToTheAuto();

    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        // color: Colors.red,
        child: Column(
          children: [
            Visibility(
              visible: context
                          .read<HomeProvider>()
                          .isManualLocationEqualToTheAuto() ==
                      false &&
                  location_type == 'pickup',
              child: ListTile(
                onTap: () {
                  //! Set the location
                  context.read<HomeProvider>().updateManualPickupOrDropoff(
                      location_type: location_type,
                      location:
                          context.read<HomeProvider>().userLocationDetails);
                  //! Go back and clean
                  context
                      .read<HomeProvider>()
                      .updateRealtimeLocationSuggestions(data: []);
                  context
                      .read<HomeProvider>()
                      .updateTypedSeachQueries(data: '');

                  Navigator.of(context).pop();
                },
                contentPadding: EdgeInsets.only(top: 10, left: 20, right: 20),
                horizontalTitleGap: -5,
                leading: Icon(
                  Icons.my_location,
                  color: AppTheme().getPrimaryColor(),
                ),
                title: Text(
                  'generic_text.myCurrentLocation'.tr(),
                  style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 16),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '${locationData['location_name']}, ${locationData['city']}',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
            Divider(
              color: context
                              .read<HomeProvider>()
                              .isManualLocationEqualToTheAuto() ==
                          false &&
                      location_type == 'pickup'
                  ? Colors.grey
                  : Colors.white,
            ),
            context.watch<HomeProvider>().isLoadingForSearch
                ? Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.2),
                    child: Container(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.black,
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          return LocationInstance(
                            location_type: location_type,
                            locationData: context
                                .read<HomeProvider>()
                                .suggestedLocationSearches[index],
                          );
                        },
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: context
                            .watch<HomeProvider>()
                            .suggestedLocationSearches
                            .length),
                  )
          ],
        ),
      ),
    );
  }
}

//Location instance
class LocationInstance extends StatelessWidget {
  final DataParser _dataParser = DataParser();
  final Map<String, dynamic> locationData;
  final String location_type;
  LocationInstance(
      {Key? key, required this.locationData, required this.location_type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> locationTemplate =
        _dataParser.getRealisticPlacesNames(locationData: locationData);
    return ListTile(
      onTap: () {
        //! Set the location
        context.read<HomeProvider>().updateManualPickupOrDropoff(
            location_type: location_type, location: locationData);
        //! Go back and clean
        context
            .read<HomeProvider>()
            .updateRealtimeLocationSuggestions(data: []);
        context.read<HomeProvider>().updateTypedSeachQueries(data: '');

        Navigator.of(context).pop();
      },
      contentPadding: EdgeInsets.only(top: 10, left: 20, right: 20),
      horizontalTitleGap: -5,
      leading: Icon(
        Icons.location_pin,
        color: Colors.black,
      ),
      title: Text(
        locationTemplate['suburb'],
        style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 16),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          '${locationData['location_name']}, ${locationData['city']}',
          style: TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}

//Header search
class HeaderSearch extends StatefulWidget {
  final String location_type;
  const HeaderSearch({Key? key, required this.location_type}) : super(key: key);

  @override
  State<HeaderSearch> createState() =>
      _HeaderSearchState(location_type: location_type);
}

class _HeaderSearchState extends State<HeaderSearch> {
  final String location_type;

  _HeaderSearchState({Key? key, required this.location_type});

  TextEditingController _editingController = TextEditingController();
  DataParser _dataParser = DataParser();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  Timer? _debounce;

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<HomeProvider>().updateTypedSeachQueries(data: query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _editingController.value = TextEditingValue(
        text: context.read<HomeProvider>().typedSearchLocation.isNotEmpty
            ? context.read<HomeProvider>().typedSearchLocation
            : '');
    // context.read<HomeProvider>().getManualLocationSetted(
    //             location_type: location_type)['street'] !=
    //         null
    //     ? _dataParser
    //             .getRealisticPlacesNames(
    //                 locationData: context
    //                     .read<HomeProvider>()
    //                     .getManualLocationSetted(
    //                         location_type:
    //                             location_type))['location_name']!
    //             .isNotEmpty
    //         ? _dataParser.getRealisticPlacesNames(
    //             locationData: context
    //                 .read<HomeProvider>()
    //                 .getManualLocationSetted(
    //                     location_type: location_type))['location_name']
    //         : _dataParser.getRealisticPlacesNames(
    //             locationData: context
    //                 .read<HomeProvider>()
    //                 .getManualLocationSetted(location_type: location_type))['suburb']
    //     : context.read<HomeProvider>().userLocationDetails['street'] != null
    //         ? context.read<HomeProvider>().userLocationDetails['street'].toString().isNotEmpty
    //             ? context.read<HomeProvider>().userLocationDetails['street']
    //             : context.read<HomeProvider>().userLocationDetails['suburb']
    //         : 'generic_text.findingYourLocation_label'.tr());

    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 0,
          blurRadius: 2,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ]),
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 20, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    //! Clean the search data
                    context
                        .read<HomeProvider>()
                        .updateRealtimeLocationSuggestions(data: []);
                    context
                        .read<HomeProvider>()
                        .updateTypedSeachQueries(data: '');

                    Navigator.of(context).pop();
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back,
                          size: AppTheme().getArrowBackSize()),
                      SizedBox(
                        width: 4,
                      ),
                      Text(
                          location_type == 'pickup'
                              ? 'delivery.whereAreYouTitle'.tr()
                              : 'delivery.deliveryLocation_label'.tr(),
                          style: TextStyle(
                              fontFamily: 'MoveTextBold', fontSize: 20))
                    ],
                  ),
                )
              ],
            ),
            Divider(
              height: 20,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                height: 50,
                child: TextField(
                    controller: _editingController,
                    autocorrect: false,
                    onChanged: (value) {
                      //! Place the cursor at the end
                      _editingController.text = value;
                      _editingController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _editingController.text.length));
                      //! Update the change for the typed
                      _onSearchChanged(value);
                    },
                    style: TextStyle(
                        fontFamily: 'MoveTextRegular',
                        fontSize: 18,
                        color: Colors.black),
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            context
                                .read<HomeProvider>()
                                .updateTypedSeachQueries(data: '');
                            _editingController.clear();
                          },
                          icon: Icon(Icons.clear),
                        ),
                        contentPadding:
                            EdgeInsets.only(top: 0, left: 10, right: 10),
                        filled: true,
                        fillColor: Colors.grey.shade300,
                        floatingLabelStyle:
                            const TextStyle(color: Colors.black),
                        label: Text('generic_text.enterAddress_label'.tr()),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(1)),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(1)))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Header note
class HeaderNote extends StatelessWidget {
  HeaderNote({Key? key}) : super(key: key);

  final TextEditingController _editingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _editingController.value =
        TextEditingValue(text: context.read<HomeProvider>().noteTyped);
    _editingController.selection = TextSelection.fromPosition(
        TextPosition(offset: _editingController.text.length));

    return Expanded(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 0,
                offset: Offset(0, 1), // changes position of shadow
              )
            ]),
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 20, top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_back,
                                size: AppTheme().getArrowBackSize()),
                            SizedBox(
                              width: 4,
                            ),
                            Text('rides.addNote'.tr(),
                                style: TextStyle(
                                    fontFamily: 'MoveTextBold', fontSize: 20))
                          ],
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 26, top: 10),
                    child: Text('shopping.shoppingRequirements_msg'.tr(),
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade600)),
                  ),
                  Divider(
                    height: 20,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: SizedBox(
              height: 250,
              child: TextField(
                  // controller: _editingController,
                  autocorrect: false,
                  onChanged: (value) {
                    //! Update the change for the typed
                    context
                        .read<HomeProvider>()
                        .updateTypedUserNoteShopping(data: value);
                    //! Place the cursor at the end
                    _editingController.text = value;
                    _editingController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _editingController.text.length));
                  },
                  style: TextStyle(
                      fontFamily: 'MoveTextRegular',
                      fontSize: 18,
                      color: Colors.black),
                  maxLines: 45,
                  decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.only(top: 20, left: 10, right: 10),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      floatingLabelStyle: const TextStyle(color: Colors.black),
                      label: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text("generic_text.enterNoteHereLabel".tr()),
                        ),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(1)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(1)))),
            ),
          ),
          Expanded(child: SizedBox.shrink()),
          GenericRectButton(
            label: context.watch<HomeProvider>().noteTyped.isEmpty
                ? 'rides.skip'.tr()
                : 'rides.done'.tr(),
            labelFontSize: 20,
            actuatorFunctionl: () {
              Navigator.of(context).pop();
            },
            isArrowShow: false,
          )
        ],
      ),
    );
  }
}
