import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dulcetdash/components/Helpers/DataParser.dart';
import 'package:dulcetdash/components/Helpers/SuperHttp.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:dulcetdash/components/GenericRectButton.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Helpers/RequestCardHelper.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;

class RequestWindow extends StatefulWidget {
  const RequestWindow({Key? key}) : super(key: key);

  @override
  State<RequestWindow> createState() => _RequestWindowState();
}

class _RequestWindowState extends State<RequestWindow> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<HomeProvider>().requestShoppingData == null ||
        context.watch<HomeProvider>().requestShoppingData.isEmpty) {
      // Navigator.of(context).pushNamed('/home');
      return SizedBox.shrink();
    }

    try {
      Map<String, dynamic> requestData =
          context.watch<HomeProvider>().requestShoppingData == null
              ? {}
              : context.watch<HomeProvider>().requestShoppingData.isNotEmpty
                  ? context.watch<HomeProvider>().requestShoppingData[0]
                  : {};

      if (context.watch<HomeProvider>().requestShoppingData == null)
        return SizedBox.shrink();

      if (context.watch<HomeProvider>().requestShoppingData.isEmpty)
        return SizedBox.shrink();

      if (context.watch<HomeProvider>().requestShoppingData[0]
              ['shopping_list'] ==
          null) return SizedBox.shrink();

      print(requestData['state_vars']);

      return context.watch<HomeProvider>().requestShoppingData == null ||
              context.watch<HomeProvider>().requestShoppingData[0]
                      ['shopping_list'] ==
                  null
          ? SizedBox.shrink()
          : context.watch<HomeProvider>().requestShoppingData.length == 0
              ? SizedBox.shrink()
              : Scaffold(
                  body: SafeArea(
                      child: ListView(
                    children: [
                      Header(),
                      ShoppingList(),
                      PaymentSection(),
                      DeliverySection(),
                      CancellationSection(),
                      requestData['state_vars']['completedDropoff'] == false
                          ? SizedBox.shrink()
                          : GenericRectButton(
                              label: 'shopping.rateShopper'.tr(),
                              horizontalPadding: 20,
                              labelFontSize: 25,
                              labelFontFamily: "MoveBold",
                              backgroundColor: AppTheme().getSecondaryColor(),
                              actuatorFunctionl: () =>
                                  showMaterialModalBottomSheet(
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
                  )),
                );
    } on Exception catch (e) {
      // TODO
      return SizedBox.shrink();
    }
  }
}

//Header
class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
      // color: Colors.red,
      child: getCurrentState(context: context),
    );
  }

  //Get current state
  Widget getCurrentState({required BuildContext context}) {
    Map<String, dynamic> requestData =
        context.watch<HomeProvider>().requestShoppingData[0];

    if (requestData['state_vars']['isAccepted'] == false) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.stretchedDots(
              color: AppTheme().getPrimaryColor(), size: 50),
          // Placeholder(
          //   fallbackHeight: 50,
          // ),
          SizedBox(
            height: 15,
          ),
          Text(
            'shopping.findingShopper'.tr(),
            style: TextStyle(fontSize: 18, fontFamily: 'MoveTextBold'),
          )
        ],
      );
    } else if (requestData['state_vars']['isAccepted']) {
      ///Accepted
      return Container(
        // color: Colors.red,
        height: 135,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 30, top: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10000.0),
                    child: Container(
                      width: 60,
                      height: 60,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: requestData['driver_details']['picture'],
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
                  SizedBox(
                    width: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        requestData['driver_details']['name'],
                        style: TextStyle(
                            fontFamily: 'MoveTextMedium', fontSize: 17),
                      ),
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
                                fontFamily: 'MoveTextBold', fontSize: 16),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      //? State
                      Text(getStateText(context: context),
                          style:
                              TextStyle(color: AppTheme().getSecondaryColor()))
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () => PhoneNumberCaller.callNumber(
                    phoneNumber: requestData['driver_details']['phone']),
                child: Icon(
                  Icons.phone,
                  size: 35,
                  color: AppTheme().getSecondaryColor(),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  //Get state text
  String getStateText({required BuildContext context}) {
    Map<String, dynamic> requestData =
        context.watch<HomeProvider>().requestShoppingData[0];

    if (requestData['state_vars']['inRouteToPickupCash'] &&
        requestData['state_vars']['didPickupCash'] == false &&
        requestData['payment_method'] == 'cash') {
      return 'delivery.headingToYou'.tr();
    } else if (requestData['state_vars']['inRouteToPickupCash'] &&
        requestData['state_vars']['didPickupCash'] == false &&
        requestData['payment_method'] == 'mobile_money') {
      return 'delivery.waitingForEwallet'.tr();
    } else if (requestData['state_vars']['inRouteToShop'] &&
        requestData['state_vars']['inRouteToDropoff'] == false) {
      return 'shopping.shoppingInProgress'.tr();
    } else if (requestData['state_vars']['inRouteToDropoff'] &&
        requestData['state_vars']['completedDropoff'] == false) {
      return 'Delivery in progress...';
    } else if (requestData['state_vars']['completedDropoff']) //Shopping done
    {
      return 'shopping.doneShopping'.tr();
    } else {
      return '';
    }
  }
}

//Shopping list
class ShoppingList extends StatelessWidget {
  const ShoppingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> requestData =
        context.watch<HomeProvider>().requestShoppingData[0];

    return InkWell(
      onTap: () => showMaterialModalBottomSheet(
        backgroundColor: Colors.white,
        enableDrag: false,
        expand: true,
        bounce: true,
        duration: Duration(milliseconds: 250),
        context: context,
        builder: (context) => LocalModal(
          scenario: 'shopping_list',
        ),
      ),
      child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100.withOpacity(1),
            // border: Border(
            //     top: BorderSide(width: 0.5, color: Colors.grey),
            //     bottom: BorderSide(width: 0.5, color: Colors.grey))
          ),
          height: 145,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
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
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: Colors.grey.shade600,
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'shopping.shoppingListTitle'.tr(),
                  style: TextStyle(fontSize: 15),
                )
              ],
            ),
          )),
    );
  }

  //Get images thembnail array
  List<Widget> imagesArray({required BuildContext context}) {
    List tmpFinal = [];
    return [];
  }

  //Thumbnail items
  Widget getThumbnailItem(
      {required BuildContext context, required Map<String, dynamic> itemData}) {
    return badges.Badge(
      badgeContent: itemData['isCompleted'] != null
          ? Icon(
              Icons.check,
              size: 15,
              color:
                  itemData['isCompleted'] != null ? Colors.white : Colors.black,
            )
          : Icon(Icons.timelapse_sharp, size: 15),
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

//Payment section
class PaymentSection extends StatelessWidget {
  const PaymentSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> requestData =
        context.watch<HomeProvider>().requestShoppingData[0];

    return Container(
        child: Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'rides.paymentLabel'.tr(),
                    style: TextStyle(
                        fontFamily: 'MoveTextMedium',
                        fontSize: 17,
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
              Text(
                'N\$${requestData['totals_request']['total']}',
                style: TextStyle(
                    fontFamily: 'MoveTextBold',
                    fontSize: 19,
                    color: AppTheme().getPrimaryColor()),
              )
            ],
          ),
          ListTile(
            onTap: () => showMaterialModalBottomSheet(
              backgroundColor: Colors.white,
              enableDrag: false,
              expand: true,
              bounce: true,
              duration: Duration(milliseconds: 250),
              context: context,
              builder: (context) => LocalModal(
                scenario: requestData['payment_method'] == 'cash'
                    ? 'payment_details_cash'
                    : 'payment_details_ewallet',
              ),
            ),
            contentPadding: EdgeInsets.only(top: 15),
            horizontalTitleGap: -15,
            leading: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                Icons.circle,
                size: 10,
                color: Colors.black,
              ),
            ),
            title: Text(
              context
                  .read<HomeProvider>()
                  .getCleanPaymentMethod_nameAndImage(
                      payment: requestData['payment_method'])['name']
                  .toString(),
              style: TextStyle(fontFamily: 'MoveBold', fontSize: 19),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  requestData['payment_method'] == 'cash'
                      ? Text(
                          requestData['state_vars']['didPickupCash'] == false
                              ? 'generic_text.notYetPickedUpFromYou'.tr()
                              : 'generic_text.pickedUpCash'.tr(),
                          style: TextStyle(
                              fontSize: 16,
                              color: AppTheme().getPrimaryColor()),
                        )
                      : Text(
                          requestData['state_vars']['didPickupCash'] == false
                              ? 'generic_text.pressHereToSeeDetails'.tr()
                              : 'generic_text.alreadyPaid'.tr(),
                          style: TextStyle(
                              fontSize: 16,
                              color: AppTheme().getPrimaryColor()),
                        ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: Colors.black,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }
}

//Delivery section
class DeliverySection extends StatelessWidget {
  DeliverySection({Key? key}) : super(key: key);

  final RequestCardHelper _requestCardHelper = RequestCardHelper();

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> requestData =
        context.watch<HomeProvider>().requestShoppingData[0];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        // border: Border(top: BorderSide(width: 0.5, color: Colors.grey))
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery',
                  style: TextStyle(
                      fontFamily: 'MoveTextMedium',
                      fontSize: 17,
                      color: Colors.grey.shade600),
                )
              ],
            ),
            // ListTile(
            //   contentPadding: EdgeInsets.only(top: 15),
            //   horizontalTitleGap: -15,
            //   leading: Icon(
            //     Icons.location_pin,
            //     size: 20,
            //     color: Colors.black,
            //   ),
            //   title: Text(
            //     'Klein Windhoek',
            //     style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 18),
            //   ),
            //   subtitle: Padding(
            //     padding: const EdgeInsets.only(top: 5),
            //     child: Text(
            //       'Street & city',
            //       style: TextStyle(fontSize: 16),
            //     ),
            //   ),
            // )
            Padding(
              padding: const EdgeInsets.only(top: 20),
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
                                              style: TextStyle(
                                                  fontFamily: 'MoveTextLight'),
                                            )),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        // color: Colors.amber,
                                        child: Column(
                                          children: _requestCardHelper
                                              .fitLocationWidgetsToList(
                                                  context: context,
                                                  locationData: [
                                                context
                                                        .read<HomeProvider>()
                                                        .requestShoppingData[0]
                                                    ['trip_locations']['pickup']
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
                                            style: TextStyle(
                                                fontFamily: 'MoveTextLight'),
                                          )),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      // color: Colors.amber,
                                      child: Column(
                                          children: _requestCardHelper
                                              .fitLocationWidgetsToList(
                                                  context: context,
                                                  locationData: [
                                            context
                                                    .read<HomeProvider>()
                                                    .requestShoppingData[0]
                                                ['trip_locations']['delivery']
                                          ])),
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
            )
          ],
        ),
      ),
    );
  }
}

