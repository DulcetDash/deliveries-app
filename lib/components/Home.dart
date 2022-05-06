import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nej/components/CartIcon.dart';
import 'package:nej/components/Helpers/DataParser.dart';
import 'package:nej/components/Helpers/LocationOpsHandler.dart';
import 'package:nej/components/Helpers/Networking.dart';
import 'package:nej/components/Helpers/Watcher.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = true; //Loading to get the stores.

  // Create a new networking instance
  late LocationOpsHandler locationOpsHandler;
  Watcher watcher = Watcher();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //! Get the stores names
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      GetMainStores(context: context);
    });

    //Start with the timers
    //Location operation handlers
    locationOpsHandler = LocationOpsHandler(context: context);
    //Ask once for the location permission
    locationOpsHandler.requestLocationPermission();
    //globalDataFetcher.getCoreDate(context: context);
    watcher.startWatcher(context: context, actuatorFunctions: [
      {'name': 'LocationOpsHandler', 'actuator': locationOpsHandler},
    ]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locationOpsHandler.dispose();
    watcher.dispose();
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
      'user_identifier': context.read<HomeProvider>().user_identifier,
    };

    try {
      http.Response response = await http.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        // log(response.body.toString());
        List tmpResponse = json.decode(response.body);
        //? Update
        context.read<HomeProvider>().updateMainStores(data: tmpResponse);
        setState(() {
          isLoading = false;
        });
      } else //Has some errors
      {
        log(response.toString());
        Timer(const Duration(milliseconds: 500), () {
          GetMainStores(context: context);
        });
      }
    } catch (e) {
      log('8');
      log(e.toString());
      Timer(const Duration(milliseconds: 500), () {
        GetMainStores(context: context);
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
              ),
              AddressBar(),
              isLoading
                  ? Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.1),
                      child: Container(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.green,
                        ),
                      ))
                  : context.watch<HomeProvider>().mainStores.isEmpty
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
                                Text('Unable to connect to the Internet.',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 15))
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView(
                            children: [
                              Divider(
                                height: 30,
                                color: Colors.white,
                              ),
                              StoresListingMain(),
                              Visibility(
                                visible: context
                                        .watch<HomeProvider>()
                                        .mainStores
                                        .length >
                                    4,
                                child: Divider(
                                  height: 60,
                                  thickness: 1,
                                ),
                              ),
                              Visibility(
                                  visible: context
                                          .watch<HomeProvider>()
                                          .mainStores
                                          .length >
                                      4,
                                  child: GenericTitle()),
                              Visibility(
                                  visible: context
                                          .watch<HomeProvider>()
                                          .mainStores
                                          .length >
                                      4,
                                  child: NewStores())
                            ],
                          ),
                        )
            ],
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
                Icon(Icons.arrow_back),
              ],
            )),
            Expanded(
                child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Stores',
                      style:
                          TextStyle(fontFamily: 'MoveTextBold', fontSize: 18),
                    ))),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Icon(Icons.person),
                  ),
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
          style: TextStyle(fontSize: 18),
          decoration: InputDecoration(
              contentPadding: EdgeInsets.only(bottom: 5),
              prefixIcon: Icon(Icons.search, color: Colors.black),
              prefixIconColor: Colors.black,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              filled: true,
              fillColor: Colors.grey.shade200,
              floatingLabelStyle: const TextStyle(color: Colors.black),
              label: Text('Search stores'),
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
              : 'Finding location',
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
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            Row(
              children: context.watch<HomeProvider>().mainStores.isEmpty
                  ? []
                  : [
                      BigStoreShow(
                        imagePath: context.watch<HomeProvider>().mainStores[0]
                            ['logo'],
                        backgroundColor: HexColor(context
                            .watch<HomeProvider>()
                            .mainStores[0]['background']),
                        borderColor: HexColor(context
                            .watch<HomeProvider>()
                            .mainStores[0]['border']),
                        closingTime: context.watch<HomeProvider>().mainStores[0]
                            ['times']['string'],
                        productData:
                            context.watch<HomeProvider>().mainStores[0],
                      ),
                      Visibility(
                        visible:
                            context.watch<HomeProvider>().mainStores.length > 1,
                        child: SizedBox(
                          width: 20,
                        ),
                      ),
                      Visibility(
                        visible:
                            context.watch<HomeProvider>().mainStores.length > 1,
                        child: BigStoreShow(
                          imagePath: context.watch<HomeProvider>().mainStores[1]
                              ['logo'],
                          backgroundColor: HexColor(context
                              .watch<HomeProvider>()
                              .mainStores[1]['background']),
                          borderColor: HexColor(context
                              .watch<HomeProvider>()
                              .mainStores[1]['border']),
                          closingTime: context
                              .watch<HomeProvider>()
                              .mainStores[1]['times']['string'],
                          productData:
                              context.watch<HomeProvider>().mainStores[1],
                        ),
                      ),
                    ],
            ),
            Divider(
              color: Colors.white,
            ),
            Row(
              children: [
                Visibility(
                  visible: context.watch<HomeProvider>().mainStores.length > 2,
                  child: BigStoreShow(
                    imagePath: context.watch<HomeProvider>().mainStores[2]
                        ['logo'],
                    backgroundColor: HexColor(context
                        .watch<HomeProvider>()
                        .mainStores[2]['background']),
                    borderColor: HexColor(
                        context.watch<HomeProvider>().mainStores[2]['border']),
                    closingTime: context.watch<HomeProvider>().mainStores[2]
                        ['times']['string'],
                    productData: context.watch<HomeProvider>().mainStores[2],
                  ),
                ),
                Visibility(
                  visible: context.watch<HomeProvider>().mainStores.length > 3,
                  child: SizedBox(
                    width: 20,
                  ),
                ),
                Visibility(
                  visible: context.watch<HomeProvider>().mainStores.length > 3,
                  child: BigStoreShow(
                    imagePath: context.watch<HomeProvider>().mainStores[3]
                        ['logo'],
                    backgroundColor: HexColor(context
                        .watch<HomeProvider>()
                        .mainStores[3]['background']),
                    borderColor: HexColor(
                        context.watch<HomeProvider>().mainStores[3]['border']),
                    closingTime: context.watch<HomeProvider>().mainStores[3]
                        ['times']['string'],
                    productData: context.watch<HomeProvider>().mainStores[3],
                  ),
                ),
              ],
            )
          ],
        ),
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
    return Expanded(
      child: InkWell(
        onTap: () {
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
                      imageUrl: imagePath,
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
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        size: 30,
                        color: Colors.grey,
                      ),
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
      ),
    );
  }
}

