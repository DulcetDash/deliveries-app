import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dulcetdash/components/Helpers/ProductOptionsViewer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:dulcetdash/components/GenericRectButton.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Helpers/Networking.dart';
import 'package:dulcetdash/components/Shopping/CartIcon.dart';
import 'package:dulcetdash/components/Shopping/Home.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ProductView extends StatefulWidget {
  const ProductView({Key? key}) : super(key: key);

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  bool isLoading = true; //Loading to get the stores.

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            child: Column(
              children: [Header(), ShowProductMain()],
            ),
          ),
        ),
      ),
    );
  }
}

//Genetic title
class GenericTitle extends StatelessWidget {
  const GenericTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Row(
          children: [
            Text('shopping.newStores'.tr(),
                style: TextStyle(fontFamily: 'MoveTextBold', fontSize: 19)),
          ],
        ),
      ),
    );
  }
}

//Header
class Header extends StatefulWidget {
  const Header({Key? key}) : super(key: key);

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.close)),
              ],
            )),
            Expanded(
                child: Container(
                    alignment: Alignment.center, child: SizedBox.shrink())),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [CartIcon()],
              ),
            )
          ],
        ),
      ),
    );
  }
}

//Showcase main categories products
class ShowProductMain extends StatelessWidget {
  const ShowProductMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> productData =
        context.watch<HomeProvider>().selectedProduct;

    if (mapEquals({}, productData)) return SizedBox.shrink();

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
        child: ProductDisplayModel(
          productData: productData,
          productImage: productData['pictures'][0].runtimeType.toString() ==
                  'List<dynamic>'
              ? productData['pictures'][0][0]
              : productData['pictures'][0],
          productName: productData['name'],
          productPrice: productData['price'],
        ),
      ),
    );
  }
}

//Product display model
class ProductDisplayModel extends StatelessWidget {
  final String productImage;
  final String productName;
  final String productPrice;
  final Map productData;

  const ProductDisplayModel(
      {Key? key,
      required this.productData,
      required this.productImage,
      required this.productName,
      required this.productPrice})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 35),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.24,
            child: CachedNetworkImage(
              fit: BoxFit.contain,
              imageUrl: productImage,
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
                Icons.photo,
                size: 45,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Text(productName,
              overflow: TextOverflow.ellipsis,
              maxLines: 5,
              style: TextStyle(fontFamily: 'MoveTextBold', fontSize: 19)),
        ),
        Visibility(
          visible: productData['description'] != null &&
              productData['description'].toString().trim().length > 0,
          child: SizedBox(
            height: 10,
          ),
        ),
        Visibility(
          visible: productData['description'] != null &&
              productData['description'].toString().trim().length > 0,
          child: Text(productData['description'].toString(),
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'MoveText',
                  color: AppTheme().getGenericDarkGrey())),
        ),
        SizedBox(
          height: 25,
        ),
        Text(
          'generic_text.information'.tr(),
          style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 16),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'generic_text.price'.tr(),
              style: TextStyle(fontSize: 17, color: Colors.grey.shade700),
            ),
            Text('N\$$productPrice',
                style: TextStyle(
                    fontFamily: 'MoveTextMedium',
                    fontSize: 21,
                    color: AppTheme().getPrimaryColor())),
          ],
        ),
        Divider(),
        ProductOptionsViewer(
          productData: productData,
        ),
        Expanded(child: Text('')),
        Visibility(
            visible: context.read<HomeProvider>().isProductInCart(
                    product: context.read<HomeProvider>().selectedProduct) ==
                false,
            child: ProductNumberIncrementor()),
        GenericRectButton(
            label: context.read<HomeProvider>().isProductInCart(
                    product: context.read<HomeProvider>().selectedProduct)
                ? 'shopping.itemInCart'.tr()
                : 'shopping.addToCart'.tr(),
            backgroundColor: context.read<HomeProvider>().isProductInCart(
                    product: context.read<HomeProvider>().selectedProduct)
                ? AppTheme().getPrimaryColor()
                : Colors.black,
            bottomSubtitleText: context.read<HomeProvider>().isProductInCart(
                    product: context.read<HomeProvider>().selectedProduct)
                ? 'shopping.clickToRemoveFromCart'.tr()
                : null,
            labelFontSize: 20,
            horizontalPadding: 0,
            isArrowShow: false,
            actuatorFunctionl: context.read<HomeProvider>().isProductInCart(
                        product:
                            context.read<HomeProvider>().selectedProduct) ==
                    false
                ? () {
                    if (context.read<HomeProvider>().isProductInCart(
                            product:
                                context.read<HomeProvider>().selectedProduct) ==
                        false) {
                      context.read<HomeProvider>().addProductToCart(
                          product:
                              context.read<HomeProvider>().selectedProduct);
                    }
                  }
                : () {
                    //!Remove from your cart
                    if (context.read<HomeProvider>().isProductInCart(
                        product:
                            context.read<HomeProvider>().selectedProduct)) {
                      context.read<HomeProvider>().removeProductFromCart(
                          product:
                              context.read<HomeProvider>().selectedProduct);
                    }
                  })
      ]),
    );
  }
}

