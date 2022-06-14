import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nej/components/GenericRectButton.dart';
import 'package:nej/components/Helpers/AppTheme.dart';
import 'package:nej/components/Helpers/SnackBarMother/SnackBarMother.dart';
import 'package:nej/components/PaymentSetting.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:nej/components/SuccessRequest.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class RideSummary extends StatefulWidget {
  const RideSummary({Key? key}) : super(key: key);

  @override
  State<RideSummary> createState() => _RideSummaryState();
}

class _RideSummaryState extends State<RideSummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [MapPreview(), SummaryPreview()],
      ),
    );
  }
}

//Preview the map
class MapPreview extends StatefulWidget {
  const MapPreview({Key? key}) : super(key: key);

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  GoogleMapController? controller;
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  PolylineId? selectedPolyline;

  late String _mapStyle;

  // ignore: use_setters_to_change_properties
  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
    this.controller?.setMapStyle(_mapStyle);
  }

  //!Get the route snapshot data
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void updateMapOrientation({required BuildContext context}) {
    try {
      if (context.read<HomeProvider>().routeSnapshotData[0].latitude >=
          context
              .read<HomeProvider>()
              .routeSnapshotData[
                  context.read<HomeProvider>().routeSnapshotData.length - 1]
              .latitude) {
        controller?.moveCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: context.read<HomeProvider>().routeSnapshotData[
                  context.read<HomeProvider>().routeSnapshotData.length - 1],
              northeast: context.read<HomeProvider>().routeSnapshotData[0],
            ),
            100.0,
          ),
        );
      } else {
        controller?.moveCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: context.read<HomeProvider>().routeSnapshotData[0],
              northeast: context.read<HomeProvider>().routeSnapshotData[
                  context.read<HomeProvider>().routeSnapshotData.length - 1],
            ),
            100.0,
          ),
        );
      }
    } on Exception catch (e) {
      // TODO
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    updateMapOrientation(context: context);

    return Container(
      decoration: BoxDecoration(color: Colors.blue),
      height: MediaQuery.of(context).size.height * 0.35,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  context.watch<HomeProvider>().userLocationCoords['latitude'],
                  context
                      .watch<HomeProvider>()
                      .userLocationCoords['longitude']),
              zoom: 14.0,
            ),
            polylines: Set<Polyline>.of(
                context.watch<HomeProvider>().polylines_snapshot.values),
            markers: Set<Marker>.of(
                context.watch<HomeProvider>().markers_snapshot.values),
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(200),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              blurRadius: 7,
                              spreadRadius: 3)
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: AppTheme().getArrowBackSize(),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//Preview the prices
class SummaryPreview extends StatelessWidget {
  const SummaryPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                blurRadius: 7,
                spreadRadius: 3)
          ],
        ),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Text(
                'Summary',
                style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
              child: Text(
                context.watch<HomeProvider>().pricing_computed[0]['category'],
                style: TextStyle(
                    fontFamily: 'MoveTextLight',
                    fontSize: 14,
                    color: AppTheme().getPrimaryColor()),
              ),
            ),
            Divider(
              height: 25,
            ),
            Expanded(
                child: CarInstance(
              carObject: context.read<HomeProvider>().selected_pricing_model,
            )),
            SafeArea(
              top: false,
              child: GenericRectButton(
                  label: 'Request for ride',
                  labelFontSize: 20,
                  actuatorFunctionl: () =>
                      requestForDelivery(context: context)),
            ),
          ],
        ),
      ),
    );
  }

  //Request for ride
  Future requestForDelivery({required BuildContext context}) async {
    //? Start the loader
    context.read<HomeProvider>().updateLoadingRequestStatus(status: true);

    showMaterialModalBottomSheet(
      enableDrag: false,
      backgroundColor: Colors.white,
      bounce: true,
      duration: Duration(milliseconds: 250),
      context: context,
      builder: (context) => Container(
        height: 400,
        child: Column(
          children: [
            LinearProgressIndicator(
              backgroundColor: Colors.white,
              color: Colors.black,
            ),
            SizedBox(
              height: 40,
            ),
            Container(
                height: 200,
                alignment: Alignment.center,
                child: Text('Requesting for your ride...',
                    style: TextStyle(fontSize: 18)))
          ],
        ),
      ),
    );

    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/requestForRideOrDelivery'));

    //Assemble the bundle data
    //? For the request
    Map<String, String> bundleData = {
      "user_identifier":
          context.read<HomeProvider>().userData['user_identifier'],
      "payment_method": context.read<HomeProvider>().paymentMethod,
      "ride_style": context.read<HomeProvider>().rideStyle,
      "passengers_number":
          context.read<HomeProvider>().passengersNumber.toString(),
      "areGoingTheSameWay":
          context.read<HomeProvider>().isGoingTheSameWay as bool
              ? 'true'
              : 'false',
      "note": context.read<HomeProvider>().noteTyped_ride,
      "ride_selected": json
          .encode(context.read<HomeProvider>().selected_pricing_model)
          .toString(),
      "custom_fare": context.read<HomeProvider>().isCustomFareConsidered
          ? context.read<HomeProvider>().definitiveCustomFare.toString()
          : 'false',
      "dropOff_data": json
          .encode(context.read<HomeProvider>().ride_location_dropoff)
          .toString(),
      "pickup_location": json
          .encode(context.read<HomeProvider>().ride_location_pickup)
          .toString(),
      "ride_mode": context.read<HomeProvider>().selectedService
    };

    try {
      Response response = await post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        Navigator.of(context).pop(); //Hide initial loader
        log(response.body.toString());
        Map<String, dynamic> responseInfo = json.decode(response.body);

        if (responseInfo['response'] == 'unable_to_request') {
          showErrorModal(context: context, scenario: 'internet_error');
        } else if (responseInfo['response'] == 'has_a_pending_shopping') {
          showErrorModal(context: context, scenario: 'already_requested');
        } else if (responseInfo['response'] == 'successful') //?SUCCESSFUL
        {
          //? Go to the successful request page
          // Navigator.of(context).pushNamed('/successfulRequest');
          showMaterialModalBottomSheet(
            backgroundColor: Colors.white,
            expand: true,
            bounce: true,
            duration: Duration(milliseconds: 250),
            context: context,
            builder: (context) => SuccessRequest(),
          );
        } else //Some weird error
        {
          showErrorModal(context: context, scenario: 'internet_error');
        }
      } else //Has some errors
      {
        Navigator.of(context).pop(); //Hide initial loader
        log(response.toString());
        showErrorModal(context: context, scenario: 'internet_error');
      }
    } catch (e) {
      Navigator.of(context).pop(); //Hide initial loader
      log('8');
      log(e.toString());
      showErrorModal(context: context, scenario: 'internet_error');
    }
  }

  //Show error modal
  void showErrorModal(
      {required BuildContext context, required String scenario}) {
    //! Swhitch loader to false
    context.read<HomeProvider>().updateLoadingRequestStatus(status: false);
    //...
    showMaterialModalBottomSheet(
      backgroundColor: Colors.white,
      expand: false,
      bounce: true,
      duration: Duration(milliseconds: 250),
      context: context,
      builder: (context) => LocalModal(
        scenario: scenario,
      ),
    );
  }
}

