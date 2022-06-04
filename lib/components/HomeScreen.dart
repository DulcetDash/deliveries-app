import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nej/components/Helpers/AppTheme.dart';
import 'package:nej/components/Helpers/LocationOpsHandler.dart';
import 'package:nej/components/Helpers/Networking.dart';
import 'package:nej/components/Helpers/Watcher.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Create a new networking instance
  late LocationOpsHandler locationOpsHandler;
  GetShoppingData _getShoppingData = GetShoppingData();
  Watcher watcher = Watcher();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //Start with the timers
    //Location operation handlers
    locationOpsHandler = LocationOpsHandler(context: context);
    //Ask once for the location permission
    locationOpsHandler.requestLocationPermission();
    //globalDataFetcher.getCoreDate(context: context);
    watcher.startWatcher(context: context, actuatorFunctions: [
      {'name': 'LocationOpsHandler', 'actuator': locationOpsHandler},
      {'name': 'getShoppingData', 'actuator': _getShoppingData}
    ]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locationOpsHandler.dispose();
    watcher.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                  color: AppTheme().getPrimaryColor(),
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Header(),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: MediaQuery.of(context).size.height * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, Vanessa',
                                style: TextStyle(
                                    fontFamily: 'MoveTextMedium',
                                    fontSize: 27,
                                    color: Colors.white),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.65,
                                child: Text(
                                  'Shop or make deliveries anywhere with Nej.',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: SizedBox.shrink()),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              // color: Colors.amber,
                              height: MediaQuery.of(context).size.height * 0.12,
                              width: 180,
                              child: Image.asset(
                                'assets/Images/package.png',
                                fit: BoxFit.fitHeight,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )),
              SizedBox(
                height: 35,
              ),
              ProductsSelection(),
              SizedBox(
                height: 35,
              ),
              Divider(
                thickness: 10,
                color: Colors.grey.shade100,
              ),
              SizedBox(
                height: 30,
              ),
              QuickAccess()
            ],
          )),
    );
  }
}

//Quick access section
class QuickAccess extends StatelessWidget {
  const QuickAccess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        // color: Colors.red,
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Go again',
                  style: TextStyle(
                      fontFamily: 'MoveTextBold',
                      fontSize: 18,
                      color: Colors.grey.shade600)),
              Expanded(
                child: ListView.separated(
                    padding: EdgeInsets.only(top: 25),
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          print('One of the go again pressed.');
                        },
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                            width: 60,
                            height: 50,
                            color: Colors.grey,
                            child: CachedNetworkImage(
                              // fit: BoxFit.contain,
                              imageUrl: '',
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 20.0,
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    width: 40.0,
                                    height: 40.0,
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
                        title: Text(
                          'Edgars',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text('You were here.'),
                        trailing: Icon(
                          Icons.arrow_forward_ios_sharp,
                          size: 15,
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: 2),
              )
            ],
          ),
        ),
      ),
    );
  }
}

//Products selection
class ProductsSelection extends StatelessWidget {
  const ProductsSelection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.90,
      alignment: Alignment.center,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        selections(
            context: context,
            imagePath: 'assets/Images/normalTaxiEconomy.jpeg',
            title: 'Ride',
            actuator: () {
              print('Ride');
              //! Update the selected service
              context
                  .read<HomeProvider>()
                  .updateSelectedService(service: 'ride');
              //...
              Navigator.of(context).pushNamed('/PassengersInput');
            }),
        selections(
            context: context,
            imagePath: 'assets/Images/box_delivery.png',
            title: 'Delivery',
            actuator: () {
              //! Update the selected service
              context
                  .read<HomeProvider>()
                  .updateSelectedService(service: 'delivery');
              //...
              Navigator.of(context).pushNamed('/delivery_recipients');
            }),
        selections(
            context: context,
            imagePath: 'assets/Images/cart.jpg',
            title: 'Shopping',
            actuator: () {
              //! Update the selected service
              context
                  .read<HomeProvider>()
                  .updateSelectedService(service: 'shopping');
              //...
              Navigator.of(context).pushNamed('/shopping');
            })
      ]),
    );
  }

  //Selection
  Widget selections(
      {required BuildContext context,
      required String imagePath,
      required String title,
      required actuator}) {
    return InkWell(
      onTap: actuator,
      highlightColor: Colors.white,
      splashFactory: NoSplash.splashFactory,
      child: Container(
        // color: Colors.red,
        width: 90,
        child: Column(
          children: [
            SizedBox(
              width: 90,
              height: 60,
              child: Image.asset(imagePath),
            ),
            SizedBox(
              height: 25,
            ),
            Text(
              title,
              style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 16),
            )
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
                Icon(
                  Icons.menu,
                  size: 30,
                  color: Colors.white,
                )
              ],
            )),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Text('')],
              ),
            )
          ],
        ),
      ),
    );
  }
}
