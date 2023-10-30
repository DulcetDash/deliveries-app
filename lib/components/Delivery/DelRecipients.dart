import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:dulcetdash/components/GenericRectButton.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Helpers/DataParser.dart';
import 'package:dulcetdash/components/Helpers/PhoneNumberInput/PhoneNumberInputEntry.dart';
import 'package:dulcetdash/components/Helpers/TextEditingControllerWorkaroud.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';

class DelRecipients extends StatefulWidget {
  const DelRecipients({Key? key}) : super(key: key);

  @override
  State<DelRecipients> createState() => _DelRecipientsState();
}

class _DelRecipientsState extends State<DelRecipients> {
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
            child: ListView.separated(
                itemBuilder: (context, index) {
                  Map<String, dynamic> receipientData =
                      context.watch<HomeProvider>().recipients_infos[index];

                  return Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      children: [
                        LocationChoiceRecipientFront(
                            recipient_index: index,
                            title: receipientData['name'].toString().isEmpty
                                ? 'delivery.recipient_msg'
                                    .tr(args: ['${index + 1}'])
                                : receipientData['name'].toString(),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: receipientData['phone']
                                      .toString()
                                      .isNotEmpty,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 10),
                                    child: Row(
                                      children: [
                                        Icon(Icons.phone, size: 15),
                                        SizedBox(width: 5),
                                        Text(receipientData['phone'].toString(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black))
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                    context
                                                    .watch<HomeProvider>()
                                                    .getRecipientDetails_indexBased(
                                                        index: index,
                                                        nature_data: 'dropoff_location')[0]
                                                ['street'] !=
                                            null
                                        ? _dataParser.getGenericLocationString(
                                            location: _dataParser.getRealisticPlacesNames(
                                                locationData: context.watch<HomeProvider>().getRecipientDetails_indexBased(
                                                    index: index,
                                                    nature_data:
                                                        'dropoff_location')[0]))
                                        : 'generic_text.pressHereToSet'.tr(),
                                    style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            context.read<HomeProvider>().validateRecipient_data_isolated(index: index)['opacity'] == 1.0
                                                ? AppTheme().getPrimaryColor()
                                                : Colors.grey.shade500))
                              ],
                            ),
                            checked: context
                                        .watch<HomeProvider>()
                                        .getRecipientDetails_indexBased(
                                            index: index,
                                            nature_data: 'dropoff_location')[0]
                                    ['street'] !=
                                null,
                            actuator: () {
                              //! Update the index of the recipient when selected
                              context
                                  .read<HomeProvider>()
                                  .updateSelected_recipient_index(index: index);
                              //!...
                              return showMaterialModalBottomSheet(
                                backgroundColor: Colors.white,
                                bounce: true,
                                duration: Duration(milliseconds: 250),
                                context: context,
                                builder: (context) => LocalModal(
                                  scenario: 'setRecipient',
                                ),
                              ).whenComplete(() {
                                //! Clean the search data
                                context
                                    .read<HomeProvider>()
                                    .updateRealtimeLocationSuggestions(
                                        data: []);
                                context
                                    .read<HomeProvider>()
                                    .updateTypedSeachQueries(data: '');
                                //! Update the phone number and clear it
                                context
                                    .read<HomeProvider>()
                                    .updateSelectedRecipient_phone();
                                //! Clear the entered phone number
                                context
                                    .read<HomeProvider>()
                                    .clearEnteredPhone_number();
                              });
                            }),
                        //Add more?
                        addNewRecipient(context: context, index: index)
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(
                      height: 25,
                    ),
                itemCount:
                    context.watch<HomeProvider>().recipients_infos.length),
          ),
          //? Done button
          Opacity(
            opacity: context
                .read<HomeProvider>()
                .validateRecipient_data_bulk()['opacity'],
            child: GenericRectButton(
              label: 'generic_text.next'.tr(),
              bottomSubtitleText: 'delivery.bottomSubtitleText'.tr(args: [
                '${context.read<HomeProvider>().recipients_infos.length} recipient${context.read<HomeProvider>().recipients_infos.length > 1 || context.read<HomeProvider>().recipients_infos.isEmpty ? 's' : ''}'
              ]),
              labelFontSize: 20,
              horizontalPadding: 20,
              actuatorFunctionl: context
                          .read<HomeProvider>()
                          .validateRecipient_data_bulk()['actuator'] ==
                      'back'
                  ? () {
                      //? Successfully validated
                      Navigator.of(context)
                          .pushNamed('/delivery_pickupLocation');
                    }
                  : () {},
            ),
          )
        ],
      )),
    );
  }

  //Add new recipient
  Widget addNewRecipient({required BuildContext context, required int index}) {
    //! Limit to 30 recipients.
    return Visibility(
        visible:
            index + 1 == context.watch<HomeProvider>().recipients_infos.length,
        child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: ListTile(
              onTap: () =>
                  context.read<HomeProvider>().recipients_infos.length == 30
                      ? {}
                      : context.read<HomeProvider>().addNewReceiver_delivery(),
              contentPadding: EdgeInsets.zero,
              horizontalTitleGap: -5,
              leading: Text(''),
              title: Row(
                children: [
                  Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(150)),
                      child: Icon(Icons.add, color: Colors.white)),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    'delivery.addRecipientLabel'.tr(),
                    style: TextStyle(
                        fontSize: 17, color: AppTheme().getPrimaryColor()),
                  )
                ],
              ),
            )));
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
            Text('delivery.whoAreRecipients'.tr(),
                style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 24)),
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