//Local modal
class LocalModal extends StatelessWidget {
  final String scenario;

  const LocalModal({Key? key, required this.scenario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (scenario == 'already_requested') {
      return SafeArea(
        child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.05),
              child: Column(
                children: [
                  Icon(Icons.warning,
                      size: 50, color: AppTheme().getErrorColor()),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'You have a request in progress',
                    style: TextStyle(
                      fontFamily: 'MoveTextMedium',
                      fontSize: 19,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      "We were unable to go forward with this ride request because it seems like you have an unconfirmed ride request in progress, please confirm it and try again.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                    label: 'Try again',
                    labelFontSize: 20,
                    actuatorFunctionl: () {
                      Navigator.of(context).pop();
                    },
                    isArrowShow: false,
                  )
                ],
              ),
            )),
      );
    } else //Unknown error
    {
      return SafeArea(
        child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.05),
              child: Column(
                children: [
                  Icon(Icons.error,
                      size: 50, color: AppTheme().getErrorColor()),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Unable to request',
                    style: TextStyle(
                      fontFamily: 'MoveTextMedium',
                      fontSize: 19,
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Text(
                      "We were unable to go forward with your ride request due to an unexpected error, please try again and if it persists, please contact us through the Support tab.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                    label: 'Try again',
                    labelFontSize: 20,
                    actuatorFunctionl: () {
                      Navigator.of(context).pop();
                    },
                    isArrowShow: false,
                  )
                ],
              ),
            )),
      );
    }
  }
}

