import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nej/components/GenericRectButton.dart';
import 'package:nej/components/Helpers/AppTheme.dart';
import 'package:nej/components/PaymentSetting.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class FareDisplay extends StatefulWidget {
  const FareDisplay({Key? key}) : super(key: key);

  @override
  State<FareDisplay> createState() => _FareDisplayState();
}

class _FareDisplayState extends State<FareDisplay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [MapPreview(), FarePreview()],
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      GetRouteSnapshotData(context: context);
      GetPricingData(context: context);
    });
  }

  //?1. Functional: Get the route data
  Future GetRouteSnapshotData({required BuildContext context}) async {
    //....
    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/getRouteToDestinationSnapshot'));

    //Assemble the bundle data
    //* @param type: the type of request (past, scheduled, business)
    Map<String, String> bundleData = {
      "org_latitude": context
          .read<HomeProvider>()
          .ride_location_pickup['coordinates']['latitude']
          .toString(),
      "org_longitude": context
          .read<HomeProvider>()
          .ride_location_pickup['coordinates']['longitude']
          .toString(),
      "dest_latitude": context
          .read<HomeProvider>()
          .ride_location_dropoff[0]['coordinates'][0]
          .toString(),
      "dest_longitude": context
          .read<HomeProvider>()
          .ride_location_dropoff[0]['coordinates'][1]
          .toString(),
      "user_fingerprint": context.read<HomeProvider>().user_identifier
    };

    // print(bundleData);

    if (controller != null) {
      try {
        http.Response response = await http.post(mainUrl, body: bundleData);

        if (response.statusCode == 200) //Got some results
        {
          // log(response.body.toString());
          Map<String, dynamic> tmpResponse = json.decode(response.body);
          //? Update
          context
              .read<HomeProvider>()
              .updateRouteSnaphotData(rawSnap: tmpResponse);
          //? Recenter
          try {
            controller?.moveCamera(
              CameraUpdate.newLatLngBounds(
                LatLngBounds(
                  southwest: LatLng(
                      double.parse(tmpResponse['origin']['latitude']),
                      double.parse(tmpResponse['origin']['longitude'])),
                  northeast: LatLng(
                      double.parse(tmpResponse['destination']['latitude']),
                      double.parse(tmpResponse['destination']['longitude'])),
                ),
                50.0,
              ),
            );
          } on Exception catch (e) {
            // TODO
            controller?.moveCamera(
              CameraUpdate.newLatLngBounds(
                LatLngBounds(
                  northeast: LatLng(
                      double.parse(tmpResponse['origin']['latitude']),
                      double.parse(tmpResponse['origin']['longitude'])),
                  southwest: LatLng(
                      double.parse(tmpResponse['destination']['latitude']),
                      double.parse(tmpResponse['destination']['longitude'])),
                ),
                50.0,
              ),
            );
          }
        } else //Has some errors
        {
          log(response.toString());
          Timer(const Duration(seconds: 1), () {
            GetRouteSnapshotData(context: context);
          });
        }
      } catch (e) {
        log('8');
        log(e.toString());
        Timer(const Duration(seconds: 1), () {
          GetRouteSnapshotData(context: context);
        });
      }
    } else {
      Timer(const Duration(milliseconds: 500), () {
        GetRouteSnapshotData(context: context);
      });
    }
  }

  //?2. Get the pricing information
  Future GetPricingData({required BuildContext context}) async {
    //....
    Uri mainUrl = Uri.parse(
        Uri.encodeFull('${context.read<HomeProvider>().bridge}/computeFares'));

    //Assemble the bundle data
    //* @param type: the type of request (past, scheduled, business)
    Map<String, String> bundleData = {
      "pickup_location": json
          .encode(context.read<HomeProvider>().ride_location_pickup)
          .toString(),
      "dropoff_locations": json
          .encode(context.read<HomeProvider>().ride_location_dropoff)
          .toString(),
      "ride_type": context.read<HomeProvider>().selectedService,
      "user_fingerprint": context.read<HomeProvider>().user_identifier
    };

    // print(bundleData);

    if (controller != null) {
      try {
        http.Response response = await http.post(mainUrl, body: bundleData);

        if (response.statusCode == 200) //Got some results
        {
          // log(response.body.toString());
          List tmpResponse = json.decode(response.body);
          //? Update
          context
              .read<HomeProvider>()
              .updatePricingData_bulk(data: tmpResponse);
          //Auto select the first one
          context
              .read<HomeProvider>()
              .updateSelectedPricing_model(data: tmpResponse[0]);
          //Off the loader
          context
              .read<HomeProvider>()
              .updateFareComputation_status(status: false);
        } else //Has some errors
        {
          log(response.toString());
          Timer(const Duration(seconds: 1), () {
            GetPricingData(context: context);
          });
        }
      } catch (e) {
        log('8');
        log(e.toString());
        Timer(const Duration(seconds: 1), () {
          GetPricingData(context: context);
        });
      }
    } else {
      Timer(const Duration(milliseconds: 500), () {
        GetPricingData(context: context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue),
      height: MediaQuery.of(context).size.height * 0.45,
      width: MediaQuery.of(context).size.width,
      child: Stack(children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
                context.watch<HomeProvider>().userLocationCoords['latitude'],
                context.watch<HomeProvider>().userLocationCoords['longitude']),
            zoom: 7.0,
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
                  onTap: () => Navigator.of(context)
                      .popUntil(ModalRoute.withName('/PassengersInput')),
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
      ]),
    );
  }
}

