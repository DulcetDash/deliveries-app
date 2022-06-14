import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as MapToolkit;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nej/components/DrawerMenu.dart';
import 'package:nej/components/GenericRectButton.dart';
import 'package:nej/components/Helpers/AppTheme.dart';
import 'package:nej/components/Helpers/MapMarkerFactory/place_to_marker.dart';
import 'package:nej/components/Helpers/RequestCardHelper.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

class RequestWindow_ride extends StatefulWidget {
  const RequestWindow_ride({Key? key}) : super(key: key);

  @override
  State<RequestWindow_ride> createState() => _RequestWindow_rideState();
}

class _RequestWindow_rideState extends State<RequestWindow_ride> {
  @override
  Widget build(BuildContext context) {
    return context.watch<HomeProvider>().requestShoppingData == null
        ? SizedBox.shrink()
        : context.watch<HomeProvider>().requestShoppingData.isEmpty
            ? SizedBox.shrink()
            : Scaffold(
                drawer: DrawerMenu(),
                backgroundColor: Colors.white,
                body: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    MapPreview(),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 20),
                        child: Container(
                          // color: Colors.red,
                          width: MediaQuery.of(context).size.width,
                          child: RenderBottomPreview(
                              scenario: context
                                              .watch<HomeProvider>()
                                              .requestShoppingData[0]
                                          ['step_name'] !=
                                      null
                                  ? context
                                      .watch<HomeProvider>()
                                      .requestShoppingData[0]['step_name']
                                  : ''),
                        ),
                      ),
                    )
                  ],
                ),
              );
  }
}

//Render bottom preview
class RenderBottomPreview extends StatelessWidget {
  final String scenario;
  const RenderBottomPreview({Key? key, required this.scenario})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      Map<String, dynamic> requestData =
          context.watch<HomeProvider>().requestShoppingData.isNotEmpty
              ? context.watch<HomeProvider>().requestShoppingData[0]
              : {};

