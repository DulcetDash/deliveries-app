//ShoppingSummary

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nej/components/GenericRectButton.dart';
import 'package:nej/components/Helpers/AppTheme.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
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
                                  'No items selected for your shopping.',
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
                        Text('Your cart', style: TextStyle(fontSize: 17)),
                        Text(payment_summary['cart'],
                            style: TextStyle(
                                fontSize: 20,
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
                        Text('Service fee', style: TextStyle(fontSize: 17)),
                        Text(payment_summary['service_fee'],
                            style: TextStyle(
                                fontSize: 20,
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
                          Text('Cash pickup fee',
                              style: TextStyle(fontSize: 17)),
                          Text(payment_summary['cash_pickup_fee'],
                              style: TextStyle(
                                  fontSize: 20,
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
                  GenericRectButton(
                      label: 'Shop now',
                      labelFontSize: 22,
                      actuatorFunctionl:
                          context.watch<HomeProvider>().CART.isNotEmpty
                              ? () {
                                  Navigator.of(context)
                                      .pushNamed('/paymentSetting');
                                }
                              : () {}),
                ],
              ),
            )
          ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    //! Restore the tmp selected product if changed
                    context.read<HomeProvider>().updateSelectedProduct(
                        data: context
                                    .read<HomeProvider>()
                                    .tmp_selectedProduct['name'] !=
                                null
                            ? context.read<HomeProvider>().tmp_selectedProduct
                            : context.read<HomeProvider>().selectedProduct);
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
                      Icon(Icons.arrow_back),
                      SizedBox(
                        width: 4,
                      ),
                      Text('Summary',
                          style: TextStyle(
                              fontFamily: 'MoveTextBold', fontSize: 24)),
                    ],
                  ),
                ),
                Text(
                  'Edit',
                  style: TextStyle(
                      fontFamily: 'MoveTextMedium',
                      fontSize: 20,
                      color: AppTheme().getPrimaryColor()),
                )
              ],
            ),
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
              fit: BoxFit.cover,
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
              SizedBox(
                height: 38,
                child: Text(
                  productData['name'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, fontFamily: 'MoveTextMedium'),
                ),
              ),
              SizedBox(
                height: 5,
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