//Cancel section
class CancellationSection extends StatelessWidget {
  const CancellationSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> requestData =
        context.watch<HomeProvider>().requestShoppingData[0];

    return Visibility(
      visible: requestData['state_vars']['inRouteToShop'] == false,
      child: InkWell(
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
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 30, bottom: 60),
          child: Container(
            child: Text(
              'shopping.cancelShoppingTitle'.tr(),
              style: TextStyle(
                  fontFamily: 'MoveTextMedium',
                  fontSize: 17,
                  color: AppTheme().getErrorColor()),
            ),
          ),
        ),
      ),
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
    {
      'title': 'delivery.excellentRatingLabel'.tr(),
      'image': 'assets/Images/gold_medal.png'
    },
    {
      'title': 'delivery.veryFastRatingLabel'.tr(),
      'image': 'assets/Images/fast.png'
    },
    {
      'title': 'delivery.neatAndTidyRatingLabel'.tr(),
      'image': 'assets/Images/cloth.png'
    },
    {
      'title': 'delivery.veryPoliteRatingLabel'.tr(),
      'image': 'assets/Images/polite.png'
    },
    {
      'title': 'delivery.expertShopper'.tr(),
      'image': 'assets/Images/shopping.png'
    }
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

    // print(bundleData);

    try {
      SuperHttp superHttp = SuperHttp();
      var response = await superHttp.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        Map<String, dynamic> tmpResponse = json.decode(response.body);
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
        // print(response.toString());
        showErrorModal(context: context);
      }
    } catch (e) {
      // print('8');
      // print(e.toString());
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
        child: SafeArea(
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
                      'shopping.unableToRateShopper'.tr(),
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
                        "rides.unableToSubmitRating_msg".tr(),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Expanded(child: SizedBox.shrink()),
                    GenericRectButton(
                      label: 'generic_text.tryAgain'.tr(),
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
      SuperHttp superHttp = SuperHttp();
      var response = await superHttp.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        log(response.body.toString());
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
        log(response.toString());
        showErrorModal_cancellation(context: context);
      }
    } catch (e) {
      log('8');
      log(e.toString());
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
                    'generic_text.unableToCancel'.tr(),
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
                      "shopping.unableToCancelShopping_msg".tr(),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                    label: 'generic_text.tryAgain'.tr(),
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
    Map<String, dynamic> requestData =
        context.watch<HomeProvider>().requestShoppingData.isNotEmpty
            ? context.watch<HomeProvider>().requestShoppingData[0]
            : {};

    switch (scenario) {
      case 'payment_details_ewallet':
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
                      'delivery.paymentDetails'.tr(),
                      style:
                          TextStyle(fontFamily: 'MoveTextBold', fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 30,
              color: Colors.white,
            ),
            Expanded(
                child: ListView(
              children: [
                Align(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1000)),
                    width: 70,
                    height: 70,
                    child: Image.asset(
                      'assets/Images/ewallet.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Divider(
                  color: Colors.white,
                  height: 20,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'generic_text.ewallet'.tr(),
                    style: TextStyle(fontFamily: 'MoveBold', fontSize: 24),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25, top: 15),
                  child: Container(
                    child: Text(
                      'shopping.sendShoppingMoney_request'.tr(),
                      style: TextStyle(
                          fontSize: 16, color: AppTheme().getGenericDarkGrey()),
                    ),
                  ),
                ),
                Divider(
                  height: 30,
                  color: Colors.white,
                ),
                //?Payment
                Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 15, bottom: 5),
                  child: Row(
                    children: [
                      Text(
                        'generic_text.sendTo'.tr(),
                        style: TextStyle(
                            fontFamily: 'MoveTextMedium',
                            fontSize: 16,
                            color: AppTheme().getGenericDarkGrey()),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 5,
                  color: Colors.white,
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Container(
                      // color: Colors.amber,
                      child: ListTile(
                        onTap: () => print('Copy ewallet number'),
                        contentPadding: EdgeInsets.zero,
                        horizontalTitleGap: 0,
                        leading: Icon(
                          Icons.phone,
                          color: AppTheme().getPrimaryColor(),
                          size: 20,
                        ),
                        title: Text(
                            requestData['ewallet_details']['phone'].toString(),
                            style: TextStyle(
                                fontFamily: 'MoveTextBold', fontSize: 20)),
                        trailing: Icon(Icons.copy),
                      ),
                    )),
                Divider(),
                //?Amount
                Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 15, bottom: 5),
                  child: Row(
                    children: [
                      Text(
                        'generic_text.amount'.tr(),
                        style: TextStyle(
                            fontFamily: 'MoveTextMedium',
                            fontSize: 16,
                            color: AppTheme().getGenericDarkGrey()),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 5,
                  color: Colors.white,
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Container(
                      // color: Colors.amber,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        horizontalTitleGap: 0,
                        leading: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Icon(
                            Icons.square,
                            color: AppTheme().getPrimaryColor(),
                            size: 10,
                          ),
                        ),
                        title: Text(
                            'N\$ ${requestData['totals_request']['total'].toString()}',
                            style: const TextStyle(
                                fontFamily: 'MoveTextBold', fontSize: 20)),
                      ),
                    )),
                const Divider(
                  height: 15,
                  color: Colors.white,
                ),
                //?Notice
                Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Container(
                      // color: Colors.amber,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        horizontalTitleGap: 0,
                        leading: Icon(
                          Icons.info,
                          color: AppTheme().getGenericDarkGrey(),
                          size: 20,
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                              'generic_text.sendFullAmountBeforeProceeding'
                                  .tr(),
                              style: TextStyle(
                                  fontFamily: 'MoveTextRegular',
                                  fontSize: 15,
                                  color: AppTheme().getGenericDarkGrey())),
                        ),
                      ),
                    )),
                Divider(
                  height: 30,
                ),
                //?Support
                Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 15, bottom: 5),
                  child: Row(
                    children: [
                      Text(
                        'generic_text.support'.tr(),
                        style: TextStyle(
                            fontFamily: 'MoveTextMedium',
                            fontSize: 16,
                            color: AppTheme().getGenericDarkGrey()),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 5,
                  color: Colors.white,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: ListTile(
                    onTap: () => PhoneNumberCaller.callNumber(
                        phoneNumber: '+264857642043'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.support, color: Colors.black),
                    horizontalTitleGap: 0,
                    title: Text(
                      'generic_text.callUs'.tr(),
                      style: TextStyle(
                        fontFamily: 'MoveTextMedium',
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Text('generic_text.forMoreAssistance_msg'.tr()),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                    ),
                  ),
                )
              ],
            ))
          ],
        )));
      case 'payment_details_cash':
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
                      'delivery.paymentDetails'.tr(),
                      style:
                          TextStyle(fontFamily: 'MoveTextBold', fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 30,
              color: Colors.white,
            ),
            Expanded(
                child: ListView(
              children: [
                Align(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1000)),
                    width: 70,
                    height: 70,
                    child: Image.asset(
                      'assets/Images/money.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Divider(
                  color: Colors.white,
                  height: 20,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    'generic_text.cash'.tr(),
                    style: TextStyle(fontFamily: 'MoveBold', fontSize: 24),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25, top: 15),
                  child: Container(
                    child: Text(
                      'shopping.shopperPickupCashBefore'.tr(),
                      style: TextStyle(
                          fontSize: 16, color: AppTheme().getGenericDarkGrey()),
                    ),
                  ),
                ),
                Divider(
                  height: 30,
                  color: Colors.white,
                ),
                //?Payment
                Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 15, bottom: 5),
                  child: Row(
                    children: [
                      Text(
                        'generic_text.securityPin'.tr(),
                        style: TextStyle(
                            fontFamily: 'MoveTextMedium',
                            fontSize: 16,
                            color: AppTheme().getGenericDarkGrey()),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 5,
                  color: Colors.white,
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Container(
                      // color: Colors.amber,
                      child: ListTile(
                        onTap: () => print('Copy PIN number'),
                        contentPadding: EdgeInsets.zero,
                        horizontalTitleGap: 0,
                        leading: Icon(
                          Icons.shield,
                          color: AppTheme().getPrimaryColor(),
                          size: 20,
                        ),
                        title: Text(
                            requestData['ewallet_details']['security']
                                .toString(),
                            style: TextStyle(
                                fontFamily: 'MoveTextBold',
                                fontSize: 20,
                                letterSpacing: 3)),
                        trailing: Icon(Icons.copy),
                      ),
                    )),
                Divider(
                  height: 15,
                ),
                //?Notice
                Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Container(
                      // color: Colors.amber,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        horizontalTitleGap: 0,
                        leading: Icon(
                          Icons.info,
                          color: AppTheme().getGenericDarkGrey(),
                          size: 20,
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text('shopping.askForSecurityPin_msg'.tr(),
                              style: TextStyle(
                                  fontFamily: 'MoveTextRegular',
                                  fontSize: 15,
                                  color: AppTheme().getGenericDarkGrey())),
                        ),
                      ),
                    )),
                Divider(
                  height: 30,
                ),
                //?Support
                Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 15, bottom: 5),
                  child: Row(
                    children: [
                      Text(
                        'generic_text.support'.tr(),
                        style: TextStyle(
                            fontFamily: 'MoveTextMedium',
                            fontSize: 16,
                            color: AppTheme().getGenericDarkGrey()),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 5,
                  color: Colors.white,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 25, right: 25),
                  child: ListTile(
                    onTap: () => PhoneNumberCaller.callNumber(
                        phoneNumber: '+264857642043'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.support, color: Colors.black),
                    horizontalTitleGap: 0,
                    title: Text(
                      'generic_text.callUs'.tr(),
                      style: TextStyle(
                        fontFamily: 'MoveTextMedium',
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Text('generic_text.forMoreAssistance_msg'.tr()),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 15,
                    ),
                  ),
                )
              ],
            ))
          ],
        )));
      case 'shopping_list':
        return SafeArea(
            child: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 10, bottom: 15),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    // color: Colors.red,
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 100,
                          child: Icon(
                            Icons.arrow_back,
                            size: AppTheme().getArrowBackSize() - 3,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              'shopping.myShoppingListTitle'.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'MoveTextBold', fontSize: 18),
                            ),
                          ),
                        ),
                        Container(width: 100, child: Text(''))
                      ],
                    ),
                  ),
                ),
              ),
              Divider(
                height: 0,
                thickness: 1,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 40,
                color: AppTheme().getGenericGrey().withOpacity(0.5),
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Text('shopping.seeWhichItemsAreSold'.tr()),
                ),
              ),
              Expanded(
                  child: Container(
                child: ListView.separated(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 35),
                    itemBuilder: (context, index) {
                      return ProductModel(
                        indexProduct: index + 1,
                        productData: requestData['shopping_list'][index],
                      );
                    },
                    separatorBuilder: (context, index) => Divider(
                          height: 50,
                        ),
                    itemCount: requestData['shopping_list'].length),
              ))
            ],
          ),
        ));
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
                      'shopping.rateShopperTitle'.tr(),
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
                              // print(rating);
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
                        'rides.giveABadgeTitle'.tr(),
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
                                          selectedBadges.removeAt(selectedBadges
                                              .indexOf(badges[index]['title']
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                        'rides.noteTitle'.tr(),
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
                            floatingLabelBehavior: FloatingLabelBehavior.never,
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
                    label: isLoadingSubmission ? 'LOADING' : 'rides.done'.tr(),
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
                      child: Text('shopping.cancelShoppingTitleQuestion'.tr(),
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
                    child: Text('shopping.cancelShoppingConfirmation_msg'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    child: Text('shopping.cancelShopping_explanation'.tr(),
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
                Expanded(child: SizedBox.shrink()),
                GenericRectButton(
                    label: isLoadingSubmission
                        ? 'LOADING'
                        : 'shopping.cancelShoppingBttn_label'.tr(),
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
                      label: 'generic_text.doNotCancelBttn_label'.tr(),
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
  }
}

//Product model
class ProductModel extends StatelessWidget {
  final Map<String, dynamic> productData;
  final int indexProduct;

  const ProductModel(
      {Key? key, required this.productData, required this.indexProduct})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        // onTap: () {},
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 30,
              child: Text(
                indexProduct.toString(),
                style: const TextStyle(fontSize: 17),
              )),
          badges.Badge(
            badgeContent: productData['isCompleted'] != null
                ? Icon(
                    Icons.check,
                    size: 15,
                    color: productData['isCompleted'] != null
                        ? Colors.white
                        : Colors.black,
                  )
                : const Icon(Icons.timelapse_sharp, size: 15),
            badgeStyle: badges.BadgeStyle(
              badgeColor: productData['isCompleted'] != null
                  ? AppTheme().getSecondaryColor()
                  : AppTheme().getGenericGrey(),
            ),
            child: Container(
                width: 70,
                height: 60,
                child: CachedNetworkImage(
                  fit: BoxFit.contain,
                  imageUrl: productData['pictures'][0].runtimeType.toString() ==
                          'List<dynamic>'
                      ? productData['pictures'][0][0]
                      : productData['pictures'][0],
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      SizedBox(
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
                )),
          ),
          const SizedBox(
            width: 30,
          ),
          Container(
            // color: Colors.amber,
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productData['name'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontFamily: 'MoveTextMedium'),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'N\$${productData['price']} • ${getItemsNumber()}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
                const Divider(
                  height: 5,
                  color: Colors.white,
                ),
                Text(
                    DataParser().capitalizeWords(
                        productData['meta']['store'].toString()),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16))
              ],
            ),
          )
        ]),
      ),
    );
  }

  //Get the number of items
  String getItemsNumber() {
    int items = productData['items'];

    if (items == 0 || items > 1) {
      return 'delivery.manyItems'.tr(args: ['$items']);
    } else {
      return 'delivery.singleItem'.tr(args: ['$items']);
    }
  }
}