//Location choice recipient front
class LocationChoiceRecipientFront extends StatelessWidget {
  final String title;
  final Widget subtitle;
  final actuator;
  final bool tracked;
  final bool checked;
  final int recipient_index;

  const LocationChoiceRecipientFront(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.actuator,
      required this.recipient_index,
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
          subtitle:
              Padding(padding: const EdgeInsets.only(top: 5), child: subtitle
                  // Text(
                  //   subtitle,
                  //   style: TextStyle(
                  //       fontSize: 16,
                  //       color: checked
                  //           ? AppTheme().getPrimaryColor()
                  //           : Colors.grey.shade500),
                  // ),
                  ),
          trailing: context.watch<HomeProvider>().recipients_infos.length > 1
              ? InkWell(
                  onTap: () => context
                      .read<HomeProvider>()
                      .removeReceiver_delivery(index: recipient_index),
                  child: Icon(Icons.close, color: AppTheme().getErrorColor()))
              : context.watch<HomeProvider>().recipients_infos.length == 1
                  ? Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color:
                          checked ? Colors.grey : AppTheme().getPrimaryColor(),
                    )
                  : Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color:
                          checked ? Colors.grey : AppTheme().getPrimaryColor(),
                    ),
        ));
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

//Modal set recipient
//Local modal
class LocalModal extends StatelessWidget {
  final String scenario;

  LocalModal({Key? key, required this.scenario}) : super(key: key);

  DataParser _dataParser = DataParser();
  TextEditingController _editingController_name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (scenario == 'setRecipient') {
      // TextEditingControllerWorkaroud _editingController_name =
      //     TextEditingControllerWorkaroud(
      //         text: context.read<HomeProvider>().getRecipientDetails_indexBased(
      //             index: context.read<HomeProvider>().selectedRecipient_index,
      //             nature_data: 'name')[0]);

      //Auto get the relevant data infos if any
      // _editingController_name.value = TextEditingValue(
      //     text: context.watch<HomeProvider>().getRecipientDetails_indexBased(
      //         index: context.watch<HomeProvider>().selectedRecipient_index,
      //         nature_data: 'name')[0]);
      // _editingController_name.selection = TextSelection.fromPosition(
      //     TextPosition(offset: _editingController_name.text.length));

      //! 1. Set tyhe recipient infos
      return SafeArea(
        top: false,
        child: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.90,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back,
                            size: AppTheme().getArrowBackSize()),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'delivery.recipient_msg'.tr(args: [
                            '${context.read<HomeProvider>().selectedRecipient_index + 1}'
                          ]),
                          style: TextStyle(
                              fontFamily: 'MoveTextBold', fontSize: 19),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 30,
                    color: Colors.white,
                  ),
                  TextField(
                      // controller: _editingController_name,
                      autocorrect: false,
                      onChanged: (value) {
                        //! Update the change for the typed
                        context
                            .read<HomeProvider>()
                            .updateSelected_recipientName(name: value);
                      },
                      style: TextStyle(
                          fontFamily: 'MoveTextRegular',
                          fontSize: 18,
                          color: Colors.black),
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              _editingController_name.clear();
                            },
                            icon: Icon(Icons.clear),
                          ),
                          contentPadding:
                              EdgeInsets.only(top: 0, left: 10, right: 10),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          floatingLabelStyle:
                              const TextStyle(color: Colors.black),
                          label: Text('delivery.recipientNameLabel'.tr()),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(1)),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(1)))),
                  Divider(
                    height: 30,
                    color: Colors.white,
                  ),
                  //! Phone number input
                  PhoneNumberInputEntry(),
                  Visibility(
                      visible:
                          context.watch<HomeProvider>().isPhoneEnteredValid ==
                              false,
                      child: ErrorPhone()),
                  Divider(
                    height: 40,
                  ),
                  //! Location details
                  // Text('Delivery location'),
                  LocationChoice(
                      title: 'delivery.deliveryLocation_label'.tr(),
                      subtitle: context.watch<HomeProvider>().getRecipientDetails_indexBased(index: context.read<HomeProvider>().selectedRecipient_index, nature_data: 'dropoff_location')[0]
                                  ['street'] !=
                              null
                          ? _dataParser.getGenericLocationString(
                              location: _dataParser.getRealisticPlacesNames(
                                  locationData: context
                                      .watch<HomeProvider>()
                                      .getRecipientDetails_indexBased(
                                          index: context
                                              .read<HomeProvider>()
                                              .selectedRecipient_index,
                                          nature_data: 'dropoff_location')[0]))
                          : 'delivery.whereToDropOff_description'.tr(),
                      checked: context.watch<HomeProvider>().getRecipientDetails_indexBased(
                              index: context.read<HomeProvider>().selectedRecipient_index,
                              nature_data: 'dropoff_location')[0]['street'] !=
                          null,
                      actuator: () => showMaterialModalBottomSheet(
                            backgroundColor: Colors.white,
                            bounce: true,
                            duration: Duration(milliseconds: 250),
                            context: context,
                            builder: (context) => LocalModal_locations(
                              scenario: 'dropoff',
                            ),
                          )),

                  //! Done
                  Expanded(child: SizedBox.shrink()),
                  Opacity(
                    opacity: context
                        .read<HomeProvider>()
                        .validateRecipient_data_isolated()['opacity'],
                    child: GenericRectButton(
                      label: 'rides.done'.tr(),
                      labelFontSize: 20,
                      horizontalPadding: 0,
                      actuatorFunctionl: context
                                      .read<HomeProvider>()
                                      .validateRecipient_data_isolated()[
                                  'actuator'] ==
                              'back'
                          ? () {
                              Navigator.of(context).pop();
                            }
                          : () => {},
                      isArrowShow: false,
                    ),
                  )
                ],
              ),
            )),
      );
    } else {
      return Container(
        child: SizedBox.shrink(),
      );
    }
  }
}

