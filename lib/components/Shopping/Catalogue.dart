import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dulcetdash/components/Helpers/SuperHttp.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Helpers/Networking.dart';
import 'package:dulcetdash/components/Shopping/CartIcon.dart';
import 'package:dulcetdash/components/Shopping/Home.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Catalogue extends StatefulWidget {
  const Catalogue({Key? key}) : super(key: key);

  @override
  State<Catalogue> createState() => _CatalogueState();
}

class _CatalogueState extends State<Catalogue> {
  bool isLoading = true; //Loading to get the stores.
  final ScrollController _scrollController = ScrollController();
  int pageNumber = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _scrollController.addListener(_onScroll);

    //! Get the stores names
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GetCatalogueL1(context: context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50 &&
        !isLoading) {
      pageNumber += 1;
      GetCatalogueL1(context: context);
    }
  }

  Future GetCatalogueL1({required BuildContext context}) async {
    setState(() {
      isLoading = true;
    });

    //....
    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/getCatalogueFor'));

    //Assemble the bundle data
    //* @param type: the type of request (past, scheduled, business)
    Map<String, String> bundleData = {
      'store': context.read<HomeProvider>().selected_store['store_fp'],
      'structured': 'true',
      'pageNumber': pageNumber.toString(),
    };

    try {
      SuperHttp superHttp = SuperHttp();
      var response = await superHttp.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        Map tmpResponse = json.decode(response.body);
        //? Update
        context
            .read<HomeProvider>()
            .updateCatalogueLevel2_structured(data: tmpResponse['response']);
        setState(() {
          isLoading = false;
        });
      } else //Has some errors
      {
        Timer(const Duration(milliseconds: 1500), () {
          GetCatalogueL1(context: context);
        });
      }
    } catch (e) {
      log('8 - GetCatalogueL1');
      Timer(const Duration(milliseconds: 1500), () {
        GetCatalogueL1(context: context);
      });
    }
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
              children: [
                const Header(),
                const Divider(
                  thickness: 1,
                  height: 35,
                ),
                const SearchBar(),
                const Divider(
                  color: Colors.white,
                  height: 5,
                ),
                const TimeBar(),
                context.watch<HomeProvider>().shops_search_item_key.isNotEmpty
                    ? context
                                .watch<HomeProvider>()
                                .shops_items_searched
                                .isEmpty &&
                            context
                                    .watch<HomeProvider>()
                                    .isLoadingForItemsSearch ==
                                false
                        ? const Column(
                            children: [
                              Divider(
                                height: 60,
                              ),
                              Icon(Icons.info_outlined,
                                  color: Colors.grey, size: 30),
                              Divider(
                                height: 15,
                                color: Colors.white,
                              ),
                              Text(
                                'No products found for that search',
                                style:
                                    TextStyle(fontSize: 17, color: Colors.grey),
                              ),
                            ],
                          )
                        : Expanded(
                            child: ListView(
                            padding: const EdgeInsets.only(top: 10, bottom: 50),
                            children: [
                              GenericTitle(
                                  title: 'shopping.searchResults'.tr()),
                              const SizedBox(
                                height: 15,
                              ),
                              searchedCatalogue(context: context),
                            ],
                          ))
                    : ShowCaseMainCat(
                        scrollController: _scrollController,
                        isLoading: isLoading,
                      )
              ],
            ),
          ),
        ),
      ),
    );
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
              padding: const EdgeInsets.only(left: 20, right: 20),
              physics:
                  const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
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
                  key: Key(productData['id'].toString()),
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
    if (context.watch<HomeProvider>().selected_store['name'] == null)
      return SizedBox.shrink();

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
                          .updateCatalogueLevel1_structured(data: {});
                      //! Clear the search data
                      context
                          .read<HomeProvider>()
                          .updateShopsKeyItemsSearch(value: '');
                      context
                          .read<HomeProvider>()
                          .updateItemsSearchResults(value: []);
                      context.read<HomeProvider>().clearProductsData();
                      //...
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.arrow_back,
                        size: AppTheme().getArrowBackSize())),
              ],
            )),
            Expanded(
                flex: 3,
                child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      context.watch<HomeProvider>().selected_store['name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'MoveTextBold', fontSize: 19),
                    ))),
            const Expanded(
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
      "user_fingerprint":
          context.read<HomeProvider>().userData['user_identifier'].toString(),
      'store_fp':
          context.read<HomeProvider>().selected_store['store_fp'].toString()
    };

    // print(bundleData);

    try {
      SuperHttp superHttp = SuperHttp();
      var response = await superHttp.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        List<dynamic> tmpResponse = json.decode(response.body)['response'];
        //? Update
        if (tmpResponse.isNotEmpty) //Found some products
        {
          context
              .read<HomeProvider>()
              .updateItemsSearchResults(value: tmpResponse);
          context
              .read<HomeProvider>()
              .updateLoaderStatusItems_shop(status: false);
        } else //No items
        {
          context.read<HomeProvider>().updateItemsSearchResults(value: []);
          context
              .read<HomeProvider>()
              .updateLoaderStatusItems_shop(status: false);
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
      log(e.toString());
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

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        height: 45,
        child: TextField(
          controller: _controller,
          style: TextStyle(fontSize: 18),
          onChanged: _onChangeHandler,
          maxLength: 150,
          decoration: InputDecoration(
              counterText: "",
              contentPadding: EdgeInsets.only(bottom: 5),
              prefixIcon: Icon(Icons.search, color: Colors.black),
              prefixIconColor: Colors.black,
              suffixIcon: _controller.text.isEmpty
                  ? Container(width: 0)
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _controller.clear();
                          context
                              .read<HomeProvider>()
                              .updateShopsKeyItemsSearch(value: '');
                        });
                      },
                    ),
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
  final ScrollController scrollController;
  final bool isLoading;

  const ShowCaseMainCat(
      {Key? key, required this.scrollController, required this.isLoading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List dataProducts = getSegmentedListPer3(context: context);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
        child: ListView.separated(
            controller: scrollController,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            // scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              if (index < dataProducts.length) {
                List<Widget> tmpProductData = dataProducts[index];
                //...
                return Row(
                    key: Key(index.toString()), children: tmpProductData);
              } else {
                return Container(
                  key: Key(index.toString()),
                  height: 50,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppTheme().getPrimaryColor(),
                    ),
                  ),
                );
              }
            },
            separatorBuilder: (context, index) => const Divider(
                  height: 65,
                  thickness: 1,
                ),
            itemCount: dataProducts.length + (isLoading ? 1 : 0)),
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
          key: Key(tmpProductData['id']),
          productData: tmpProductData,
          index: j.toDouble(),
        ));
      }

      //If the chunk is less than 3, add empty containers
      if (chunks[i].length < 3) {
        for (var k = 0; k < 3 - chunks[i].length; k++) {
          rowItems.add(Expanded(child: Container()));
        }
      }

      //? Save
      mainListWidgets.add(rowItems);
    }

    //DONE
    return mainListWidgets;
  }
}

