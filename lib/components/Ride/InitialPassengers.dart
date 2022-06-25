import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nej/components/GenericRectButton.dart';
import 'package:nej/components/Helpers/AppTheme.dart';
import 'package:nej/components/Helpers/DataParser.dart';
import 'package:nej/components/Helpers/PhoneNumberInput/PhoneNumberInputEntry.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';

class InitialPassengers extends StatefulWidget {
  const InitialPassengers({Key? key}) : super(key: key);

  @override
  State<InitialPassengers> createState() => _InitialPassengersState();
}

class _InitialPassengersState extends State<InitialPassengers> {
  DataParser _dataParser = DataParser();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(
        children: [
          Header(),
          //? Select passenger
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: passengersNode(context: context),
                  ),
                ),
                //? Going to the same destination
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
                  child: GoingSameDestination(
                    isChecked:
                        context.watch<HomeProvider>().isGoingTheSameWay as bool,
                  ),
                ),
                //? Ride type
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 25),
                  child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text("What's your style?",
                          style: TextStyle(
                              fontFamily: 'MoveTextMedium', fontSize: 17))),
                ),
                RideStyleSelect(),
                Divider(
                  height: 30,
                ),
                //? Note
                Padding(
                  padding: const EdgeInsets.only(right: 25),
                  child: LocationChoice(
                    title:
                        context.read<HomeProvider>().noteTyped_delivery.isEmpty
                            ? 'Add a note'
                            : 'Your note',
                    subtitle: context
                            .read<HomeProvider>()
                            .noteTyped_delivery
                            .isEmpty
                        ? 'Anything you want your driver to do for your ride?'
                        : context.read<HomeProvider>().noteTyped_delivery,
                    actuator: () => showMaterialModalBottomSheet(
                      backgroundColor: Colors.white,
                      bounce: true,
                      duration: Duration(milliseconds: 250),
                      context: context,
                      builder: (context) => SafeArea(
                        child: Container(
                            color: Colors.white,
                            height: MediaQuery.of(context).size.height,
                            child: Column(
                              children: [HeaderNote()],
                            )),
                      ),
                    ),
                    tracked: false,
                  ),
                ),
              ],
            ),
          ),
          // Expanded(child: SizedBox.shrink()),
          //? Done button
          Opacity(
            opacity: 1,
            child: GenericRectButton(
                label: 'Continue',
                labelFontSize: 20,
                horizontalPadding: 20,
                actuatorFunctionl: () {
                  //! Clear the previous dropoff and and reset the pickup the the current user location
                  context.read<HomeProvider>().clearPickupAndDropoffs();
                  //!Reset the fare loading status to true
                  context
                      .read<HomeProvider>()
                      .updateFareComputation_status(status: true);
                  //!
                  return showMaterialModalBottomSheet(
                    backgroundColor: Colors.white,
                    bounce: true,
                    duration: Duration(milliseconds: 250),
                    context: context,
                    builder: (context) => LocalModal_locations(
                      scenario: 'dropoff',
                    ),
                  );
                }),
          )
        ],
      )),
    );
  }

  //Get the passenger no nodes
  List<Widget> passengersNode({required BuildContext context}) {
    List<Widget> finalCompilation = [];

    for (var i = 0; i < 4; i++) {
      bool isSelected = context.watch<HomeProvider>().passengersNumber == i + 1;

      Widget node = InkWell(
          onTap: () =>
              context.read<HomeProvider>().updatePassengersNumber(no: i + 1),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 0)
                ],
                color: isSelected ? AppTheme().getPrimaryColor() : Colors.white,
                border: Border.all(
                    width: 1,
                    color: isSelected
                        ? AppTheme().getPrimaryColor()
                        : Colors.grey),
                borderRadius: BorderRadius.circular(200)),
            alignment: Alignment.center,
            child: Text(
              (i + 1).toString(),
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'MoveTextMedium',
                  color: isSelected ? Colors.white : Colors.black),
            ),
          ));
      //Save
      finalCompilation.add(node);
    }
    //...
    return finalCompilation;
  }
}

