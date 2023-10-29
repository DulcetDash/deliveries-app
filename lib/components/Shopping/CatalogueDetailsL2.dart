import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Helpers/Networking.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:dulcetdash/components/Shopping/CartIcon.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CatalogueDetailsL2 extends StatefulWidget {
  const CatalogueDetailsL2({Key? key}) : super(key: key);

  @override
  State<CatalogueDetailsL2> createState() => _CatalogueDetailsL2State();
}

class _CatalogueDetailsL2State extends State<CatalogueDetailsL2> {
  bool isLoading = true; //Loading to get the stores.

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //! Get the stores names
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GetCatalogueL2(context: context);
    });
  }

  Future GetCatalogueL2({required BuildContext context}) async {
    //....
    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/getCatalogueFor'));

    //Assemble the bundle data
    //* @param type: the type of request (past, scheduled, business)
    Map<String, String> bundleData =
        context.read<HomeProvider>().selectedDataL2ToShow;

    print(bundleData);

    try {
      http.Response response = await http.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        // log(response.body.toString());
        Map tmpResponse = json.decode(response.body);
        // log(tmpResponse['response']['WOMEN'].toString());
        //? Update
        context
            .read<HomeProvider>()
            .updateCatalogueLevel2_structured(data: tmpResponse['response']);
        setState(() {
          isLoading = false;
        });
      } else //Has some errors
      {
        log(response.toString());
        Timer(const Duration(milliseconds: 500), () {
          GetCatalogueL2(context: context);
        });
      }
    } catch (e) {
      log('8');
      log(e.toString());
      Timer(const Duration(milliseconds: 500), () {
        GetCatalogueL2(context: context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Header(),
              Divider(
                thickness: 1,
                height: 35,
              ),
              SearchBar(),
              Divider(
                color: Colors.white,
                height: 5,
              ),
              TimeBar(),
              context
                              .watch<HomeProvider>()
                              .catalogueData_level2_structured
                              .isEmpty ==
                          false &&
                      isLoading == false
                  ? Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 20, bottom: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                              ucFirst(context
                                      .read<HomeProvider>()
                                      .catalogueData_level2_structured[0]
                                  ['meta']['category']),
                              style: TextStyle(
                                  fontFamily: 'MoveTextBold', fontSize: 18)),
                        ],
                      ),
                    )
                  : SizedBox.shrink(),
              isLoading
                  ? Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.1),
                      child: Container(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppTheme().getPrimaryColor(),
                        ),
                      ))
                  : context
                          .watch<HomeProvider>()
                          .catalogueData_level2_structured
                          .isEmpty
                      ? Container(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.1),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.wifi_off,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text('generic_text.unableToConnectToNet'.tr(),
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 15))
                              ],
                            ),
                          ),
                        )
                      : context
                              .watch<HomeProvider>()
                              .shops_search_item_key
                              .isNotEmpty
                          ? Expanded(
                              child: ListView(
                              padding: EdgeInsets.only(top: 10, bottom: 50),
                              children: [
                                GenericTitle(
                                    title: 'shopping.searchResults'.tr()),
                                SizedBox(
                                  height: 15,
                                ),
                                searchedCatalogue(context: context),
                              ],
                            ))
                          : ShowCaseMainCat(),
            ],
          ),
        ),
      ),
    );
  }

  //? Only upper the first char
  String ucFirst(String text) {
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
  }

  //? Show searched catalogue
  Widget searchedCatalogue({required BuildContext context}) {
    List searchedData = context.watch<HomeProvider>().shops_items_searched;

    return context.watch<HomeProvider>().isLoadingForItemsSearch
        ? Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
            child: Align(
              child: Container(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppTheme().getPrimaryColor(),
                ),
              ),
            ))
        : Container(
            // color: Colors.red,
            child: GridView.count(
              padding: EdgeInsets.only(left: 20, right: 20),
              physics:
                  NeverScrollableScrollPhysics(), // to disable GridView's scrolling
              shrinkWrap: true, // You won't see infinite size error
              // Create a grid with 2 columns. If you change the scrollDirection to
              // horizontal, this produces 2 rows.
              crossAxisCount: 2,
              mainAxisSpacing: 40,
              crossAxisSpacing: 20, childAspectRatio: 0.89,
              // Generate 100 widgets that display their index in the List.
              children: List.generate(searchedData.length, (index) {
                Map<String, dynamic> productData = searchedData[index];

                // print(productData['product_picture']);

                return ProductDisplayModel_search(
                  index: index,
                  productImage:
                      productData['product_picture'].runtimeType.toString() ==
                              'String'
                          ? productData['product_picture']
                          : productData['product_picture'][0]
                                      .runtimeType
                                      .toString() ==
                                  'List<dynamic>'
                              ? productData['product_picture'][0][0]
                              : productData['product_picture'][0],
                  productName: productData['product_name'],
                  productPrice: productData['product_price'],
                  productData: productData,
                );
                // return Text('item');
              }),
            ),
          );
  }
}

