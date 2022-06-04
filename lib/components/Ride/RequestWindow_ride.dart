import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nej/components/DrawerMenu.dart';
import 'package:nej/components/Helpers/AppTheme.dart';
import 'package:nej/components/Helpers/RequestCardHelper.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class RequestWindow_ride extends StatefulWidget {
  const RequestWindow_ride({Key? key}) : super(key: key);

  @override
  State<RequestWindow_ride> createState() => _RequestWindow_rideState();
}

class _RequestWindow_rideState extends State<RequestWindow_ride> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerMenu(),
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          MapPreview(),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
              child: Container(
                // color: Colors.red,
                width: MediaQuery.of(context).size.width,
                child: RenderBottomPreview(
                    scenario: context
                        .watch<HomeProvider>()
                        .requestShoppingData[0]['step_name']),
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
    Map<String, dynamic> requestData =
        context.watch<HomeProvider>().requestShoppingData[0];

    if (scenario == 'pending') {
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
              leading: Text('LOADER'),
              title: Text(
                'Finding your driver...',
                style: TextStyle(fontFamily: 'MoveTextBold', fontSize: 19),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text('Press here for more details about your trip.'),
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
      return Container(
        decoration: BoxDecoration(color: Colors.amber),
        width: 400,
        height: 300,
        child: Text('Completed, rate the driver.'),
      );
    } else {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.blue),
      // height: MediaQuery.of(context).size.height * 0.45,
      width: MediaQuery.of(context).size.width,
      child: Stack(children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
                context.watch<HomeProvider>().userLocationCoords['latitude'],
                context.watch<HomeProvider>().userLocationCoords['longitude']),
            zoom: 14.0,
          ),
          // polylines: Set<Polyline>.of(
          //     context.watch<HomeProvider>().polylines_snapshot.values),
          // markers: Set<Marker>.of(
          //     context.watch<HomeProvider>().markers_snapshot.values),
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
class LocalModal extends StatelessWidget {
  final String scenario;
  const LocalModal({Key? key, required this.scenario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (scenario) {
      case 'trip_details':
        final RequestCardHelper requestCardHelper = RequestCardHelper();
        final Map<String, dynamic> requestData =
            context.watch<HomeProvider>().requestShoppingData[0];

        return SafeArea(
          child: Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
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
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 20.0,
                                              child: Shimmer.fromColors(
                                                baseColor: Colors.grey.shade300,
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
                                                    fontFamily: 'MoveTextBold',
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
                              carBrand: requestData['driver_details']['vehicle']
                                  ['brand'],
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
                                'About ${requestData['route_details']['eta']}',
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
                        subtitle: Text('Reach the local authorities quickly.'),
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
      default:
        return SizedBox.shrink();
    }
  }
}