//Ride style select
class RideStyleSelect extends StatelessWidget {
  const RideStyleSelect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          rideSelector(
              context: context,
              title: 'Private',
              subtitle: 'Just you',
              imagePath: 'assets/Images/man.png',
              isSelected: context.watch<HomeProvider>().rideStyle == 'private',
              actuator: () => context
                  .read<HomeProvider>()
                  .updateRideStyle(value: 'private')),
          SizedBox(
            width: 50,
          ),
          rideSelector(
              context: context,
              title: 'Shared',
              subtitle: 'With others',
              imagePath: 'assets/Images/shared.png',
              isSelected: context.watch<HomeProvider>().rideStyle == 'shared',
              actuator: () => context
                  .read<HomeProvider>()
                  .updateRideStyle(value: 'shared')),
        ],
      ),
    );
  }

  //..Ride selector
  Widget rideSelector(
      {required BuildContext context,
      required String title,
      required String subtitle,
      required String imagePath,
      required bool isSelected,
      required actuator}) {
    return Transform.scale(
      scale: isSelected ? 1.0 : 0.9,
      child: InkWell(
        onTap: actuator,
        child: Opacity(
          opacity: isSelected ? 1 : AppTheme().getFadedOpacityValue() + 0.2,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 0)
                ],
                border: Border.all(
                    width: isSelected ? 3 : 1,
                    color: isSelected
                        ? AppTheme().getSecondaryColor()
                        : Colors.grey),
                borderRadius: BorderRadius.circular(5)),
            width: 120,
            // height: 180,
            height: MediaQuery.of(context).size.height * 0.23,
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                    decoration: BoxDecoration(color: Colors.white),
                    width: 80,
                    // height: 60,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    )),
                Divider(
                  color: Colors.white,
                ),
                Text(
                  title,
                  style: TextStyle(fontFamily: 'MoveTextBold', fontSize: 17),
                ),
                Divider(
                  color: Colors.white,
                ),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 15, color: AppTheme().getGenericDarkGrey()))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//Going same destination