//Trio product shower
class TrioProductShower extends StatelessWidget {
  final List productData;
  const TrioProductShower({Key? key, required this.productData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(ucFirst(productData[0]['meta']['category']),
                  style: const TextStyle(
                      fontFamily: 'MoveTextBold', fontSize: 18)),
              InkWell(
                onTap: () {
                  Map<String, String> tmpData = {
                    "store": productData[0]['meta']['store_fp'],
                    "name": productData[0]['meta']['store'],
                    "fd_name":
                        context.read<HomeProvider>().selected_store['name'],
                    "category": productData[0]['meta']['category'],
                  };
                  //...
                  context
                      .read<HomeProvider>()
                      .updateSelectedDataL2ToShow(data: tmpData);
                  //? Move
                  Navigator.of(context).pushNamed('/catalogue_details_l2');
                },
                child: Row(
                  children: [
                    Text('shopping.viewAll'.tr(),
                        style: TextStyle(
                            fontFamily: 'MoveTextBold',
                            fontSize: 14,
                            color: AppTheme().getPrimaryColor())),
                    const SizedBox(
                      width: 4,
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: AppTheme().getPrimaryColor(),
                    )
                  ],
                ),
              )
            ],
          ),
          const Divider(height: 35, color: Colors.white),
          Container(
            // color: Colors.red,
            child: Row(
              children: [
                ProductDisplayModel(
                  productImage:
                      productData[0]['pictures'][0].runtimeType.toString() ==
                              'List<dynamic>'
                          ? productData[0]['pictures'][0][0]
                          : productData[0]['pictures'][0],
                  productName: productData[0]['name'],
                  productPrice: productData[0]['price'],
                  productData: productData[0],
                ),
                const SizedBox(
                  width: 20,
                ),
                ProductDisplayModel(
                  productImage:
                      productData[1]['pictures'][0].runtimeType.toString() ==
                              'List<dynamic>'
                          ? productData[1]['pictures'][0][0]
                          : productData[1]['pictures'][0],
                  productName: productData[1]['name'],
                  productPrice: productData[1]['price'],
                  productData: productData[1],
                ),
                const SizedBox(
                  width: 20,
                ),
                ProductDisplayModel(
                  productImage:
                      productData[2]['pictures'][0].runtimeType.toString() ==
                              'List<dynamic>'
                          ? productData[2]['pictures'][0][0]
                          : productData[2]['pictures'][0],
                  productName: productData[2]['name'],
                  productPrice: productData[2]['price'],
                  productData: productData[2],
                ),
              ],
            ),
          ),
        ],
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
    return Expanded(
      key: Key(productData['id']),
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

          final Map<String, dynamic> updatedProduct =
              (productData as Map<String, dynamic>);
          updatedProduct.addAll(tmpData);
          //...
          context
              .read<HomeProvider>()
              .updateSelectedProduct(data: updatedProduct);
          //Move
          Navigator.of(context).pushNamed('/product_view');
        },
        child: Container(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 90.0,
                child: CachedNetworkImage(
                  key: Key(productData['id']),
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
                  errorWidget: (context, url, error) {
                    return const Icon(
                      Icons.photo,
                      size: 60,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
            Text(productName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: 'MoveTextMedium', fontSize: 15)),
            const SizedBox(
              height: 5,
            ),
            Text("N\$$productPrice",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700))
          ]),
        ),
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
      key: Key(productData['id']),
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

          final Map<String, dynamic> updatedProduct =
              (productData as Map<String, dynamic>);
          updatedProduct.addAll(tmpData);

          //...
          context
              .read<HomeProvider>()
              .updateSelectedProduct(data: updatedProduct);
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
                    key: Key(productData['id']),
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
                      Icons.photo,
                      size: 35,
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
                  style: const TextStyle(
                      fontFamily: 'MoveTextMedium', fontSize: 15)),
            ),
            const SizedBox(
              height: 5,
            ),
            Text('N\$$productPrice',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700))
          ]),
        ),
      ),
    );
  }
}
