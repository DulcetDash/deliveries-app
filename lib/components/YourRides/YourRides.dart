import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:dulcetdash/components/GenericRectButton.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Helpers/DataParser.dart';
import 'package:dulcetdash/components/Helpers/RequestCardHelper.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart' as share_external;
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class YourRides extends StatefulWidget {
  const YourRides({Key? key}) : super(key: key);

  @override
  State<YourRides> createState() => _YourRidesState();
}

class _YourRidesState extends State<YourRides> {
  bool isLoading = true; //Loading to get the stores.
  List requestsMade = []; //Will hold the list of all the requests fetched

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //! Get the stores names
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // GetListRequests(context: context);
    });
  }

  Future GetListRequests({required BuildContext context}) async {
    //? Set the main stores to empty
    context.read<HomeProvider>().updateMainStores(data: []);
    //....
    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/getRequestListRiders'));

    //Assemble the bundle data
    //* @param type: the type of request (past, scheduled, business)
    Map<String, String> bundleData = {
      'user_identifier':
          context.read<HomeProvider>().userData['user_identifier'],
    };

    try {
      http.Response response = await http.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        List tmpResponse = json.decode(response.body)['response'];
        //? Update
        setState(() {
          requestsMade = tmpResponse;
          isLoading = false;
        });
      } else //Has some errors
      {
        Timer(const Duration(milliseconds: 1000), () {
          GetListRequests(context: context);
        });
      }
    } catch (e) {
      log('8');
      log(e.toString());
      Timer(const Duration(milliseconds: 1000), () {
        GetListRequests(context: context);
      });
    }
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  void _onRefresh() async {
    _onLoading();
  }

  void _onLoading() async {
    // monitor network fetch
    await GetListRequests(context: context);
    _refreshController.loadComplete();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: SafeArea(
            child: Column(
          children: [
            Header(),
            Expanded(
              child: Column(children: [
                Divider(
                  color: Colors.white,
                ),
                Expanded(
                  child: ListView.separated(
                      padding: EdgeInsets.only(bottom: 50),
                      itemBuilder: (context, index) =>
                          RequestModel(requestData: requestsMade[index]),
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: requestsMade.length),
                )
              ]),
            ),
          ],
        )),
      ),
    );
  }
}

//Header
class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Container(
        // color: Colors.red,
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).pushNamed('/home'),
              child: Container(
                alignment: Alignment.centerLeft,
                width: 100,
                child: Icon(
                  Icons.arrow_back,
                  size: AppTheme().getArrowBackSize(),
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: Text(
                  'Your requests',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'MoveBold',
                      fontSize: AppTheme().getHeaderPagesTitleSize()),
                ),
              ),
            ),
            Container(width: 100, child: Text(''))
          ],
        ),
      ),
    );
  }
}

//Request model
class RequestModel extends StatelessWidget {
  final Map<String, dynamic> requestData;
  RequestModel({Key? key, required this.requestData}) : super(key: key);

  final DataParser _dataParser = DataParser();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 20, right: 20, top: 20),
        leading: Icon(
          Icons.circle,
          size: 7,
          color: Colors.black,
        ),
        horizontalTitleGap: -10,
        title: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _dataParser.ucFirst(requestData['request_type'].toString()),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    _dataParser.getReadableDate(
                        dateString: requestData['createdAt']),
                    style: TextStyle(
                        fontSize: 13, color: AppTheme().getGenericDarkGrey()),
                  ),
                  const Expanded(child: Text('')),
                  requestData['cancelled']
                      ? Container(
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(100)),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              'Cancelled',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white),
                            ),
                          ))
                      : requestData['completed']
                          ? Container(
                              decoration: BoxDecoration(
                                  color: AppTheme().getPrimaryColor(),
                                  borderRadius: BorderRadius.circular(100)),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  'Completed',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white),
                                ),
                              ))
                          : const Text('')
                ],
              ),
              SizedBox(
                height: 30,
              ),
              requestData['request_type'].toString().toUpperCase() == 'SHOPPING'
                  ? ShoppingListDetails(requestData: requestData)
                  : RideOrDeliveryDetails(
                      requestData: requestData,
                    )
            ],
          ),
        ),
        //TODO: activate it later: v2 maybe
        // trailing: Icon(
        //   Icons.arrow_forward_ios,
        //   size: 15,
        // ),
      ),
    );
  }
}

