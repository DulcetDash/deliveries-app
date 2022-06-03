//DeliverySummary

import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nej/components/GenericRectButton.dart';
import 'package:nej/components/Helpers/AppTheme.dart';
import 'package:nej/components/Helpers/DataParser.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DeliverySummary extends StatefulWidget {
  const DeliverySummary({Key? key}) : super(key: key);

  @override
  State<DeliverySummary> createState() => _DeliverySummaryState();
}

class _DeliverySummaryState extends State<DeliverySummary> {
  @override
  Widget build(BuildContext context) {
    Map payment_summary = context.read<HomeProvider>().getTotals_delivery();
    DataParser _dataParser = DataParser();

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LocationChoiceRecipientFront(
                  recipient_index: -1,
                  title: 'Pickup location',
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          context
                                      .read<HomeProvider>()
                                      .delivery_pickup['street'] !=
                                  null
                              ? _dataParser.getGenericLocationString(
                                  location: _dataParser.getRealisticPlacesNames(
                                      locationData: context
                                          .read<HomeProvider>()
                                          .delivery_pickup))
                              : 'Press here to set',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade500))
                    ],
                  ),
                  checked: true,
                  actuator: () => Navigator.of(context)
                      .pushNamed('/delivery_pickupLocation'),
                  shape: 'circle'),
            ),
            Divider(
              height: 40,
              color: Colors.white,
            ),
            Expanded(
              child: Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 5),
                  child: context
                          .watch<HomeProvider>()
                          .recipients_infos
                          .isNotEmpty
                      ? ListView.separated(
                          itemBuilder: (context, index) {
                            Map<String, dynamic> receipientData = context
                                .read<HomeProvider>()
                                .recipients_infos[index];

                            return LocationChoiceRecipientFront(
                                recipient_index: index,
                                title: receipientData['name'].toString().isEmpty
                                    ? 'Recipient ${index + 1}'
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
                                            Text(
                                                receipientData['phone']
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black))
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                        context.read<HomeProvider>().getRecipientDetails_indexBased(index: index, nature_data: 'dropoff_location')[0]['street'] != null
                                            ? _dataParser.getGenericLocationString(
                                                location: _dataParser.getRealisticPlacesNames(
                                                    locationData: context
                                                            .read<HomeProvider>()
                                                            .getRecipientDetails_indexBased(
                                                                index: index,
                                                                nature_data: 'dropoff_location')[
                                                        0]))
                                            : 'Press here to set',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: context
                                                        .read<HomeProvider>()
                                                        .validateRecipient_data_isolated(index: index)['opacity'] ==
                                                    1.0
                                                ? AppTheme().getPrimaryColor()
                                                : Colors.grey.shade500))
                                  ],
                                ),
                                checked: true,
                                actuator: () {});
                          },
                          separatorBuilder: (context, index) => Divider(
                                height: 30,
                              ),
                          itemCount: context
                              .watch<HomeProvider>()
                              .recipients_infos
                              .length)
                      : Padding(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.15),
                          child: Container(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 45,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  'No recipients added for your delivery',
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
                        Text('Delivery fee', style: TextStyle(fontSize: 17)),
                        Text(payment_summary['delivery_fee'],
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
                        Text('Handling fee', style: TextStyle(fontSize: 17)),
                        Text(payment_summary['service_fee'],
                            style: TextStyle(
                                fontSize: 19,
                                color: AppTheme().getPrimaryColor())),
                      ],
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
                        Text('Total',
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
                          label: 'Make your delivery',
                          labelFontSize: 22,
                          actuatorFunctionl: () {
                            requestForDelivery(context: context);
                          }),
                ],
              ),
            )
          ],
        )));
  }

  //Request for delivery
  Future requestForDelivery({required BuildContext context}) async {
    //? Start the loader
    context.read<HomeProvider>().updateLoadingRequestStatus(status: true);

    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/requestForRideOrDelivery'));

    //Assemble the bundle data
    List shopping_list = context.read<HomeProvider>().CART;
    //? For the request
    Map<String, String> bundleData = {
      "user_identifier": context.read<HomeProvider>().user_identifier,
      "payment_method": context.read<HomeProvider>().paymentMethod,
      "dropOff_data":
          json.encode(context.read<HomeProvider>().recipients_infos).toString(),
      "totals": json
          .encode(context.read<HomeProvider>().getTotals_delivery())
          .toString(),
      "pickup_location":
          json.encode(context.read<HomeProvider>().delivery_pickup).toString(),
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
          Navigator.of(context).pushNamed('/successfulRequest');
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
      expand: true,
      bounce: true,
      duration: Duration(milliseconds: 400),
      context: context,
      builder: (context) => LocalModal(
        scenario: scenario,
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
  final String shape;

  const LocationChoiceRecipientFront(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.actuator,
      required this.recipient_index,
      this.tracked = true,
      this.shape = 'square',
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
              ? recipient_index + 1 ==
                      context.read<HomeProvider>().recipients_infos.length
                  ? Icon(
                      shape == 'square' ? Icons.square : Icons.circle,
                      size: 13,
                      color:
                          checked ? AppTheme().getPrimaryColor() : Colors.grey,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          shape == 'square' ? Icons.square : Icons.circle,
                          size: 13,
                          color: checked
                              ? shape == 'circle'
                                  ? Colors.black
                                  : AppTheme().getPrimaryColor()
                              : Colors.grey,
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              width: 1,
                              height: 60,
                              decoration:
                                  BoxDecoration(border: Border.all(width: 1)),
                            ),
                          ),
                        ),
                      ],
                    )
              : Text(''),
          title: Text(
            title,
            style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 16),
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
        ));
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
            child: Padding(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
          child: Column(
            children: [
              Icon(Icons.warning, size: 50, color: AppTheme().getErrorColor()),
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
                  "We were unable to go forward with this shopping request because it seems like you have an unconfirmed shopping request in progress, please confirm it and try again.",
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
            child: Padding(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
          child: Column(
            children: [
              Icon(Icons.error, size: 50, color: AppTheme().getErrorColor()),
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
                  "We were unable to go forward with your shopping request due to an unexpected error, please try again and if it persists, please contact us through the Support tab.",
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
                      Text('Summary',
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
      return '$items items';
    } else {
      return '$items item';
    }
  }
}