//Preview the prices
class FarePreview extends StatelessWidget {
  const FarePreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: context.watch<HomeProvider>().isLoadingFor_fareComputation
          ? LoadingForFare()
          : Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Text(
                      context.watch<HomeProvider>().pricing_computed[0]
                          ['category'],
                      style:
                          TextStyle(fontFamily: 'MoveTextMedium', fontSize: 18),
                    ),
                  ),
                  Divider(
                    height: 25,
                  ),
                  Expanded(
                    child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          return CarInstance(
                            carObject: context
                                .read<HomeProvider>()
                                .pricing_computed[index],
                          );
                        },
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: 2),
                  ),
                  PaymentMethodSelector(),
                  SafeArea(
                    top: false,
                    child: GenericRectButton(
                        label: 'Confirm',
                        labelFontSize: 20,
                        actuatorFunctionl: () =>
                            Navigator.of(context).pushNamed('/RideSummary')),
                  ),
                ],
              ),
            ),
    );
  }
}

//Loading for fare
class LoadingForFare extends StatelessWidget {
  const LoadingForFare({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              child: Text('Computing your fare...',
                  style: TextStyle(fontSize: 18)))
        ],
      ),
    );
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
                width: 35,
                height: 35,
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
    return InkWell(
      onTap: carObject['availability'] == 'unavailable'
          ? () => {}
          : () {
              context
                  .read<HomeProvider>()
                  .updateSelectedPricing_model(data: carObject);
            },
      child: Opacity(
        opacity: carObject['availability'] == 'unavailable'
            ? AppTheme().getFadedOpacityValue()
            : 1,
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  left: BorderSide(
                      width: 6,
                      color: carObject['availability'] == 'unavailable' ||
                              carObject['app_label'] !=
                                  context
                                      .watch<HomeProvider>()
                                      .selected_pricing_model['app_label']
                          ? Colors.white
                          : AppTheme().getPrimaryColor()))),
          child: ListTile(
            leading: Container(
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
            title: Text(
              carObject['app_label'],
              style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 16),
            ),
            subtitle: Text(carObject['description']),
            trailing: carObject['availability'] == 'unavailable'
                ? null
                : Text(
                    'N\$${carObject['base_fare']}',
                    style: TextStyle(fontFamily: 'MoveTextBold', fontSize: 21),
                  ),
          ),
        ),
      ),
    );
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