//New stores
class NewStores extends StatelessWidget {
  const NewStores({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 70.0,
        // color: Colors.red,
        child: ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: context.watch<HomeProvider>().mainStores.length - 4,
            itemBuilder: ((context, index) {
              int indexAdjusted = index + 4;
              return NewStoreDisplay(
                productData:
                    context.watch<HomeProvider>().mainStores[indexAdjusted],
                storeName: context
                    .watch<HomeProvider>()
                    .mainStores[indexAdjusted]['fd_name'],
                storeType: context
                    .watch<HomeProvider>()
                    .mainStores[indexAdjusted]['type'],
                imagePath: context
                    .watch<HomeProvider>()
                    .mainStores[indexAdjusted]['logo'],
                backgroundColor: HexColor(context
                    .watch<HomeProvider>()
                    .mainStores[indexAdjusted]['background']),
                borderColor: HexColor(context
                    .watch<HomeProvider>()
                    .mainStores[indexAdjusted]['border']),
                closingTime: context
                    .watch<HomeProvider>()
                    .mainStores[indexAdjusted]['times']['string'],
              );
            })));
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
      padding: const EdgeInsets.only(left: 20, right: 30),
      child: InkWell(
        onTap: () {
          //! Save the store fp and store name
          Map tmpData = {
            'store_fp': productData['fp'],
            'name': productData['fd_name'],
            'structured': productData['structured']
          };
          //...
          context.read<HomeProvider>().updateSelectedStoreData(data: tmpData);
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
                ])
          ],
        ),
      ),
    );
  }
}