//Error phone number
class ErrorPhone extends StatelessWidget {
  const ErrorPhone({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        child: Row(children: [
          Icon(
            Icons.error,
            size: 17,
            color: AppTheme().getErrorColor(),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            'phone_input.invalid_phone_number'.tr(),
            style: TextStyle(fontSize: 16, color: AppTheme().getErrorColor()),
          )
        ]),
      ),
    );
  }
}

//Location picker modal
class LocalModal_locations extends StatelessWidget {
  final String scenario;

  const LocalModal_locations({Key? key, required this.scenario})
      : super(key: key);

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
    } else {
      return Container(
        child: SizedBox.shrink(),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    _editingController.value = TextEditingValue(
        text: context.read<HomeProvider>().typedSearchLocation.isNotEmpty
            ? context.read<HomeProvider>().typedSearchLocation
            : context.read<HomeProvider>().getManualLocationSetted_delivery(
                        location_type: location_type)['street'] !=
                    null
                ? _dataParser
                        .getRealisticPlacesNames(
                            locationData: context
                                .read<HomeProvider>()
                                .getManualLocationSetted_delivery(
                                    location_type:
                                        location_type))['location_name']!
                        .isNotEmpty
                    ? _dataParser.getRealisticPlacesNames(
                        locationData: context
                            .read<HomeProvider>()
                            .getManualLocationSetted_delivery(
                                location_type: location_type))['location_name']
                    : _dataParser.getRealisticPlacesNames(
                        locationData: context
                            .read<HomeProvider>()
                            .getManualLocationSetted_delivery(location_type: location_type))['suburb']
                : context.read<HomeProvider>().userLocationDetails['street'] != null
                    ? context.read<HomeProvider>().userLocationDetails['street'].toString().isNotEmpty
                        ? ''
                        : context.read<HomeProvider>().userLocationDetails['suburb']
                    : '');

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
                    // controller: _editingController,
                    autocorrect: false,
                    onChanged: (value) {
                      //! Place the cursor at the end
                      // _editingController.text = value;
                      // _editingController.selection = TextSelection.fromPosition(
                      //     TextPosition(offset: _editingController.text.length));
                      //! Update the change for the typed
                      context
                          .read<HomeProvider>()
                          .updateTypedSeachQueries(data: value);
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
        context.read<HomeProvider>().updateManualPickupOrDropoff_delivery(
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
