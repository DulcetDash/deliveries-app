//ShoppingSummary

import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:orniss/components/GenericRectButton.dart';
import 'package:orniss/components/Helpers/AppTheme.dart';
import 'package:orniss/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ShoppingSummary extends StatefulWidget {
  const ShoppingSummary({Key? key}) : super(key: key);

  @override
  State<ShoppingSummary> createState() => _ShoppingSummaryState();
}

class _ShoppingSummaryState extends State<ShoppingSummary> {
  @override
  Widget build(BuildContext context) {
    Map payment_summary = context.read<HomeProvider>().getTotals();

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(
          children: [
            Header(),
            Expanded(
              child: Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 5),
                  child: context.watch<HomeProvider>().CART.isNotEmpty
                      ? ListView.separated(
                          itemBuilder: (context, index) {
                            return ProductModel(
                              indexProduct: index + 1,
                              productData:
                                  context.watch<HomeProvider>().CART[index],
                            );
                          },
                          separatorBuilder: (context, index) => Divider(
                                height: 50,
                              ),
                          itemCount: context.watch<HomeProvider>().CART.length)
                      : Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.15),
                          child: Container(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  size: 45,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'shopping.noItemsForShopping'.tr(),
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 17),
                                )
                              ],
                            ),
                          ),
                        )),
            ),
            Container(
              // color: Colors.red,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [AppTheme().getPrimaryColor(), Colors.black]),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  //CART FEE
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('shopping.yourCart'.tr(),
                            style: TextStyle(fontSize: 17)),
                        Text(payment_summary['cart'],
                            style: TextStyle(
                                fontSize: 19,
                                color: AppTheme().getPrimaryColor())),
                      ],
                    ),
                  ),
                  //SERVICE FEE
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('shopping.serviceFee'.tr(),
                            style: TextStyle(fontSize: 17)),
                        Text(payment_summary['service_fee'],
                            style: TextStyle(
                                fontSize: 19,
                                color: AppTheme().getPrimaryColor())),
                      ],
                    ),
                  ),
                  //CASH PICKUP FEE?
                  Visibility(
                    visible:
                        context.watch<HomeProvider>().paymentMethod == 'cash',
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('shopping.cashPickupFee'.tr(),
                              style: TextStyle(fontSize: 17)),
                          Text(payment_summary['cash_pickup_fee'],
                              style: TextStyle(
                                  fontSize: 19,
                                  color: AppTheme().getPrimaryColor())),
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  //TOTAL
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('delivery.total'.tr(),
                            style: TextStyle(
                                fontFamily: 'MoveTextMedium', fontSize: 17)),
                        Text(payment_summary['total'],
                            style: TextStyle(
                                fontFamily: 'MoveTextMedium',
                                fontSize: 21,
                                color: AppTheme().getPrimaryColor())),
                      ],
                    ),
                  ),
                  context.watch<HomeProvider>().isLoadingForRequest
                      ? Column(
                          children: [
                            SizedBox(
                              height: 25,
                            ),
                            CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        )
                      : GenericRectButton(
                          label: 'shopping.shopNow'.tr(),
                          labelFontSize: 22,
                          actuatorFunctionl: () {
                            requestForShopping(context: context);
                          }),
                ],
              ),
            )
          ],
        )));
  }

  //Request for shipping
  Future requestForShopping({required BuildContext context}) async {
    //? Start the loader
    context.read<HomeProvider>().updateLoadingRequestStatus(status: true);

    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/requestForShopping'));

    //Assemble the bundle data
    //1. Locations data
    Map<String, dynamic> locations = {
      "pickup":
          context.read<HomeProvider>().manuallySettedCurrentLocation_pickup,
      "delivery":
          context.read<HomeProvider>().manuallySettedCurrentLocation_dropoff
    };

    List shopping_list = context.read<HomeProvider>().CART;
    //? For the request
    Map<String, String> bundleData = {
      "user_identifier":
          context.read<HomeProvider>().userData['user_identifier'],
      "payment_method": context.read<HomeProvider>().paymentMethod,
      "note": context.read<HomeProvider>().noteTyped,
      "locations": json.encode(locations).toString(),
      "totals":
          json.encode(context.read<HomeProvider>().getTotals()).toString(),
      "shopping_list": json.encode(shopping_list).toString(),
      "ride_mode": context.read<HomeProvider>().selectedService
    };

    try {
      Response response = await post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
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
        } else //Some weird error
        {
          showErrorModal(context: context, scenario: 'internet_error');
        }
      } else //Has some errors
      {
        log(response.toString());
        showErrorModal(context: context, scenario: 'internet_error');
      }
    } catch (e) {
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
                    'rides.haveRequestInPro_title'.tr(),
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
                      "shopping.unableToRequestShopping_msg".tr(),
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
                    'rides.unableToRequestTitle'.tr(),
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
                      "shopping.unableToRequestShoppingUnexpected_msg".tr(),
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
      );
    }
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
                  onTap: context.watch<HomeProvider>().isLoadingForRequest
                      ? () {}
                      : () {
                          //! Restore the tmp selected product if changed
                          context.read<HomeProvider>().updateSelectedProduct(
                              data: context
                                          .read<HomeProvider>()
                                          .tmp_selectedProduct['name'] !=
                                      null
                                  ? context
                                      .read<HomeProvider>()
                                      .tmp_selectedProduct
                                  : context
                                      .read<HomeProvider>()
                                      .selectedProduct);
                          //! Clear the tmp selected product
                          context
                              .read<HomeProvider>()
                              .updateTMPSelectedProduct(data: {});
                          //...
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
                      Text('rides.summaryRideLabel'.tr(),
                          style: TextStyle(
                              fontFamily: 'MoveTextBold', fontSize: 24)),
                    ],
                  ),
                ),
                // Text(
                //   'Edit',
                //   style: TextStyle(
                //       fontFamily: 'MoveTextMedium',
                //       fontSize: 20,
                //       color: AppTheme().getPrimaryColor()),
                // )
              ],
            ),
            Divider(
              height: 35,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
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
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 30,
            child: Text(
              indexProduct.toString(),
              style: TextStyle(fontSize: 17),
            )),
        Container(
            // color: Colors.red,
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
        SizedBox(
          width: 10,
        ),
        Container(
          // color: Colors.amber,
          width: MediaQuery.of(context).size.width * 0.45,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productData['name'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontFamily: 'MoveTextMedium'),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '${productData['price']} • ${getItemsNumber()}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              )
            ],
          ),
        ),
      ]),
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