class GoingSameDestination extends StatelessWidget {
  final bool isChecked;
  const GoingSameDestination({Key? key, required this.isChecked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: context.watch<HomeProvider>().passengersNumber > 1
          ? 1
          : AppTheme().getFadedOpacityValue(),
      child: Container(
          // color: Colors.red,
          alignment: Alignment.centerLeft,
          child: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppTheme().getPrimaryColor(),
            title: Text(
              isChecked ? 'Same destination' : 'Not same destination',
              style: TextStyle(
                  fontFamily: 'MoveTextRegular',
                  fontSize: 16,
                  color:
                      isChecked ? AppTheme().getPrimaryColor() : Colors.black),
            ),
            subtitle: null,
            value: isChecked,
            onChanged: context.watch<HomeProvider>().passengersNumber == 1
                ? (v) {}
                : (value) {
                    context
                        .read<HomeProvider>()
                        .updateGoingSameDestinationOrNot(value: value);
                  },
            controlAffinity:
                ListTileControlAffinity.leading, //  <-- leading Checkbox
          )),
    );
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
            InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.arrow_back,
                    size: AppTheme().getArrowBackSize())),
            SizedBox(
              height: 15,
            ),
            Text('For how many passengers?',
                style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 20)),
            Divider(
              height: 30,
              color: Colors.white,
            )
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
        TextEditingValue(text: context.read<HomeProvider>().noteTyped_delivery);
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
                            Text('Add a note',
                                style: TextStyle(
                                    fontFamily: 'MoveTextBold', fontSize: 20))
                          ],
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 26, top: 10),
                    child: Text(
                        'Let us know if you require any specifications about your ride.',
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
                        .updateTypedUserNoteDelivery(data: value);
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
                          child: Text("Enter your note here."),
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
            label: context.watch<HomeProvider>().noteTyped_delivery.isEmpty
                ? 'Skip'
                : 'Done',
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
          minLeadingWidth: 25,
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
            style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              subtitle,
              style: TextStyle(
                  fontSize: 15,
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

//Location picker modal
class LocalModal_locations extends StatelessWidget {
  final String scenario;

  const LocalModal_locations({Key? key, required this.scenario})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              HeaderSearch(
                location_type:
                    context.watch<HomeProvider>().selectedLocationField_index ==
                            -1
                        ? 'pickup'
                        : 'dropoff',
              ),
              SearchResultsRenderer(
                location_type:
                    context.watch<HomeProvider>().selectedLocationField_index ==
                            -1
                        ? 'pickup'
                        : 'dropoff',
              )
            ],
          )),
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

  TextEditingController _editingController_pickup = TextEditingController();
  List<TextEditingController> _editingControllersList = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  DataParser _dataParser = DataParser();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    _editingController_pickup.value = TextEditingValue(
        text: context
            .read<HomeProvider>()
            .getManualLocationSetted_ride(location_type: 'pickup'));

    _editingController_pickup.selection = TextSelection.fromPosition(
        TextPosition(offset: _editingController_pickup.text.length));

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
                          size: AppTheme().getArrowBackSize() - 5),
                      SizedBox(
                        width: 4,
                      ),
                      // Text(
                      //     location_type == 'pickup'
                      //         ? 'Where are you?'
                      //         : 'Delivery location',
                      //     style: TextStyle(
                      //         fontFamily: 'MoveTextBold', fontSize: 20))
                    ],
                  ),
                )
              ],
            ),
            Divider(
              height: 10,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                height: 35,
                child: TextField(
                    controller: context
                                .watch<HomeProvider>()
                                .selectedLocationField_index !=
                            -1
                        ? _editingController_pickup
                        : null,
                    autocorrect: false,
                    onTap: () => context
                        .read<HomeProvider>()
                        .updateSelectedLocationField_index(index: -1),
                    onChanged: (value) {
                      //! Place the cursor at the end
                      _editingController_pickup.text = value;
                      _editingController_pickup.selection =
                          TextSelection.fromPosition(TextPosition(
                              offset: _editingController_pickup.text.length));
                      //! Update the change for the typed
                      context
                          .read<HomeProvider>()
                          .updateTypedSeachQueries(data: value);

                      print(value);
                    },
                    style: TextStyle(
                        fontFamily: 'MoveTextRegular',
                        fontSize: 16,
                        color: Colors.black),
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            context
                                .read<HomeProvider>()
                                .updateTypedSeachQueries(data: '');
                            _editingController_pickup.clear();
                          },
                          icon: Icon(Icons.clear),
                        ),
                        contentPadding:
                            EdgeInsets.only(top: 0, left: 10, right: 10),
                        filled: true,
                        fillColor: Colors.grey.shade300,
                        floatingLabelStyle:
                            const TextStyle(color: Colors.black),
                        label: Text('Pickup location'),
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
            Column(
              children: generateDropOffLocation(context: context),
            )
          ],
        ),
      ),
    );
  }

  //Generate dropoff location fields
  List<Widget> generateDropOffLocation({required BuildContext context}) {
    List<Widget> dropoffFields = [];

    int limit = context.read<HomeProvider>().isGoingTheSameWay!
        ? 1
        : context.read<HomeProvider>().passengersNumber;

    for (var i = 0; i < limit; i++) {
      // _editingControllersList[i].value = TextEditingValue(
      //     text: context.read<HomeProvider>().getManualLocationSetted_ride(
      //         location_type: 'dropoff', index: i));

      // _editingControllersList[i].selection = TextSelection.fromPosition(
      //     TextPosition(offset: _editingControllersList[i].text.length));
      //...
      Widget field = Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: SizedBox(
          height: 35,
          child: TextField(
              controller: _editingControllersList[i],
              // controller:
              //     context.watch<HomeProvider>().selectedLocationField_index != i
              //         ? _editingControllersList[i]
              //         : null,
              autocorrect: false,
              // keyboardType: TextInputType.text,
              onTap: () => context
                  .read<HomeProvider>()
                  .updateSelectedLocationField_index(index: i),
              onChanged: (value) {
                //! Place the cursor at the end
                // _editingControllersList[i].text = value;
                // _editingControllersList[i].selection =
                //     TextSelection.fromPosition(TextPosition(
                //         offset: _editingControllersList[i].text.length));
                //! Update the change for the typed
                context
                    .read<HomeProvider>()
                    .updateTypedSeachQueries(data: value);

                print(value);
              },
              style: TextStyle(
                  fontFamily: 'MoveTextRegular',
                  fontSize: 16,
                  color: Colors.black),
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      context
                          .read<HomeProvider>()
                          .updateTypedSeachQueries(data: '');
                      _editingControllersList[i].clear();
                    },
                    icon: Icon(Icons.clear),
                  ),
                  contentPadding: EdgeInsets.only(top: 0, left: 10, right: 10),
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  floatingLabelStyle: const TextStyle(color: Colors.black),
                  label: Text('Passenger ${i + 1} drop off'),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(1)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(1)))),
        ),
      );

      //...Save
      dropoffFields.add(field);
    }

    return dropoffFields;
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

    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        // color: Colors.red,
        child: Column(
          children: [
            Visibility(
              visible: context
                          .read<HomeProvider>()
                          .isManualLocationEqualToTheAuto_ride() ==
                      false &&
                  location_type == 'pickup' &&
                  context.read<HomeProvider>().userLocationDetails['street'] !=
                      null,
              child: ListTile(
                onTap: () {
                  //! Set the location
                  context.read<HomeProvider>().updateManualPickupOrDropoff_ride(
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

                  //? Autovalidate
                  locationAutovalidatorChecker(context: context);
                },
                contentPadding: EdgeInsets.only(top: 10, left: 20, right: 20),
                horizontalTitleGap: -5,
                leading: Icon(
                  Icons.my_location,
                  color: AppTheme().getPrimaryColor(),
                ),
                title: Text(
                  'My current location',
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
                              .isManualLocationEqualToTheAuto_ride() ==
                          false &&
                      location_type == 'pickup' &&
                      context
                              .read<HomeProvider>()
                              .userLocationDetails['street'] !=
                          null
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
                  ),
            //!Show move next if valid
            Visibility(
              visible:
                  context.watch<HomeProvider>().pricing_computed.isNotEmpty &&
                      areAllLocationsValid(context: context),
              child: GenericRectButton(
                  label: 'Next',
                  labelFontSize: 20,
                  actuatorFunctionl: areAllLocationsValid(context: context)
                      ? () => Navigator.of(context).pushNamed('/FareDisplay')
                      : () {}),
            )
          ],
        ),
      ),
    );
  }

  //? Location autovalidator checker
  void locationAutovalidatorChecker({required BuildContext context}) {
    //Check if all the location had been successfully set
    bool isPickupSet =
        context.read<HomeProvider>().ride_location_pickup['street'] != null
            ? true
            : false;
    List<Map<String, dynamic>> dropoffsTemplate =
        List.from(context.read<HomeProvider>().ride_location_dropoff);

    dropoffsTemplate.removeWhere((element) => element['street'] != null);

    if (isPickupSet && dropoffsTemplate.isEmpty) //Valid move forward
    {
      Navigator.of(context).pushNamed('/FareDisplay');
    }
  }

  bool areAllLocationsValid({required BuildContext context}) {
    bool isPickupSet =
        context.read<HomeProvider>().ride_location_pickup['street'] != null
            ? true
            : false;
    List<Map<String, dynamic>> dropoffsTemplate =
        List.from(context.read<HomeProvider>().ride_location_dropoff);

    dropoffsTemplate.removeWhere((element) => element['street'] != null);

    return isPickupSet && dropoffsTemplate.isEmpty;
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
        context.read<HomeProvider>().updateManualPickupOrDropoff_ride(
            location_type: location_type, location: locationData);
        //! Go back and clean
        context
            .read<HomeProvider>()
            .updateRealtimeLocationSuggestions(data: []);
        context.read<HomeProvider>().updateTypedSeachQueries(data: '');

        //? Autovalidate
        locationAutovalidatorChecker(context: context);
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

  //? Location autovalidator checker
  void locationAutovalidatorChecker({required BuildContext context}) {
    //Check if all the location had been successfully set
    bool isPickupSet =
        context.read<HomeProvider>().ride_location_pickup['street'] != null
            ? true
            : false;
    List<Map<String, dynamic>> dropoffsTemplate =
        List.from(context.read<HomeProvider>().ride_location_dropoff);

    dropoffsTemplate.removeWhere((element) => element['street'] != null);

    if (isPickupSet && dropoffsTemplate.isEmpty) //Valid move forward
    {
      Navigator.of(context).pushNamed('/FareDisplay');
    }
  }
}