//Payment method
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: InkWell(
        onTap: () => showMaterialModalBottomSheet(
          backgroundColor: Colors.white,
          bounce: true,
          duration: Duration(milliseconds: 250),
          context: context,
          builder: (context) => PaymentSetting(),
        ),
        child: Container(
          // color: Colors.amber,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 25,
                height: 25,
                child: Image.asset(context
                    .watch<HomeProvider>()
                    .getCleanPaymentMethod_nameAndImage()['image']!),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                context
                    .watch<HomeProvider>()
                    .getCleanPaymentMethod_nameAndImage()['name']!,
                style: TextStyle(
                    fontFamily: 'MoveTextMedium',
                    fontSize: 18,
                    color: AppTheme().getPrimaryColor()),
              ),
              SizedBox(
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 13,
                  color: AppTheme().getPrimaryColor(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//Car instance
class CarInstance extends StatelessWidget {
  final Map<String, dynamic> carObject;
  const CarInstance({Key? key, required this.carObject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(),
        child: Column(
          children: [
            Container(
                // color: Colors.red,
                child: SizedBox(
              width: 80,
              height: 60,
              child: Padding(
                padding: EdgeInsets.all(
                    carObject['car_type'] != 'normalTaxiEconomy' ? 3.5 : 0),
                child: Image.asset(
                  'assets/Images/${carObject['media']['car_app_icon'].toString()}',
                  fit: BoxFit.contain,
                ),
              ),
            )),
            Divider(
              height: 10,
              color: Colors.white,
            ),
            Container(
              width: 130,
              height: 25,
              decoration: BoxDecoration(
                  color: Colors.grey
                      .withOpacity(AppTheme().getFadedOpacityValue() - 0.1),
                  border: Border.all(
                      width: 1,
                      color: Colors.grey.withOpacity(
                          AppTheme().getFadedOpacityValue() - 0.1)),
                  borderRadius: BorderRadius.circular(150)),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info,
                    size: 15,
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    carObject['app_label'],
                    style:
                        TextStyle(fontFamily: 'MoveTextRegular', fontSize: 15),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.white,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 20,
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      context.read<HomeProvider>().passengersNumber.toString(),
                      style:
                          TextStyle(fontFamily: 'MoveTextMedium', fontSize: 18),
                    )
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                PaymentMethodSelector()
              ],
            ),
            Divider(
              height: 35,
              color: Colors.white,
            ),
            Text(
              context.watch<HomeProvider>().isCustomFareConsidered
                  ? 'N\$${context.watch<HomeProvider>().definitiveCustomFare.toString()}'
                  : 'N\$${double.parse(carObject['base_fare'].toString()).toStringAsFixed(1)}',
              style: TextStyle(fontFamily: 'MoveTextBold', fontSize: 28),
            ),
            Divider(
              height: 40,
            ),
            InkWell(
              onTap: () => enterCustomFare(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Or'),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Enter your own amount',
                    style: TextStyle(
                        fontFamily: 'MoveTextMedium',
                        fontSize: 16,
                        color: AppTheme().getPrimaryColor()),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 13,
                      color: AppTheme().getPrimaryColor(),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }

  void enterCustomFare(BuildContext context) {
    //? Initialized the error 15min ahead snackbar
    SnackBarMother snackBarMother = SnackBarMother(
        context: context,
        snackChild: RichText(
          text: TextSpan(
              style: TextStyle(fontFamily: 'MoveTextLight'),
              children: [
                TextSpan(text: 'Your custom fare should be between '),
                TextSpan(
                    text:
                        'N\$${context.read<HomeProvider>().getCustomFareRange()['min']}',
                    style: TextStyle(fontFamily: 'MoveTextMedium')),
                TextSpan(text: ' and '),
                TextSpan(
                    text:
                        'N\$${context.read<HomeProvider>().getCustomFareRange()['max']}',
                    style: TextStyle(fontFamily: 'MoveTextMedium'))
              ]),
        ),
        snackPaddingBottom: 410,
        snackBackgroundcolor: AppTheme().getErrorColor());
    //...
    //this._selectDate(context);
    Future customFareModal = showModalBottomSheet(
        //enableDrag: false,
        barrierColor: Colors.black.withOpacity(0.2),
        context: context,
        builder: (context) {
          return Container(
              color: Colors.white,
              child: SafeArea(
                  child: Container(
                width: MediaQuery.of(context).size.width,
                height: 400,
                color: Colors.white,
                child: Container(
                  //decoration: BoxDecoration(border: Border.all(width: 1)),
                  child: Column(
                    children: [
                      Container(
                        //decoration: BoxDecoration(border: Border.all(width: 1)),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 25),
                          child: Text("What's your custom fare?",
                              style: TextStyle(
                                  fontFamily: 'MoveTextMedium', fontSize: 20)),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Divider(),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 15, right: 15, top: 20),
                        child: Container(
                          child: TextField(
                            enabled: context
                                    .read<HomeProvider>()
                                    .isCustomFareConsidered
                                ? false
                                : true,
                            keyboardType: TextInputType.numberWithOptions(
                                decimal: true, signed: false),
                            autocorrect: false,
                            autofocus: true,
                            maxLength: 3,
                            onChanged: (value) {
                              try {
                                context
                                    .read<HomeProvider>()
                                    .updateCustomFareValueOnChange(
                                        customFareValue: double.parse(
                                            value.trim().length > 0
                                                ? value
                                                : '0'));
                              } catch (e) {
                                context
                                    .read<HomeProvider>()
                                    .updateCustomFareValueOnChange(
                                        customFareValue: 0);
                              }
                            },
                            style: TextStyle(
                                fontFamily: 'MoveTextMedium', fontSize: 22),
                            decoration: InputDecoration(
                                counterText: '',
                                labelText: 'Enter your fare',
                                labelStyle:
                                    TextStyle(fontFamily: 'MoveTextRegular'),
                                prefixText: 'N\$',
                                prefixStyle: TextStyle(
                                    fontFamily: 'MoveTextBold', fontSize: 20)),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 15, right: 15, top: 15),
                        child: Container(
                          // decoration:
                          //     BoxDecoration(border: Border.all(width: 1)),
                          width: MediaQuery.of(context).size.width,
                          child: RichText(
                            text: TextSpan(
                                style: TextStyle(
                                    fontFamily: 'MoveTextRegular',
                                    color: Colors.black,
                                    fontSize: 15),
                                children: [
                                  TextSpan(text: 'Between '),
                                  TextSpan(
                                      text:
                                          'N\$${context.read<HomeProvider>().getCustomFareRange()['min']} ',
                                      style: TextStyle(
                                          fontFamily: 'MoveTextMedium')),
                                  TextSpan(text: 'and '),
                                  TextSpan(
                                      text:
                                          'N\$${context.read<HomeProvider>().getCustomFareRange()['max']}',
                                      style: TextStyle(
                                          fontFamily: 'MoveTextMedium'))
                                ]),
                          ),
                        ),
                      ),
                      Expanded(child: Text('')),
                      FittedBox(
                        child: GenericRectButton(
                            label: context
                                        .watch<HomeProvider>()
                                        .isCustomFareConsidered ==
                                    false
                                ? context
                                            .watch<HomeProvider>()
                                            .customFareEntered !=
                                        null
                                    ? 'Set new fare${context.read<HomeProvider>().customFareEntered != null ? ' to N\$' + context.read<HomeProvider>().customFareEntered!.round().toString() : ''}'
                                    : 'Close'
                                : 'Remove custom fare',
                            labelFontSize: 20,
                            bottomSubtitleText: context
                                        .watch<HomeProvider>()
                                        .isCustomFareConsidered ==
                                    false
                                ? null
                                : 'Current fare: N\$${context.watch<HomeProvider>().definitiveCustomFare}',
                            isArrowShow: false,
                            actuatorFunctionl: () {
                              if (context
                                      .read<HomeProvider>()
                                      .isCustomFareConsidered ==
                                  false) {
                                Map setCustomFareCheck = context
                                    .read<HomeProvider>()
                                    .setCustomFareValue();

                                switch (setCustomFareCheck['response']) {
                                  case 'out_of_range': //Out of acceptable range
                                    snackBarMother.showSnackBarMotherChild();
                                    break;
                                  case true:
                                    //? Close custom fare modal
                                    Navigator.pop(context);
                                    break;
                                  case 'no_change':
                                    //? Close custom fare modal
                                    Navigator.pop(context);
                                    break;
                                  default:
                                    //? Close custom fare modal
                                    Navigator.pop(context);
                                    break;
                                }
                              } else //!Remove the previous custom fare
                              {
                                context.read<HomeProvider>().removeCustomFare();
                                snackBarMother.hideSnackBar();
                                //? Focus on the textfield
                                //mainCustomFareInputController.
                              }
                            }),
                      )
                    ],
                  ),
                ),
              )));
        });
    //...
    customFareModal.then((value) {
      //? Close the snackbar if previously initialized
      snackBarMother.hideSnackBar();
    });
  }
}

//Computing fare screen
class ComputingFaresLoader extends StatelessWidget {
  const ComputingFaresLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        width: MediaQuery.of(context).size.width,
        child: Text('Computing fares'),
      ),
    );
  }
}