//Increment/decrement the total number of items you want for this product
class ProductNumberIncrementor extends StatefulWidget {
  const ProductNumberIncrementor({Key? key}) : super(key: key);

  @override
  State<ProductNumberIncrementor> createState() =>
      _ProductNumberIncrementorState();
}

class _ProductNumberIncrementorState extends State<ProductNumberIncrementor> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        child: Row(children: [
          InkWell(
            onTap: () {
              //! Reduce the amount of this product by one
              Map<String, dynamic> productModel =
                  context.read<HomeProvider>().selectedProduct;
              productModel['items'] = productModel['items'] != null
                  ? productModel['items'] > 1
                      ? productModel['items'] - 1
                      : 1
                  : 1;
              //! Keep the original price
              productModel['base_price'] = productModel['base_price'] != null
                  ? productModel['base_price']
                  : productModel['price'];
              //! Update the price
              productModel['price'] = pricingToolbox(
                  currentPrice: productModel['base_price'],
                  multiplier: productModel['items']);
              //?Update the product
              context
                  .read<HomeProvider>()
                  .updateSelectedProduct(data: productModel);
            },
            child: Container(
                width: 50,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: context
                                .watch<HomeProvider>()
                                .selectedProduct['items'] !=
                            null
                        ? context
                                    .watch<HomeProvider>()
                                    .selectedProduct['items'] ==
                                1
                            ? Colors.grey.shade400
                            : Colors.black
                        : Colors.grey.shade400,
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(50)),
                child: Text('-',
                    style: TextStyle(
                        fontFamily: 'MoveTextBold',
                        fontSize: 19,
                        color: context
                                    .watch<HomeProvider>()
                                    .selectedProduct['items'] !=
                                null
                            ? context
                                        .watch<HomeProvider>()
                                        .selectedProduct['items'] ==
                                    1
                                ? Colors.black
                                : Colors.white
                            : Colors.black))),
          ),
          Container(
              width: 70,
              height: 30,
              alignment: Alignment.center,
              child: Text(
                  context.watch<HomeProvider>().selectedProduct['items'] != null
                      ? context
                          .watch<HomeProvider>()
                          .selectedProduct['items']
                          .toString()
                      : '1',
                  style:
                      TextStyle(fontFamily: 'MoveTextMedium', fontSize: 19))),
          InkWell(
            onTap: () {
              //! Add the amount of this product by one
              //? STOP AT 100
              if (context.read<HomeProvider>().selectedProduct['items'] ==
                      null ||
                  context.read<HomeProvider>().selectedProduct['items'] < 15) {
                Map<String, dynamic> productModel =
                    context.read<HomeProvider>().selectedProduct;
                productModel['items'] = productModel['items'] != null
                    ? productModel['items'] + 1
                    : 2;
                //! Keep the original price
                productModel['base_price'] = productModel['base_price'] != null
                    ? productModel['base_price']
                    : productModel['price'];
                //! Update the price
                productModel['price'] = pricingToolbox(
                    currentPrice: productModel['base_price'],
                    multiplier: productModel['items']);
                //?Update the product
                context
                    .read<HomeProvider>()
                    .updateSelectedProduct(data: productModel);
              }
            },
            child: Container(
                width: 50,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(50)),
                child: Text('+',
                    style: TextStyle(
                        fontFamily: 'MoveTextBold',
                        fontSize: 19,
                        color: Colors.white))),
          )
        ]),
      ),
    );
  }

  //Pricing toolbox
  String pricingToolbox(
      {required String currentPrice, required int multiplier}) {
    if (currentPrice.split(',').length > 1 &&
        currentPrice.split(',')[1].length == 2) //Remove and divide by 100
    {
      //Get the number
      double number = double.parse(
              currentPrice.replaceAll('N\$', '').trim().replaceAll(',', '')) /
          100;
      //...
      return (number * multiplier).toStringAsFixed(2);
    } else {
      //Get the number
      double number = double.parse(
          currentPrice.replaceAll('N\$', '').trim().replaceAll(',', ''));
      //...
      return (number * multiplier).toStringAsFixed(2);
    }
  }
}