//Genetic title
class GenericTitle extends StatelessWidget {
  final String title;
  const GenericTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Row(
          children: [
            Text(title, style: TextStyle(fontFamily: 'MoveBold', fontSize: 16)),
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
                          .updateCatalogueLevel2_structured(data: []);

                      //! Clear the search data
                      context
                          .read<HomeProvider>()
                          .updateShopsKeyItemsSearch(value: '');
                      context
                          .read<HomeProvider>()
                          .updateItemsSearchResults(value: []);
                      //...
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.arrow_back,
                        size: AppTheme().getArrowBackSize())),
              ],
            )),
            Expanded(
                child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      context.watch<HomeProvider>().selected_store['name'],
                      style:
                          TextStyle(fontFamily: 'MoveTextBold', fontSize: 19),
                    ))),
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

//Search bar
class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  //!Search for items in a specific store
  Future SearchForItemsInAStore({required BuildContext context}) async {
    //Start the loader
    context.read<HomeProvider>().updateLoaderStatusItems_shop(status: true);

    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/getResultsForKeywords'));

    //Assemble the bundle data
    //* @param type: the type of request (past, scheduled, business)
    Map<String, String> bundleData = {
      "store": context
          .read<HomeProvider>()
          .selected_store['name']
          .toString()
          .toUpperCase(),
      "key": context.read<HomeProvider>().shops_search_item_key.toString(),
      'category': context
          .read<HomeProvider>()
          .catalogueData_level2_structured[0]['meta']['category']
          .toString()
          .toUpperCase(),
      "user_fingerprint":
          context.read<HomeProvider>().userData['user_identifier'].toString(),
      'store_fp':
          context.read<HomeProvider>().selected_store['store_fp'].toString()
    };

    // print(bundleData);

    try {
      http.Response response = await http.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        context
            .read<HomeProvider>()
            .updateLoaderStatusItems_shop(status: false);
        // log(response.body.toString());
        List<dynamic> tmpResponse = json.decode(response.body)['response'];
        //? Update
        if (tmpResponse.isNotEmpty) //Found some products
        {
          context
              .read<HomeProvider>()
              .updateItemsSearchResults(value: tmpResponse);
        } else //No items
        {
          context.read<HomeProvider>().updateItemsSearchResults(value: []);
        }
      } else //Has some errors
      {
        // print(response.toString());
        // showErrorModal(context: context);
        context.read<HomeProvider>().updateItemsSearchResults(value: []);
        context
            .read<HomeProvider>()
            .updateLoaderStatusItems_shop(status: false);
      }
    } catch (e) {
      // print('8');
      // print(e.toString());
      // showErrorModal(context: context);
      context.read<HomeProvider>().updateItemsSearchResults(value: []);
      context.read<HomeProvider>().updateLoaderStatusItems_shop(status: false);
    }
  }

  Timer? searchOnStoppedTyping;

  _onChangeHandler(value) {
    const duration = Duration(
        milliseconds:
            800); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping!.cancel()); // clear timer
    }
    setState(() => searchOnStoppedTyping = new Timer(duration, () {
          //! Update the typed key
          context.read<HomeProvider>().updateShopsKeyItemsSearch(value: value);
          //...Search
          SearchForItemsInAStore(context: context);
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        height: 45,
        child: TextField(
          onChanged: _onChangeHandler,
          maxLength: 150,
          style: TextStyle(fontSize: 18),
          decoration: InputDecoration(
              counterText: "",
              contentPadding: EdgeInsets.only(bottom: 5),
              prefixIcon: Icon(Icons.search, color: Colors.black),
              prefixIconColor: Colors.black,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              filled: true,
              fillColor: Colors.grey.shade200,
              floatingLabelStyle: const TextStyle(color: Colors.black),
              label: Text('shopping.searchInStore'.tr(args: [
                '${context.watch<HomeProvider>().selected_store['name']}'
              ])),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Color.fromRGBO(0, 0, 0, 1)),
                  borderRadius: BorderRadius.circular(1)),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(1))),
        ),
      ),
    );
  }
}

//Address bar
class TimeBar extends StatelessWidget {
  const TimeBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        horizontalTitleGap: -10,
        leading: Icon(
          Icons.access_time_filled_outlined,
          color: Colors.black,
          size: 20,
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            context.read<HomeProvider>().selected_store['times'] != null
                ? context.read<HomeProvider>().selected_store['times']['string']
                : 'shopping.findingClosingTime'.tr(),
            style: TextStyle(fontFamily: 'MoveTextRegular', fontSize: 16),
          ),
        ),
        // subtitle: Text('Can\'t shop after that.'),
        // trailing: Icon(
        //   Icons.arrow_forward_ios,
        //   size: 15,
        // ),
      ),
    );
  }
}

