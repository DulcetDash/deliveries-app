import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dulcetdash/components/Helpers/SuperHttp.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Helpers/DataParser.dart';
import 'package:dulcetdash/components/Helpers/LocationOpsHandler.dart';
import 'package:dulcetdash/components/Helpers/Networking.dart';
import 'package:dulcetdash/components/Helpers/Watcher.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:dulcetdash/components/Shopping/CartIcon.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = true; //Loading to get the stores.

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //! Get the stores names
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GetMainStores(context: context);
    });
  }

  Future GetMainStores({required BuildContext context}) async {
    //? Set the main stores to empty
    context.read<HomeProvider>().updateMainStores(data: []);
    //....
    Uri mainUrl = Uri.parse(
        Uri.encodeFull('${context.read<HomeProvider>().bridge}/getStores'));

    //Assemble the bundle data
    //* @param type: the type of request (past, scheduled, business)
    Map<String, String> bundleData = {
      'user_identifier':
          context.read<HomeProvider>().userData['user_identifier'],
    };

    try {
      SuperHttp superHttp = SuperHttp();
      var response = await superHttp.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        // log(response.body.toString());
        List tmpResponse = json.decode(response.body)['response'];
        //? Update
        context.read<HomeProvider>().updateMainStores(data: tmpResponse);
        setState(() {
          isLoading = false;
        });
      } else //Has some errors
      {
        // log(response.toString());
        Timer(const Duration(milliseconds: 2500), () {
          GetMainStores(context: context);
        });
      }
    } catch (e) {
      log('8');
      log(e.toString());
      Timer(const Duration(milliseconds: 2500), () {
        GetMainStores(context: context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 1)).then((value) =>
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.black,
          systemNavigationBarDividerColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarColor: Colors.black,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        )));

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
                  height: 35,
                ),
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
                    : context.watch<HomeProvider>().mainStores.isEmpty
                        ? Container(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * 0.1),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.wifi_off,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text('generic_text.unableToConnectToNet'.tr(),
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 15))
                                ],
                              ),
                            ),
                          )
                        : context
                                .watch<HomeProvider>()
                                .stores_search_key
                                .isNotEmpty
                            ? searchedStores(context: context)
                            : Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.only(bottom: 55),
                                  children: [
                                    GenericTitle(
                                        title: 'shopping.frequent'.tr()),
                                    const StoresListingMain(),
                                    Visibility(
                                      visible: context
                                              .watch<HomeProvider>()
                                              .mainStores
                                              .length >
                                          4,
                                      child: const Divider(
                                        height: 60,
                                        thickness: 1,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Visibility(
                                        visible: context
                                                .watch<HomeProvider>()
                                                .mainStores
                                                .length >
                                            4,
                                        child: GenericTitle(
                                          title: 'shopping.newStores'.tr(),
                                        )),
                                    Visibility(
                                        visible: context
                                                .watch<HomeProvider>()
                                                .mainStores
                                                .length >
                                            4,
                                        child: const NewStores())
                                  ],
                                ),
                              )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //? Show searched catalogue
  Widget searchedStores({required BuildContext context}) {
    List searchedData = context.watch<HomeProvider>().stores_searched;

    return Container(
        // color: Colors.red,
        child: Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  Map<String, dynamic> storeData = searchedData[index];

                  return NewStoreDisplay(
                    storeName: storeData['fd_name'],
                    imagePath: storeData['logo'],
                    backgroundColor: HexColor(storeData['background']),
                    borderColor: HexColor(storeData['border']),
                    closingTime: storeData['times']['string'],
                    productData: storeData,
                  );
                },
                separatorBuilder: (context, index) => const Divider(
                      height: 50,
                    ),
                itemCount: searchedData.length)));
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
                      context.read<HomeProvider>().clearProductsData();

                      //! Clear the data
                      context
                          .read<HomeProvider>()
                          .updateCatalogueLevel1_structured(data: {});
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
                      'shopping.stores'.tr(),
                      style:
                          TextStyle(fontFamily: 'MoveTextBold', fontSize: 18),
                    ))),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.only(right: 15),
                  //   child: Icon(Icons.person),
                  // ),
                  CartIcon()
                ],
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        height: 45,
        child: TextField(
          onChanged: (value) {
            context
                .read<HomeProvider>()
                .updateStoresKeyItemsSearch(value: value);
          },
          style: TextStyle(fontSize: 18),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.only(bottom: 5),
              prefixIcon: Icon(Icons.search, color: Colors.black),
              prefixIconColor: Colors.black,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              filled: true,
              fillColor: Colors.grey.shade200,
              floatingLabelStyle: const TextStyle(color: Colors.black),
              label: Text('shopping.searchStores'.tr()),
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
class AddressBar extends StatelessWidget {
  final DataParser _dataParser = DataParser();

  AddressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, String> locationData = _dataParser.getRealisticPlacesNames(
        locationData: context.watch<HomeProvider>().userLocationDetails);
    return Container(
      child: ListTile(
        horizontalTitleGap: 0,
        leading: Icon(
          Icons.home,
          color: Colors.black,
        ),
        title: Text(
          locationData['suburb'] != null
              ? locationData['suburb'].toString()
              : 'generic_text.findingYourLocation_label'.tr(),
          style: TextStyle(fontFamily: 'MoveTextMedium'),
        ),
        subtitle: Text(
          '${locationData['location_name']}, ${locationData['city']}',
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 15,
        ),
      ),
    );
  }
}