//Ride/delivery details
class RideOrDeliveryDetails extends StatelessWidget {
  final Map<String, dynamic> requestData;

  RideOrDeliveryDetails({Key? key, required this.requestData})
      : super(key: key);

  final RequestCardHelper requestCardHelper = RequestCardHelper();

  @override
  Widget build(BuildContext context) {
    List pickup = [requestData['locations']['pickup']];
    var dropoffsTMP =
        requestData['request_type'].toString().toUpperCase() == 'RIDE'
            ? List.from(requestData['locations']['dropoff'])
            : requestData['locations']['dropoff'].map((element) {
                return element['dropoff_location'];
              });

    List dropoffs =
        requestData['request_type'].toString().toUpperCase() == 'RIDE'
            ? dropoffsTMP
            : dropoffsTMP.toList();

    return IntrinsicHeight(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // color: Colors.orange,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            // color: Colors.green,
                            height: 33,
                            child: Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: SizedBox(
                                  width: 45,
                                  child: Text(
                                    'rides.fromLabel'.tr(),
                                    style:
                                        TextStyle(fontFamily: 'MoveTextLight'),
                                  )),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerLeft,
                              // color: Colors.amber,
                              child: Column(
                                children:
                                    requestCardHelper.fitLocationWidgetsToList(
                                        context: context, locationData: pickup),
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          // color: Colors.green,
                          height: 34,
                          child: Padding(
                            padding: EdgeInsets.only(top: 3),
                            child: SizedBox(
                                width: 45,
                                child: Text(
                                  'rides.toLabel'.tr(),
                                  style: TextStyle(fontFamily: 'MoveTextLight'),
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
                                        locationData: [dropoffs[0]])),
                          ),
                        )
                      ],
                    ),
                    dropoffs.length == 1
                        ? Text('')
                        : Row(
                            children: [
                              SizedBox(
                                width: 45,
                              ),
                              Text(
                                  'delivery.moreLocationsMask'.tr(args: [
                                    '${dropoffs.length - 1}',
                                    '${dropoffs.length - 1 > 1 ? 's' : ''}'
                                  ]),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: AppTheme().getSecondaryColor())),
                            ],
                          )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//Shopping details - shopping list
class ShoppingListDetails extends StatelessWidget {
  final Map<String, dynamic> requestData;
  const ShoppingListDetails({Key? key, required this.requestData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          // border: Border(
          //     top: BorderSide(width: 0.5, color: Colors.grey),
          //     bottom: BorderSide(width: 0.5, color: Colors.grey))
        ),
        height: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    height: 50,
                    // width: 50,
                    child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => getThumbnailItem(
                            context: context,
                            itemData: requestData['shopping_list'][index]),
                        separatorBuilder: (context, index) => SizedBox(
                              width: 15,
                            ),
                        itemCount: requestData['shopping_list'].length),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'yourRides.formerShoppingList'.tr(),
              style: TextStyle(fontSize: 14, fontFamily: 'MoveTextLight'),
            )
          ],
        ));
  }

  //Thumbnail items
  Widget getThumbnailItem(
      {required BuildContext context, required Map<String, dynamic> itemData}) {
    return badges.Badge(
      badgeContent: itemData['isCompleted'] != null
          ? Icon(
              Icons.check,
              size: 10,
              color:
                  itemData['isCompleted'] != null ? Colors.white : Colors.black,
            )
          : Icon(Icons.timelapse_sharp, size: 10),
      badgeStyle: badges.BadgeStyle(
        badgeColor: itemData['isCompleted'] != null
            ? AppTheme().getSecondaryColor()
            : AppTheme().getGenericGrey(),
      ),
      child: Container(
          height: 50,
          width: 60,
          color: Colors.grey,
          child: CachedNetworkImage(
            imageUrl: itemData['pictures'][0].runtimeType.toString() ==
                    'List<dynamic>'
                ? itemData['pictures'][0][0]
                : itemData['pictures'][0],
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 20.0,
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 48.0,
                  height: 48.0,
                  color: Colors.white,
                ),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(
              Icons.error,
              size: 30,
              color: Colors.grey,
            ),
          )),
    );
  }
}