//Showcase main categories products
class ShowCaseMainCat extends StatelessWidget {
  const ShowCaseMainCat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List dataProducts = getSegmentedListPer3(context: context);
    // return Text('LIST');
    // return Wrap(
    //   children: List.generate(
    //     context.watch<HomeProvider>().catalogueData_level2_structured.length,
    //     (index) {
    //       Map tmpProductData = context
    //           .read<HomeProvider>()
    //           .catalogueData_level2_structured[index];

    //       log(tmpProductData.toString());
    //       //...
    //       return ProductShower(
    //         productData: tmpProductData,
    //       );
    //     },
    //   ),
    // );
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
        child: ListView.separated(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            // scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              List<Widget> tmpProductData = dataProducts[index];

              log(tmpProductData.toString());
              //...
              return Row(children: tmpProductData);
            },
            separatorBuilder: (context, index) => const Divider(
                  height: 65,
                  thickness: 1,
                ),
            itemCount: dataProducts.length),
      ),
    );
  }

  //? Return segmented list
  List getSegmentedListPer3({required BuildContext context}) {
    //? Draw an index map for all the elements
    int totalSize =
        context.read<HomeProvider>().catalogueData_level2_structured.length;

    List products =
        context.read<HomeProvider>().catalogueData_level2_structured;

    var chunks = [];
    int chunkSize = 3;
    for (var i = 0; i < products.length; i += chunkSize) {
      chunks.add(products.sublist(i,
          i + chunkSize > products.length ? products.length : i + chunkSize));
    }

    //! Create the global widget array
    List mainListWidgets = [];

    for (var i = 0; i < chunks.length; i++) {
      List<Widget> rowItems = [];
      for (var j = 0; j < chunks[i].length; j++) {
        Map tmpProductData = chunks[i][j];
        //...
        rowItems.add(ProductShower(
          productData: tmpProductData,
          index: j.toDouble(),
        ));
      }
      //? Save
      mainListWidgets.add(rowItems);
    }

    //DONE
    return mainListWidgets;
  }
}

//Trio product shower
class ProductShower extends StatelessWidget {
  final Map productData;
  final double index;
  const ProductShower({Key? key, required this.productData, this.index = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Flexible(
        child: Row(
          children: [
            ProductDisplayModel(
                productImage:
                    productData['pictures'][0].runtimeType.toString() ==
                            'List<dynamic>'
                        ? productData['pictures'][0][0]
                        : productData['pictures'][0],
                productName: productData['name'],
                productPrice: productData['price'],
                productData: productData),
            Visibility(
              visible: index < 2,
              child: SizedBox(
                width: 20,
              ),
            )
          ],
        ),
      ),
    );
  }

  //? Only upper the first char
  String ucFirst(String text) {
    return "${text[0].toUpperCase()}${text.substring(1).toLowerCase()}";
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
      required this.productImage,
      required this.productName,
      required this.productPrice,
      required this.productData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: InkWell(
        onTap: () {
          //! Form the saving data object for the selected item
          Map<String, dynamic> tmpData = {
            "index": productData['index'],
            "name": productData['name'],
            "price": productData['price'],
            "pictures": productData['pictures'],
            "sku": productData['sku'],
            "meta": productData['meta']
          };
          //...
          context.read<HomeProvider>().updateSelectedProduct(data: tmpData);
          //Move
          Navigator.of(context).pushNamed('/product_view');
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 90.0,
              child: CachedNetworkImage(
                fit: BoxFit.cover,
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
          Text(productName,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 14)),
          SizedBox(
            height: 5,
          ),
          Text(productPrice,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700))
        ]),
      ),
    );
  }
}

//Product display model search
class ProductDisplayModel_search extends StatelessWidget {
  final String productImage;
  final String productName;
  final String productPrice;
  final int index;
  final Map productData;

  const ProductDisplayModel_search(
      {Key? key,
      required this.productImage,
      required this.productName,
      required this.productPrice,
      required this.productData,
      required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.amber,
      // height: 800,
      child: InkWell(
        onTap: () {
          //! Form the saving data object for the selected item
          Map<String, dynamic> tmpData = {
            "index": index,
            "name": productData['product_name'],
            "price": productData['product_price'],
            "pictures": productData['product_picture'],
            "sku": productData['sku'],
            "meta": productData['meta']
          };
          //...
          context.read<HomeProvider>().updateSelectedProduct(data: tmpData);
          //Move
          Navigator.of(context).pushNamed('/product_view');
        },
        child: Container(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Align(
                child: SizedBox(
                  // width: MediaQuery.of(context).size.width,
                  height: 90.0,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: productImage,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => SizedBox(
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
            ),
            Container(
              // color: Colors.red,
              height: 55,
              child: Text(productName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 15)),
            ),
            SizedBox(
              height: 5,
            ),
            Text(productPrice,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700))
          ]),
        ),
      ),
    );
  }
}