// Stores
class StoresListingMain extends StatefulWidget {
  const StoresListingMain({Key? key}) : super(key: key);

  @override
  State<StoresListingMain> createState() => _StoresListingMainState();
}

class _StoresListingMainState extends State<StoresListingMain> {
  @override
  Widget build(BuildContext context) {
    List<dynamic> newStoresList =
        context.watch<HomeProvider>().mainStores.length > 4
            ? context.watch<HomeProvider>().mainStores.sublist(0, 4)
            : context.watch<HomeProvider>().mainStores;

    return Container(
      child: GridView.count(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        physics:
            NeverScrollableScrollPhysics(), // to disable GridView's scrolling
        shrinkWrap: true, // You won't see infinite size error
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        // Generate 100 widgets that display their index in the List.
        children: List.generate(newStoresList.length, (index) {
          return BigStoreShow(
            imagePath: newStoresList[index]['logo'] ?? 'none',
            backgroundColor: HexColor(newStoresList[index]['background']),
            borderColor: HexColor(newStoresList[index]['border']),
            closingTime: newStoresList[index]['times']['string'],
            productData: newStoresList[index],
          );
        }),
      ),
    );
  }
}

// Big store showoff
class BigStoreShow extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final String imagePath;
  final String closingTime;
  final Map productData;

  const BigStoreShow(
      {Key? key,
      this.backgroundColor = Colors.black,
      this.borderColor = Colors.black,
      required this.imagePath,
      this.closingTime = "Closes in 3hours",
      required this.productData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key(productData['fp']),
      onTap: () {
        context.read<HomeProvider>().clearProductsData();
        //! Save the store fp and store name
        Map tmpData = productData;
        tmpData['store_fp'] = productData['fp'];
        tmpData['name'] = productData['fd_name'];
        //...
        context.read<HomeProvider>().updateSelectedStoreData(data: tmpData);
        //...
        Navigator.of(context).pushNamed('/catalogue');
      },
      child: Container(
        decoration: BoxDecoration(
            color: backgroundColor, border: Border.all(color: borderColor)),
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: SizedBox(
                  height: 50,
                  child: CachedNetworkImage(
                    imageUrl: imagePath ?? 'none',
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) => SizedBox(
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
                    errorWidget: (context, url, error) => Container(
                        alignment: Alignment.center,
                        child: Text(productData['fd_name'],
                            style: const TextStyle(fontSize: 18))),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.black.withOpacity(0.7)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 3, bottom: 3),
                    child: Text(closingTime,
                        style: TextStyle(
                            fontFamily: 'MoveTextRegular',
                            fontSize: 13,
                            color: Colors.white)),
                  )),
            )
          ],
        ),
      ),
    );
  }
}

//New stores
class NewStores extends StatelessWidget {
  const NewStores({Key? key}) : super(key: key);

  //int indexAdjusted = index + 4;
  //context.watch<HomeProvider>().mainStores.length - 4

  @override
  Widget build(BuildContext context) {
    List<dynamic> newStoresList =
        context.watch<HomeProvider>().mainStores.sublist(4);

    return Container(
      // color: Colors.red,
      child: GridView.count(
        padding: EdgeInsets.only(left: 20, right: 20),
        physics:
            NeverScrollableScrollPhysics(), // to disable GridView's scrolling
        shrinkWrap: true, // You won't see infinite size error
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        // Generate 100 widgets that display their index in the List.
        children: List.generate(newStoresList.length, (index) {
          return BigStoreShow(
            imagePath: newStoresList[index]['logo'] ?? 'none',
            backgroundColor: HexColor(newStoresList[index]['background']),
            borderColor: HexColor(newStoresList[index]['border']),
            closingTime: newStoresList[index]['times']['string'],
            productData: newStoresList[index],
          );
        }),
      ),
    );
  }

  // //?Get the new stores
  // List<Widget> getNewStores(BuildContext context) {

  // }
}

//New stores display
class NewStoreDisplay extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final String imagePath;
  final String closingTime;
  final String storeType;
  final String storeName;
  final Map productData;

  const NewStoreDisplay(
      {Key? key,
      this.backgroundColor = Colors.black,
      this.borderColor = Colors.black,
      required this.imagePath,
      this.closingTime = "Closes in 3hours",
      required this.storeName,
      this.storeType = 'Store',
      required this.productData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        height: 70,
        child: InkWell(
          onTap: () {
            context.read<HomeProvider>().clearProductsData();

            //! Save the store fp and store name
            Map tmpData = {
              'store_fp': productData['fp'],
              'name': productData['fd_name'],
              'structured': productData['structured']
            };
            //...
            context.read<HomeProvider>().updateSelectedStoreData(data: tmpData);
            //...
            // context.read<HomeProvider>().updateStoresKeyItemsSearch(value: '');
            //...
            Navigator.of(context).pushNamed('/catalogue');
          },
          child: Row(
            children: [
              Container(
                  decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border.all(color: borderColor)),
                  width: 70,
                  height: 70,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CachedNetworkImage(
                      imageUrl: imagePath,
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
                  )),
              SizedBox(
                width: 15,
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storeName,
                      style:
                          TextStyle(fontFamily: 'MoveTextMedium', fontSize: 17),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      storeType,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Expanded(
                        child: Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(closingTime)))
                  ]),
              Expanded(
                child: SizedBox.shrink(),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 15,
              )
            ],
          ),
        ),
      ),
    );
  }
}