      if (context.watch<HomeProvider>().requestShoppingData.isEmpty) {
        return SizedBox.shrink();
      } else {
        if (scenario == 'pending') {
          return context.watch<HomeProvider>().requestShoppingData.isEmpty
              ? SizedBox.shrink()
              : InkWell(
                  onTap: () => showMaterialModalBottomSheet(
                    backgroundColor: Colors.white,
                    enableDrag: false,
                    expand: true,
                    bounce: true,
                    duration: Duration(milliseconds: 250),
                    context: context,
                    builder: (context) => LocalModal(
                      scenario: 'trip_details',
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            blurRadius: 7,
                            spreadRadius: 3)
                      ],
                    ),
                    height: 110,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: ListTile(
                        leading: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: AppTheme().getPrimaryColor())),
                        title: Text(
                          'Finding your driver...',
                          style: TextStyle(
                              fontFamily: 'MoveTextBold', fontSize: 19),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                              'Press here for more details about your trip.'),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward,
                          color: AppTheme().getPrimaryColor(),
                        ),
                      ),
                    ),
                  ),
                );
        } else if (scenario == 'in_route_to_pickup' ||
            scenario == 'in_route_to_dropoff') {
          return InkWell(
            onTap: () => showMaterialModalBottomSheet(
              backgroundColor: Colors.white,
              enableDrag: false,
              expand: true,
              bounce: true,
              duration: Duration(milliseconds: 250),
              context: context,
              builder: (context) => LocalModal(
                scenario: 'trip_details',
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      blurRadius: 7,
                      spreadRadius: 3)
                ],
              ),
              height: 110,
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10000.0),
                    child: Container(
                      width: 60,
                      height: 60,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl:
                            //'https://picsum.photos/200/300',
                            requestData['driver_details']['picture'],
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Container(
                          width: MediaQuery.of(context).size.width,
                          height: 20.0,
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              width: 20.0,
                              height: 20.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    requestData['driver_details']['name'],
                    style: TextStyle(fontFamily: 'MoveTextBold', fontSize: 19),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(requestData['driver_details']['vehicle']['brand']),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.star,
                              size: 17,
                              color: AppTheme().getGoldColor(),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              '${double.parse(requestData['driver_details']['rating'].toString()).toStringAsFixed(1)}',
                              style: TextStyle(
                                  fontFamily: 'MoveTextMedium',
                                  fontSize: 16,
                                  color: Colors.black),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward,
                    color: AppTheme().getPrimaryColor(),
                  ),
                ),
              ),
            ),
          );
        } else if (scenario == 'completed') {
          final RequestCardHelper requestCardHelper = RequestCardHelper();

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 5),
                      child: Row(
                        children: [
                          Text(
                            'Itinerary',
                            style: TextStyle(
                                fontFamily: 'MoveTextMedium',
                                fontSize: 16,
                                color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    //PICKUP -> DROP OFF DETAILS
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 20),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Icon(
                                    Icons.circle,
                                    size: 8,
                                  ),
                                ),
                                Flexible(
                                  child: DottedBorder(
                                    color: Colors.black,
                                    strokeWidth: 0.5,
                                    padding: EdgeInsets.all(0.5),
                                    borderType: BorderType.RRect,
                                    dashPattern: [4, 0],
                                    child: Container(
                                      // width: 1,
                                      height: 48,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 23),
                                  child: Icon(
                                    Icons.stop,
                                    size: 15,
                                    color: AppTheme().getSecondaryColor(),
                                  ),
                                )
                              ],
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        // color: Colors.orange,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              // color: Colors.green,
                                              height: 33,
                                              child: const Padding(
                                                padding:
                                                    EdgeInsets.only(top: 2),
                                                child: SizedBox(
                                                    width: 45,
                                                    child: Text(
                                                      'From',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'MoveTextLight'),
                                                    )),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.centerLeft,
                                                // color: Colors.amber,
                                                child: Column(
                                                  children: requestCardHelper
                                                      .fitLocationWidgetsToList(
                                                          context: context,
                                                          locationData: [
                                                        context
                                                                .read<
                                                                    HomeProvider>()
                                                                .requestShoppingData[0]
                                                            [
                                                            'trip_locations']['pickup']
                                                      ]),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  //Destination
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            // color: Colors.green,
                                            height: 34,
                                            child: const Padding(
                                              padding: EdgeInsets.only(top: 3),
                                              child: SizedBox(
                                                  width: 45,
                                                  child: Text(
                                                    'To',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'MoveTextLight'),
                                                  )),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              alignment: Alignment.centerLeft,
                                              // color: Colors.amber,
                                              child: Column(
                                                  children: requestCardHelper
                                                      .fitLocationWidgetsToList(
                                                          context: context,
                                                          locationData: context
                                                                      .read<
                                                                          HomeProvider>()
                                                                      .requestShoppingData[0]
                                                                  [
                                                                  'trip_locations']
                                                              ['dropoff'])),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //?ETA
                    Container(
                      color: Colors.grey
                          .withOpacity(AppTheme().getFadedOpacityValue() - 0.1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer,
                              size: 17,
                              color: AppTheme().getSecondaryColor(),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'About ${requestData['route_details']['eta']}',
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //Button rating
              GenericRectButton(
                  label: 'Rate your driver',
                  horizontalPadding: 0,
                  labelFontSize: 25,
                  labelFontFamily: "MoveBold",
                  backgroundColor: AppTheme().getSecondaryColor(),
                  actuatorFunctionl: () => showMaterialModalBottomSheet(
                        backgroundColor: Colors.white,
                        enableDrag: false,
                        expand: true,
                        bounce: true,
                        duration: Duration(milliseconds: 250),
                        context: context,
                        builder: (context) => LocalModal(
                          scenario: 'rating',
                        ),
                      ))
            ],
          );
        } else {
          return SizedBox.shrink();
        }
      }
    } on Exception catch (e) {
      // TODO
      print(e);
      return SizedBox.shrink();
    }
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
  List<LatLng> routeSnapshotData =
      <LatLng>[]; //Will hold the converted route snapshot recived
  Map<PolylineId, Polyline> polylines_snapshot = <PolylineId,
      Polyline>{}; //Will contain the full form of the polyline ready to be used
  Map<MarkerId, Marker> markers_snapshot =
      <MarkerId, Marker>{}; //Will hold the markers for the snapshot route
  PolylineId? selectedPolyline;

  late String _mapStyle;
  late BitmapDescriptor customCarIcon;

  BitmapDescriptor? _carMarkerIcon;

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
    //Initialize car marker icon

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initCarMarker();
    });
  }

  void initCarMarker() async {
    final Uint8List? markerIcon =
        await getBytesFromAsset("assets/Images/caradvanced_black.png", 90);

    setState(() {
      _carMarkerIcon = BitmapDescriptor.fromBytes(markerIcon!);
    });
  }

  LatLng createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }

  //! Compute the route
  Future<Uint8List?> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        ?.buffer
        .asUint8List();
  }

  //Bearing angle
  double angleFromCoordinate(
      double lat1, double long1, double lat2, double long2) {
    double dLon = (long2 - long1);

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    double brng = atan2(y, x);

    brng = brng * pi / 180;
    brng = (brng + 360) % 360;
    brng = 360 -
        brng; // count degrees counter-clockwise - remove to make clockwise

    return brng;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller!.dispose();
  }

  //!1. SIMULATE ROUTE TO PICKUP
  bool isPickupLocked = false;
  late Timer simulationTimer;
  late LatLng prevDriverCoords;
  String? currentStepTripCycle;

  void simulateRouteToPickupOrDropOff({required BuildContext context}) async {
    Map<String, dynamic> requestData =
        context.watch<HomeProvider>().requestShoppingData[0];

    if (requestData['state_vars']['isAccepted'] &&
        requestData['step_name'] != 'pending' &&
        requestData['step_name'] != 'completed') {
      //?Only allow if not locked
      if (isPickupLocked == false ||
          currentStepTripCycle == null ||
          currentStepTripCycle.toString() != requestData['step_name']) {
        //! Update the current step name
        currentStepTripCycle = requestData['step_name'];

        //!Lock in sumulation
        isPickupLocked = true;
        print('GET UPDATED ROUTE');
        print('SIMULATION LOCKED');
        //? Convert the route point to be compatible with google maps
        List<LatLng> points = <LatLng>[];
        List snapsPoints = requestData['route_details']['routePoints'];
        snapsPoints.forEach((e) {
          points.add(createLatLng(e[1], e[0]));
        });
        //...save
        routeSnapshotData = points;

        //!Start the timer
        simulationTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
          polylines_snapshot = <PolylineId, Polyline>{};

          try {
            //Save the prev driver coord
            prevDriverCoords = requestData['step_name'] == 'in_route_to_pickup'
                ? routeSnapshotData[routeSnapshotData.length - 1]
                : routeSnapshotData[0];
            //!Remove one point at the end
            requestData['step_name'] == 'in_route_to_pickup'
                ? routeSnapshotData.removeLast()
                : routeSnapshotData.removeAt(0);

            //?Establish the origin and destination
            LatLng originPoint =
                requestData['step_name'] == 'in_route_to_pickup'
                    ? routeSnapshotData[0]
                    : routeSnapshotData[routeSnapshotData.length - 1];
            LatLng destinationPoint =
                requestData['step_name'] == 'in_route_to_pickup'
                    ? routeSnapshotData[routeSnapshotData.length - 1]
                    : routeSnapshotData[0];
            LatLng driverPoint =
                requestData['step_name'] == 'in_route_to_pickup'
                    ? routeSnapshotData[routeSnapshotData.length - 1]
                    : routeSnapshotData[0];

            print(routeSnapshotData.length);

            final String polylineIdVal = 'polyline_id_route_snapshot';
            final PolylineId polylineId = PolylineId(polylineIdVal);

            final Polyline polyline = Polyline(
              polylineId: polylineId,
              consumeTapEvents: false,
              color: requestData['step_name'] == 'in_route_to_pickup'
                  ? Colors.black
                  : AppTheme().getPrimaryColor(),
              endCap: Cap.buttCap,
              width: 4,
              zIndex: 100,
              points: points,
            );
            //! Update
            polylines_snapshot[polylineId] = polyline;

            //   //? Create custom markers for origin and destination
            final originIcon = await placeToMarker('My location', null);
            final destinationIcon = await placeToMarker(
              requestData['step_name'] == 'in_route_to_dropoff'
                  ? requestData['trip_locations']['dropoff'][0]['location_name']
                              .toString()
                              .length >
                          22
                      ? '${requestData['trip_locations']['dropoff'][0]['location_name'].toString().substring(0, 15)}...'
                      : requestData['trip_locations']['dropoff'][0]
                              ['location_name']
                          .toString()
                  : 'My driver',
              int.parse(requestData['route_details']['eta']
                      .toString()
                      .split(' ')[0]) *
                  (requestData['route_details']['eta']
                              .toString()
                              .split(' ')[1] ==
                          'min'
                      ? 60
                      : 1),
            );

            const originId = MarkerId('origin');
            const destinationId = MarkerId('destination');

            final originMarker = Marker(
              markerId: originId,
              position: originPoint,
              icon: originIcon,
              anchor: const Offset(1, 1.2),
            );

            final destinationMarker = Marker(
              markerId: destinationId,
              position: requestData['step_name'] == 'in_route_to_pickup'
                  ? destinationPoint
                  : LatLng(
                      double.parse(requestData['trip_locations']['dropoff'][0]
                              ['coordinates'][0]
                          .toString()),
                      double.parse(requestData['trip_locations']['dropoff'][0]
                              ['coordinates'][1]
                          .toString())),
              icon: destinationIcon,
              anchor: const Offset(0, 1.2),
            );

            //...Save
            if (requestData['step_name'] == 'pending') {
              markers_snapshot[originId] = originMarker;
            } else {
              markers_snapshot = <MarkerId, Marker>{}; //Clean
            }
            //...
            markers_snapshot[destinationId] = destinationMarker;

            //! Add the car marker
            const driverCarId = MarkerId('driver_car_id');

            //Compute the heading angle
            var headingAngle = MapToolkit.SphericalUtil.computeHeading(
                MapToolkit.LatLng(
                    prevDriverCoords.latitude, prevDriverCoords.longitude),
                MapToolkit.LatLng(driverPoint.latitude, driverPoint.longitude));

            print('BEARING ANGLE: $headingAngle');

            // print(angleFromCoordinate(
            //     double.parse(requestData['route_details']['origin']['latitude']),
            //     double.parse(requestData['route_details']['origin']['longitude']),
            //     double.parse(requestData['route_details']['destination']['latitude']),
            //     double.parse(
            //         requestData['route_details']['destination']['longitude'])));

            final driverCarMarker = Marker(
                rotation: headingAngle.toDouble(),
                markerId: driverCarId,
                position: driverPoint,
                // icon: markerbitmap,
                icon: _carMarkerIcon!
                // anchor: const Offset(0, 1.2),
                );
            //!Save
            markers_snapshot[driverCarId] = driverCarMarker;

            //Reorient
            try {
              controller?.moveCamera(
                CameraUpdate.newLatLngBounds(
                  requestData['step_name'] == 'in_route_to_pickup'
                      ? LatLngBounds(
                          southwest: originPoint, northeast: prevDriverCoords)
                      : LatLngBounds(
                          southwest: originPoint, northeast: destinationPoint),
                  100.0,
                ),
              );
            } on Exception catch (e) {
              // TODO
              controller?.moveCamera(
                CameraUpdate.newLatLngBounds(
                  requestData['step_name'] == 'in_route_to_pickup'
                      ? LatLngBounds(
                          northeast: originPoint,
                          southwest: prevDriverCoords,
                        )
                      : LatLngBounds(
                          northeast: destinationPoint,
                          southwest: originPoint,
                        ),
                  100.0,
                ),
              );
            }
          } catch (e) {
            print(e);
            simulationTimer.cancel();
            polylines_snapshot = <PolylineId, Polyline>{};
          }
        });
      } else {
        // simulationTimer.cancel();
        // polylines_snapshot = <PolylineId, Polyline>{};
      }
    } else //Empty the data
    {
      //!Unlock simulation
      isPickupLocked = false;
      simulationTimer.cancel();

      routeSnapshotData = <LatLng>[];
      polylines_snapshot = <PolylineId, Polyline>{};
      markers_snapshot = <MarkerId, Marker>{};
    }
  }

  void computeRouteAndSoOn({required BuildContext context}) async {
    Map<String, dynamic> requestData =
        context.watch<HomeProvider>().requestShoppingData[0];

    if (requestData['state_vars']['isAccepted'] &&
        requestData['step_name'] != 'pending' &&
        requestData['step_name'] != 'completed') {
      //!Auto clear everything if the step changes
      polylines_snapshot =
          currentStepTripCycle.toString() != requestData['step_name']
              ? <PolylineId, Polyline>{}
              : polylines_snapshot;
      markers_snapshot =
          currentStepTripCycle.toString() != requestData['step_name']
              ? <MarkerId, Marker>{}
              : markers_snapshot;

      //! Update the current step name
      currentStepTripCycle = requestData['step_name'];

      //? Convert the route point to be compatible with google maps
      List<LatLng> points = <LatLng>[];
      List snapsPoints = requestData['route_details']['routePoints'];
      snapsPoints.forEach((e) {
        points.add(createLatLng(e[1], e[0]));
      });
      //...save
      routeSnapshotData = points;

      //!Start the route
      polylines_snapshot = <PolylineId, Polyline>{};

      try {
        //!Save the prev driver coord
        prevDriverCoords = requestData['step_name'] == 'in_route_to_pickup'
            ? routeSnapshotData[routeSnapshotData.length - 1]
            : routeSnapshotData[0];

        //?Establish the origin and destination
        LatLng originPoint = requestData['step_name'] == 'in_route_to_pickup'
            ? routeSnapshotData[0]
            : routeSnapshotData[routeSnapshotData.length - 1];
        LatLng destinationPoint =
            requestData['step_name'] == 'in_route_to_pickup'
                ? routeSnapshotData[routeSnapshotData.length - 1]
                : routeSnapshotData[0];
        LatLng driverPoint = requestData['step_name'] == 'in_route_to_pickup'
            ? routeSnapshotData[routeSnapshotData.length - 1]
            : routeSnapshotData[0];

        // print(routeSnapshotData.length);

        final String polylineIdVal = 'polyline_id_route_snapshot';
        final PolylineId polylineId = PolylineId(polylineIdVal);

        final Polyline polyline = Polyline(
          polylineId: polylineId,
          consumeTapEvents: false,
          color: requestData['step_name'] == 'in_route_to_pickup'
              ? Colors.black
              : AppTheme().getPrimaryColor(),
          endCap: Cap.buttCap,
          width: 4,
          zIndex: 100,
          points: points,
        );
        //! Update
        polylines_snapshot[polylineId] = polyline;

        //   //? Create custom markers for origin and destination
        final originIcon = await placeToMarker('My location', null);
        final destinationIcon = await placeToMarker(
          requestData['step_name'] == 'in_route_to_dropoff'
              ? requestData['trip_locations']['dropoff'][0]['location_name']
                          .toString()
                          .length >
                      22
                  ? '${requestData['trip_locations']['dropoff'][0]['location_name'].toString().substring(0, 15)}...'
                  : requestData['trip_locations']['dropoff'][0]['location_name']
                      .toString()
              : 'My driver',
          int.parse(requestData['route_details']['eta']
                  .toString()
                  .split(' ')[0]) *
              (requestData['route_details']['eta'].toString().split(' ')[1] ==
                      'min'
                  ? 60
                  : 1),
        );

        const originId = MarkerId('origin');
        const destinationId = MarkerId('destination');

        final originMarker = Marker(
          markerId: originId,
          position: originPoint,
          icon: originIcon,
          anchor: const Offset(1, 1.2),
        );

        final destinationMarker = Marker(
          markerId: destinationId,
          position: requestData['step_name'] == 'in_route_to_pickup'
              ? destinationPoint
              : LatLng(
                  double.parse(requestData['trip_locations']['dropoff'][0]
                          ['coordinates'][0]
                      .toString()),
                  double.parse(requestData['trip_locations']['dropoff'][0]
                          ['coordinates'][1]
                      .toString())),
          icon: destinationIcon,
          anchor: const Offset(0, 1.2),
        );

        //...Save
        if (requestData['step_name'] == 'pending') {
          markers_snapshot[originId] = originMarker;
        } else {
          markers_snapshot = <MarkerId, Marker>{}; //Clean
        }
        //...
        markers_snapshot[destinationId] = destinationMarker;

        //! Add the car marker
        const driverCarId = MarkerId('driver_car_id');

        //Compute the heading angle
        var headingAngle = MapToolkit.SphericalUtil.computeHeading(
            MapToolkit.LatLng(
                prevDriverCoords.latitude, prevDriverCoords.longitude),
            MapToolkit.LatLng(driverPoint.latitude, driverPoint.longitude));

        print('BEARING ANGLE: $headingAngle');

        // print(angleFromCoordinate(
        //     double.parse(requestData['route_details']['origin']['latitude']),
        //     double.parse(requestData['route_details']['origin']['longitude']),
        //     double.parse(requestData['route_details']['destination']['latitude']),
        //     double.parse(
        //         requestData['route_details']['destination']['longitude'])));

        final driverCarMarker = Marker(
            rotation: headingAngle.toDouble(),
            markerId: driverCarId,
            position: driverPoint,
            // icon: markerbitmap,
            icon: _carMarkerIcon!
            // anchor: const Offset(0, 1.2),
            );
        //!Save
        markers_snapshot[driverCarId] = driverCarMarker;

        //Reorient
        try {
          controller?.moveCamera(
            CameraUpdate.newLatLngBounds(
              requestData['step_name'] == 'in_route_to_pickup'
                  ? LatLngBounds(
                      southwest: originPoint, northeast: prevDriverCoords)
                  : LatLngBounds(
                      southwest: originPoint, northeast: destinationPoint),
              100.0,
            ),
          );
        } on Exception catch (e) {
          // TODO
          controller?.moveCamera(
            CameraUpdate.newLatLngBounds(
              requestData['step_name'] == 'in_route_to_pickup'
                  ? LatLngBounds(
                      northeast: originPoint,
                      southwest: prevDriverCoords,
                    )
                  : LatLngBounds(
                      northeast: destinationPoint,
                      southwest: originPoint,
                    ),
              100.0,
            ),
          );
        }
      } catch (e) {
        print(e);
        polylines_snapshot = <PolylineId, Polyline>{};
      }
    } else //Empty the data
    {
      if (requestData['step_name'] != 'completed') //PENDING
      {
        routeSnapshotData = <LatLng>[];
        polylines_snapshot = <PolylineId, Polyline>{};
        // markers_snapshot = <MarkerId, Marker>{};
        //...
        LatLng originPoint = LatLng(
            double.parse(requestData['trip_locations']['pickup']['coordinates']
                    ['latitude']
                .toString()),
            double.parse(requestData['trip_locations']['pickup']['coordinates']
                    ['longitude']
                .toString()));

        const originId = MarkerId('origin');

        final originIcon = await placeToMarker('My pickup', 1000000);

        final originMarker = Marker(
          markerId: originId,
          position: originPoint,
          icon: originIcon,
          anchor: const Offset(0, 1.5),
        );

        //Save
        markers_snapshot[originId] = originMarker;

        //Recenter to user
        controller?.getZoomLevel().then((value) {
          if (value != 14) {
            controller?.moveCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(
                    double.parse(context
                        .watch<HomeProvider>()
                        .requestShoppingData[0]['trip_locations']['pickup']
                            ['coordinates']['latitude']
                        .toString()),
                    double.parse(context
                        .watch<HomeProvider>()
                        .requestShoppingData[0]['trip_locations']['pickup']
                            ['coordinates']['longitude']
                        .toString())),
                14.0,
              ),
            );
          }
        });
      } else //?COMPLETED
      {
        routeSnapshotData = <LatLng>[];
        polylines_snapshot = <PolylineId, Polyline>{};
        markers_snapshot = <MarkerId, Marker>{};

        //Recenter to user
        controller?.getZoomLevel().then((value) {
          if (value != 14) {
            controller?.moveCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(
                    double.parse(context
                        .watch<HomeProvider>()
                        .requestShoppingData[0]['trip_locations']['pickup']
                            ['coordinates']['latitude']
                        .toString()),
                    double.parse(context
                        .watch<HomeProvider>()
                        .requestShoppingData[0]['trip_locations']['pickup']
                            ['coordinates']['longitude']
                        .toString())),
                14.0,
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    computeRouteAndSoOn(context: context);
    // simulateRouteToPickupOrDropOff(context: context);

    return Container(
      decoration: BoxDecoration(color: Colors.blue),
      // height: MediaQuery.of(context).size.height * 0.45,
      width: MediaQuery.of(context).size.width,
      child: Stack(children: [
        GoogleMap(
          padding: EdgeInsets.only(bottom: 170, top: 50),
          initialCameraPosition: CameraPosition(
            target: LatLng(
                double.parse(context
                    .watch<HomeProvider>()
                    .requestShoppingData[0]['trip_locations']['pickup']
                        ['coordinates']['latitude']
                    .toString()),
                double.parse(context
                    .watch<HomeProvider>()
                    .requestShoppingData[0]['trip_locations']['pickup']
                        ['coordinates']['longitude']
                    .toString())),
            zoom: 14.0,
          ),
          polylines: Set<Polyline>.of(polylines_snapshot.values),
          markers: Set<Marker>.of(markers_snapshot.values),
          onMapCreated: _onMapCreated,
          myLocationEnabled: context
                          .watch<HomeProvider>()
                          .requestShoppingData[0]['step_name'] ==
                      'in_route_to_pickup' ||
                  context.watch<HomeProvider>().requestShoppingData[0]
                          ['step_name'] ==
                      'pending' ||
                  context.watch<HomeProvider>().requestShoppingData[0]
                          ['step_name'] ==
                      'completed'
              ? true
              : false,
          myLocationButtonEnabled: false,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Scaffold.of(context).openDrawer(),
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
                      Icons.menu,
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

//Local modal
class LocalModal extends StatefulWidget {
  final String scenario;
  const LocalModal({Key? key, required this.scenario}) : super(key: key);

  @override
  State<LocalModal> createState() => _LocalModalState(scenario: scenario);
}

class _LocalModalState extends State<LocalModal> {
  final String scenario;

  _LocalModalState({Key? key, required this.scenario});

  List<String> ratingStrings = [
    'Terrible',
    'Bad',
    'Good',
    'Very good',
    'Excellent!'
  ];
  int rating = 4; //Rating
  List<Map<String, String>> badges = [
    {'title': 'Excellent service', 'image': 'assets/Images/gold_medal.png'},
    {'title': 'Neat and tidy', 'image': 'assets/Images/cloth.png'},
    {'title': 'Great conversation', 'image': 'assets/Images/conversation.png'},
    {'title': 'Great beats', 'image': 'assets/Images/musical_notes.png'},
    {'title': 'Expert navigator', 'image': 'assets/Images/placeholder.png'}
  ];
  List<String> selectedBadges = [];
  String note = '';
  bool isLoadingSubmission = false;

  //!Submit user rating
  Future SubmitUserRating({required BuildContext context}) async {
    //Start the loader
    setState(() {
      isLoadingSubmission = true;
    });

    Map<String, dynamic> requestData =
        context.read<HomeProvider>().requestShoppingData[0];
    //....
    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/submitRiderOrClientRating'));

    //Assemble the bundle data
    //* @param type: the type of request (past, scheduled, business)
    Map<String, String> bundleData = {
      "request_fp": requestData['request_fp'].toString(),
      "rating": rating.toString(),
      "badges": json.encode(selectedBadges).toString(),
      "note": note,
      "user_fingerprint":
          context.read<HomeProvider>().userData['user_identifier']
    };

    print(bundleData);

    try {
      http.Response response = await http.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        Map<String, dynamic> tmpResponse = json.decode(response.body)[0];
        //? Update
        if (tmpResponse['response'] == 'success') {
          Timer(Duration(seconds: 2), () {
            Navigator.of(context).popAndPushNamed('/home');
          });
        } else //Some error
        {
          showErrorModal(context: context);
        }
      } else //Has some errors
      {
        print(response.toString());
        showErrorModal(context: context);
      }
    } catch (e) {
      print('8');
      print(e.toString());
      showErrorModal(context: context);
    }
  }

  //Show error modal
  void showErrorModal({required BuildContext context}) {
    //! Swhitch loader to false
    setState(() {
      isLoadingSubmission = false;
    });
    //...
    showMaterialModalBottomSheet(
      backgroundColor: Colors.white,
      expand: false,
      bounce: true,
      duration: Duration(milliseconds: 250),
      context: context,
      builder: (context) => SafeArea(
        top: false,
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
                    'Unable to rate driver',
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
                      "We were unable to submit your rating due to an unexpected error, please try again and if it persists, please contact us through the Support tab.",
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
      ),
    );
  }

  //Cancel shopping
  Future cancelRequest({required BuildContext context}) async {
    //Start the loader
    setState(() {
      isLoadingSubmission = true;
    });

    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/cancel_request_user'));

    //Assemble the bundle data
    Map<String, dynamic> requestData =
        context.read<HomeProvider>().requestShoppingData[0];

    //? For the request
    Map<String, String> bundleData = {
      "user_identifier":
          context.read<HomeProvider>().userData['user_identifier'].toString(),
      "request_fp": requestData['request_fp'].toString(),
    };

    try {
      Response response = await post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        print(response.body.toString());
        Map<String, dynamic> tmpResponse = json.decode(response.body)[0];
        //? Update
        if (tmpResponse['response'] == 'success') {
          //! Unlock the fates
          context
              .read<HomeProvider>()
              .updateRequestWindowLockState(state: false);
          //!---

          Timer(Duration(seconds: 3), () {
            Navigator.of(context).popAndPushNamed('/home');
          });
        } else //Some error
        {
          showErrorModal_cancellation(context: context);
        }
      } else //Has some errors
      {
        print(response.toString());
        showErrorModal_cancellation(context: context);
      }
    } catch (e) {
      print('8');
      print(e.toString());
      showErrorModal_cancellation(context: context);
    }
  }

  //Show error modal
  void showErrorModal_cancellation({required BuildContext context}) {
    //! Swhitch loader to false
    setState(() {
      isLoadingSubmission = false;
    });
    //...
    showMaterialModalBottomSheet(
      backgroundColor: Colors.white,
      expand: false,
      bounce: true,
      enableDrag: false,
      duration: Duration(milliseconds: 250),
      context: context,
      builder: (context) => SafeArea(
        top: false,
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
                    'Unable to cancel',
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
                      "We were unable to cancel your ride request due to an unexpected error, please try again and if it persists, please contact us through the Support tab.",
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
      ),
    ).whenComplete(() => Navigator.of(context).pop());
  }

  @override
  Widget build(BuildContext context) {
    try {
      final RequestCardHelper requestCardHelper = RequestCardHelper();
      final Map<String, dynamic> requestData =
          context.watch<HomeProvider>().requestShoppingData.isNotEmpty
              ? context.watch<HomeProvider>().requestShoppingData[0]
              : {};

      if (mapEquals(requestData, {})) return SizedBox.shrink();

      switch (scenario) {
        case 'trip_details':
          if (context.read<HomeProvider>().requestShoppingData[0]
                  ['trip_locations']['dropoff'] ==
              null) return SizedBox.shrink();

          return SafeArea(
            child: Container(
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: AppTheme().getArrowBackSize() - 3,
                          ),
                          Text(
                            'Trip details',
                            style: TextStyle(
                                fontFamily: 'MoveTextBold', fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 20,
                    thickness: 1,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 50),
                      children: [
                        //DRIVER DETAILS IF ANY
                        requestData['state_vars']['isAccepted'] == false
                            ? SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 30, top: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10000.0),
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl:
                                                  requestData['driver_details']
                                                      ['picture'],
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 20.0,
                                                child: Shimmer.fromColors(
                                                  baseColor:
                                                      Colors.grey.shade300,
                                                  highlightColor:
                                                      Colors.grey.shade100,
                                                  child: Container(
                                                    width: 20.0,
                                                    height: 20.0,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                Icons.error,
                                                size: 30,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              requestData['driver_details']
                                                  ['name'],
                                              style: TextStyle(
                                                  fontFamily: 'MoveTextMedium',
                                                  fontSize: 17),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  size: 17,
                                                  color:
                                                      AppTheme().getGoldColor(),
                                                ),
                                                SizedBox(
                                                  width: 2,
                                                ),
                                                Text(
                                                  '${double.parse(requestData['driver_details']['rating'].toString()).toStringAsFixed(1)}',
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'MoveTextBold',
                                                      fontSize: 16),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.phone,
                                      size: 35,
                                      color: AppTheme().getSecondaryColor(),
                                    )
                                  ],
                                ),
                              ),
                        requestData['state_vars']['isAccepted'] == false
                            ? SizedBox.shrink()
                            : Divider(
                                height: 35,
                              ),
                        requestData['state_vars']['isAccepted'] == false
                            ? SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, bottom: 10),
                                child: Row(
                                  children: [
                                    Text(
                                      'Vehicle',
                                      style: TextStyle(
                                          fontFamily: 'MoveTextMedium',
                                          fontSize: 16,
                                          color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                        requestData['state_vars']['isAccepted'] == false
                            ? SizedBox.shrink()
                            : DisplayCarInformation(
                                plateNumber: requestData['driver_details']
                                    ['vehicle']['plate_no'],
                                carBrand: requestData['driver_details']
                                    ['vehicle']['brand'],
                                carImageURL: requestData['driver_details']
                                    ['vehicle']['picture']),
                        requestData['state_vars']['isAccepted'] == false
                            ? Divider(
                                height: 10,
                                color: Colors.white,
                              )
                            : Divider(
                                height: 30,
                                color: Colors.white,
                              ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 5, bottom: 5),
                          child: Row(
                            children: [
                              Text(
                                'Itinerary',
                                style: TextStyle(
                                    fontFamily: 'MoveTextMedium',
                                    fontSize: 16,
                                    color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        //PICKUP -> DROP OFF DETAILS
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 20, bottom: 20),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Icon(
                                        Icons.circle,
                                        size: 8,
                                      ),
                                    ),
                                    Flexible(
                                      child: DottedBorder(
                                        color: Colors.black,
                                        strokeWidth: 0.5,
                                        padding: EdgeInsets.all(0.5),
                                        borderType: BorderType.RRect,
                                        dashPattern: [4, 0],
                                        child: Container(
                                          // width: 1,
                                          height: 48,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 23),
                                      child: Icon(
                                        Icons.stop,
                                        size: 15,
                                        color: AppTheme().getSecondaryColor(),
                                      ),
                                    )
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            // color: Colors.orange,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  // color: Colors.green,
                                                  height: 33,
                                                  child: const Padding(
                                                    padding:
                                                        EdgeInsets.only(top: 2),
                                                    child: SizedBox(
                                                        width: 45,
                                                        child: Text(
                                                          'From',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'MoveTextLight'),
                                                        )),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    // color: Colors.amber,
                                                    child: Column(
                                                      children: requestCardHelper
                                                          .fitLocationWidgetsToList(
                                                              context: context,
                                                              locationData: [
                                                            context
                                                                    .read<
                                                                        HomeProvider>()
                                                                    .requestShoppingData[0]
                                                                [
                                                                'trip_locations']['pickup']
                                                          ]),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      //Destination
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                // color: Colors.green,
                                                height: 34,
                                                child: const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 3),
                                                  child: SizedBox(
                                                      width: 45,
                                                      child: Text(
                                                        'To',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'MoveTextLight'),
                                                      )),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  // color: Colors.amber,
                                                  child: Column(
                                                      children: requestCardHelper
                                                          .fitLocationWidgetsToList(
                                                              context: context,
                                                              locationData: context
                                                                          .read<
                                                                              HomeProvider>()
                                                                          .requestShoppingData[0]
                                                                      [
                                                                      'trip_locations']
                                                                  ['dropoff'])),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //?ETA
                        Container(
                          color: Colors.grey.withOpacity(
                              AppTheme().getFadedOpacityValue() - 0.1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 17,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'About ${requestData['route_details'] != null ? requestData['route_details']['eta'] : '~'}',
                                  style: TextStyle(fontSize: 16),
                                )
                              ],
                            ),
                          ),
                        ),
                        //?RIDE INFOS
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      requestData['passengers'].toString(),
                                      style: TextStyle(
                                        fontFamily: 'MoveTextMedium',
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 7,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      '${requestData['ride_style'].toString().substring(0, 1).toUpperCase()}${requestData['ride_style'].toString().substring(1, requestData['ride_style'].toString().length)} ride',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'MoveTextMedium',
                                          color: AppTheme().getPrimaryColor()),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          height: 20,
                        ),
                        //?Payment
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 25, bottom: 5),
                          child: Row(
                            children: [
                              Text(
                                'Payment',
                                style: TextStyle(
                                    fontFamily: 'MoveTextMedium',
                                    fontSize: 16,
                                    color: Colors.grey.shade600),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.info,
                                size: 15,
                                color: Colors.grey.shade500,
                              )
                            ],
                          ),
                        ),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: Image.asset(context
                                          .watch<HomeProvider>()
                                          .getCleanPaymentMethod_nameAndImage(
                                              payment: requestData[
                                                  'payment_method'])['image']!),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      context
                                          .watch<HomeProvider>()
                                          .getCleanPaymentMethod_nameAndImage(
                                              payment: requestData[
                                                  'payment_method'])['name']!,
                                      style: TextStyle(
                                          fontFamily: 'MoveTextMedium',
                                          fontSize: 18,
                                          color: AppTheme().getPrimaryColor()),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'N\$${double.parse(requestData['fare'].toString()).toStringAsFixed(1)}',
                                  style: TextStyle(
                                      fontSize: 20, fontFamily: 'MoveTextBold'),
                                )
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          height: 35,
                        ),
                        //? Safety
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 15, bottom: 5),
                          child: Row(
                            children: [
                              Text(
                                'Safety',
                                style: TextStyle(
                                    fontFamily: 'MoveTextMedium',
                                    fontSize: 16,
                                    color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.only(left: 20, right: 20),
                          leading: Icon(Icons.shield,
                              color: AppTheme().getErrorColor()),
                          horizontalTitleGap: 0,
                          title: Text(
                            'Call the Police',
                            style: TextStyle(
                              fontFamily: 'MoveTextMedium',
                              fontSize: 17,
                            ),
                          ),
                          subtitle:
                              Text('Reach the local authorities quickly.'),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          ),
                        ),
                        Visibility(
                          visible: requestData['state_vars']
                                  ['inRouteToDropoff'] ==
                              false,
                          child: Divider(
                            height: 35,
                          ),
                        ),
                        Visibility(
                          visible: requestData['state_vars']
                                  ['inRouteToDropoff'] ==
                              false,
                          child: ListTile(
                            onTap: () => showMaterialModalBottomSheet(
                              backgroundColor: Colors.white,
                              expand: false,
                              bounce: true,
                              duration: Duration(milliseconds: 250),
                              context: context,
                              builder: (context) => LocalModal(
                                scenario: 'cancel_request',
                              ),
                            ),
                            contentPadding: EdgeInsets.only(left: 20),
                            title: Text(
                              'Cancel your ride',
                              style: TextStyle(
                                  fontFamily: 'MoveTextMedium',
                                  fontSize: 17,
                                  color: AppTheme().getErrorColor()),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );

        case 'rating':
          return SafeArea(
              child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: InkWell(
                  onTap: isLoadingSubmission
                      ? () {}
                      : () => Navigator.of(context).pop(),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: AppTheme().getArrowBackSize() - 3,
                      ),
                      Text(
                        'Rate driver',
                        style:
                            TextStyle(fontFamily: 'MoveTextBold', fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 20,
                thickness: 1,
              ),
              Expanded(
                  child: ListView(
                padding: EdgeInsets.only(top: 15),
                children: [
                  Align(
                      alignment: Alignment.center,
                      child: Container(
                        alignment: Alignment.center,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10000),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                            imageUrl:
                                // 'https://picsum.photos/200/300',
                                requestData['driver_details']['picture'],
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Container(
                              width: 60,
                              height: 20.0,
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  width: 20.0,
                                  height: 20.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.error,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                      alignment: Alignment.center,
                      child: Text(
                        requestData['driver_details']['name'],
                        style: TextStyle(fontFamily: 'MoveBold', fontSize: 22),
                      )),
                  SizedBox(
                    height: 35,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: RatingBar.builder(
                      initialRating: 4,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 42,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: AppTheme().getGoldColor(),
                      ),
                      onRatingUpdate: isLoadingSubmission
                          ? (v) {}
                          : (val) {
                              setState(() {
                                rating = int.parse(val.toStringAsFixed(0));
                                print(rating);
                              });
                            },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      alignment: Alignment.center,
                      child: Text(
                        ratingStrings[rating - 1],
                        style: TextStyle(
                            fontFamily: 'MoveTextRegular', fontSize: 17),
                      )),
                  Divider(
                    height: 50,
                  ),
                  //?BADGES
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          'Give a badge',
                          style: TextStyle(
                              fontFamily: 'MoveTextMedium',
                              fontSize: 16,
                              color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 20),
                    child: Container(
                      height: 130,
                      // color: Colors.red,
                      child: ListView.separated(
                          padding: EdgeInsets.only(right: 30),
                          shrinkWrap: false,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => InkWell(
                                onTap: isLoadingSubmission
                                    ? () {}
                                    : () {
                                        setState(() {
                                          if (selectedBadges.contains(
                                              badges[index]['title']
                                                  .toString())) //!Remove
                                          {
                                            selectedBadges.removeAt(
                                                selectedBadges.indexOf(
                                                    badges[index]['title']
                                                        .toString()));
                                          } else //!Add
                                          {
                                            selectedBadges.add(badges[index]
                                                    ['title']
                                                .toString());
                                          }
                                        });
                                      },
                                child: Opacity(
                                  opacity: selectedBadges.contains(
                                          badges[index]['title'].toString())
                                      ? 1
                                      : AppTheme().getFadedOpacityValue() + 0.1,
                                  child: Container(
                                    // color: Colors.amber,
                                    width: 95,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(1000),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(1000),
                                                color: Colors.white,
                                                border: Border.all(
                                                    width: 2,
                                                    color: Colors.grey
                                                        .withOpacity(AppTheme()
                                                            .getFadedOpacityValue()))),
                                            height: 65,
                                            width: 65,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(1000),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.asset(
                                                  badges[index]['image']
                                                      .toString(),
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          badges[index]['title'].toString(),
                                          textAlign: TextAlign.center,
                                          maxLines: 3,
                                          style: TextStyle(
                                              fontFamily: 'MoveTextMedium',
                                              fontSize: 15),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          separatorBuilder: (context, index) => SizedBox(
                                width: 20,
                              ),
                          itemCount: badges.length),
                    ),
                  ),
                  //Note
                  Divider(
                    height: 30,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          'Note',
                          style: TextStyle(
                              fontFamily: 'MoveTextMedium',
                              fontSize: 16,
                              color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                    child: SizedBox(
                      height: 100,
                      child: TextField(
                          autocorrect: false,
                          onChanged: (value) {
                            //! Update the change for the typed
                            setState(() {
                              note = value;
                            });
                          },
                          maxLength: 500,
                          style: TextStyle(
                              fontFamily: 'MoveTextRegular',
                              fontSize: 18,
                              color: Colors.black),
                          maxLines: 45,
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.only(top: 25, left: 10, right: 10),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              floatingLabelStyle:
                                  const TextStyle(color: Colors.black),
                              label: Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: Text("Enter your note here."),
                                ),
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(1)),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(1)))),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  GenericRectButton(
                      label: isLoadingSubmission ? 'LOADING' : 'Done',
                      labelFontSize: 22,
                      isArrowShow: false,
                      actuatorFunctionl: isLoadingSubmission
                          ? () {}
                          : () => SubmitUserRating(context: context)),
                  SizedBox(
                    height: 30,
                  )
                ],
              ))
            ],
          ));

        case 'cancel_request':
          return SafeArea(
            top: false,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    child: Container(
                        // color: Colors.red,
                        child: Text('Cancel ride?',
                            style: TextStyle(
                                fontFamily: 'MoveTextBold', fontSize: 20))),
                  ),
                  Divider(
                    height: 30,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    child: Container(
                      child: Text(
                          'Do you really want to cancel your ride request?',
                          style: TextStyle(
                            fontSize: 16,
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Container(
                      child: Text(
                          'By doing so you will not be able to get a driver to move you to your destination.',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                      label: isLoadingSubmission ? 'LOADING' : 'Cancel ride',
                      labelFontSize: 20,
                      horizontalPadding: 20,
                      verticalPadding: 0,
                      isArrowShow: !isLoadingSubmission,
                      backgroundColor: AppTheme().getErrorColor(),
                      actuatorFunctionl: isLoadingSubmission
                          ? () => {}
                          : () => cancelRequest(context: context)),
                  Divider(
                    height: 20,
                    color: Colors.white,
                  ),
                  Opacity(
                    opacity: isLoadingSubmission
                        ? AppTheme().getFadedOpacityValue()
                        : 1,
                    child: GenericRectButton(
                        label: 'Don\'t cancel',
                        labelFontSize: 20,
                        horizontalPadding: 20,
                        verticalPadding: 0,
                        isArrowShow: false,
                        backgroundColor: AppTheme().getGenericGrey(),
                        textColor: Colors.black,
                        labelFontFamily: 'MoveTextBold',
                        actuatorFunctionl: isLoadingSubmission
                            ? () => {}
                            : () => Navigator.of(context).pop()),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          );
        default:
          return SizedBox.shrink();
      }
    } on Exception catch (e) {
      // TODO
      return SizedBox.shrink();
    }
  }
}
