import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nej/components/GenericRectButton.dart';
import 'package:nej/components/Helpers/Networking.dart';
import 'package:nej/components/Home.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
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
    //! Get the stores names
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      GetCatalogueL1(context: context);
    });
  }

  Future GetCatalogueL1({required BuildContext context}) async {
    //....
    // Uri mainUrl = Uri.parse(Uri.encodeFull(
    //     '${context.read<HomeProvider>().bridge}/getCatalogueFor'));

    // //Assemble the bundle data
    // //* @param type: the type of request (past, scheduled, business)
    // Map<String, String> bundleData = {
    //   'store': context.read<HomeProvider>().selected_store['store_fp'],
    //   'structured': 'true'
    // };

    // try {
    //   http.Response response = await http.post(mainUrl, body: bundleData);

    //   if (response.statusCode == 200) //Got some results
    //   {
    //     // log(response.body.toString());
    //     Map tmpResponse = json.decode(response.body);
    //     // log(tmpResponse['response']['WOMEN'].toString());
    //     //? Update
    //     context
    //         .read<HomeProvider>()
    //         .updateCatalogueLevel1_structured(data: tmpResponse['response']);
    //     setState(() {
    //       isLoading = false;
    //     });
    //   } else //Has some errors
    //   {
    //     log(response.toString());
    //     Timer(const Duration(milliseconds: 500), () {
    //       GetCatalogueL1(context: context);
    //     });
    //   }
    // } catch (e) {
    //   log('8');
    //   log(e.toString());
    //   Timer(const Duration(milliseconds: 500), () {
    //     GetCatalogueL1(context: context);
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [Header(), ShowProductMain()],
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
            Text('New Stores',
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
                      //! Clear the data
                      context
                          .read<HomeProvider>()
                          .updateSelectedProduct(data: {});
                      //...
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
                children: [Icon(Icons.shopping_cart)],
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
        context.read<HomeProvider>().selectedProduct;

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
        child: ProductDisplayModel(
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

  const ProductDisplayModel(
      {Key? key,
      required this.productImage,
      required this.productName,
      required this.productPrice})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 35),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.26,
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
                Icons.error,
                size: 30,
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
        SizedBox(
          height: 25,
        ),
        Text(
          'Information',
          style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 16),
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Price',
              style: TextStyle(fontSize: 17, color: Colors.grey.shade700),
            ),
            Text(productPrice,
                style: TextStyle(
                    fontFamily: 'MoveTextMedium',
                    fontSize: 21,
                    color: Colors.green)),
          ],
        ),
        Expanded(child: Text('')),
        GenericRectButton(
            label: 'Add to cart',
            labelFontSize: 20,
            horizontalPadding: 0,
            isArrowShow: false,
            actuatorFunctionl: () {})
      ]),
    );
  }
}
