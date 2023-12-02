import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:dulcetdash/ThemesAndRoutes/AppRoutes.dart';
import 'package:dulcetdash/components/DrawerMenu.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Helpers/LocationOpsHandler.dart';
import 'package:dulcetdash/components/Helpers/Networking.dart';
import 'package:dulcetdash/components/Helpers/Watcher.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int refresher = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        refresher = 100;
      });
      // OneSignal.initialize("40feab96-1690-4991-a5e4-78d4d383aaee");
      // OneSignal.shared.setAppId("40feab96-1690-4991-a5e4-78d4d383aaee");
      initPlatformState();

      // // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
      // OneSignal.shared
      //     .promptUserForPushNotificationPermission()
      //     .then((accepted) {
      //   // print("Accepted permission: $accepted");
      // });

      // OneSignal.shared
      //     .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      //   // Will be called whenever the subscription changes
      //   // (ie. user gets registered with OneSignal and gets a user ID)
      //   // print(changes);
      // });
      // OneSignal.shared.getDeviceState().then((deviceState) {
      //   // context.read<HomeProvider>().updatePushnotification_token(
      //   //     data: json.decode(deviceState?.jsonRepresentation() as String));
      //   print("DeviceState: ${deviceState?.jsonRepresentation()}");
      // });
    });
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;

    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    // NOTE: Replace with your own app ID from https://www.onesignal.com
    OneSignal.shared.setAppId("40feab96-1690-4991-a5e4-78d4d383aaee");

    // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    // await OneSignal.shared.promptUserForPushNotificationPermission();
    OneSignal.shared.promptUserForPushNotificationPermission();

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      // Will be called whenever the subscription changes
      // (ie. user gets registered with OneSignal and gets a user ID)
      // print(changes);
    });
    OneSignal.shared.getDeviceState().then((deviceState) {
      // context.read<HomeProvider>().updatePushnotification_token(
      //     data: json.decode(deviceState?.jsonRepresentation() as String));
      print("DeviceState: ${deviceState?.jsonRepresentation()}");
    });
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
        drawer: DrawerMenu(),
        body: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                    color: AppTheme().getPrimaryColor(),
                    height: MediaQuery.of(context).size.height * 0.42,
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
                                  'Shop seamlessly',
                                  style: TextStyle(
                                      fontFamily: 'MoveTextMedium',
                                      fontSize: 27,
                                      color: Colors.white),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.68,
                                  child: Text(
                                    'home.subDescription'.tr(),
                                    style: TextStyle(
                                      height: 1.3,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 14,
                                ),
                                InkWell(
                                  onTap: () {
                                    //!Cleanse
                                    context
                                        .read<HomeProvider>()
                                        .clearEveryRequestsRelatedData();
                                    //! Update the selected service
                                    context
                                        .read<HomeProvider>()
                                        .updateSelectedService(
                                            service: 'shopping');
                                    //...
                                    Navigator.of(context)
                                        .pushNamed('/shopping');
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(1000)),
                                    width: 133,
                                    height: 40,
                                    child: Text(
                                      'Shop now',
                                      style: TextStyle(
                                          fontFamily: 'MoveTextBold',
                                          color: Colors.white,
                                          fontSize: 18),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          // Expanded(child: SizedBox.shrink()),
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  alignment: Alignment.centerRight,
                                  // color: Colors.amber,
                                  height:
                                      MediaQuery.of(context).size.height * 0.37,
                                  width: 180,
                                  child: Image.asset(
                                    'assets/Images/packagecp.png',
                                    fit: BoxFit.fitHeight,
                                  ),
                                )
                              ],
                            ),
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
      ),
    );
  }
}

//Quick access section
class QuickAccess extends StatelessWidget {
  const QuickAccess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List recentData = context.watch<HomeProvider>().recentlyVisitedShops;

    return Expanded(
      child: Container(
        // color: Colors.red,
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: recentData.isNotEmpty,
                child: Text('home.goAgain'.tr(),
                    style: TextStyle(
                        fontFamily: 'MoveTextBold',
                        fontSize: 18,
                        color: Colors.grey.shade600)),
              ),
              Expanded(
                child: recentData.isEmpty
                    ? renderEmptyRecent(context: context)
                    : ListView.separated(
                        padding: const EdgeInsets.only(top: 25),
                        itemBuilder: (context, index) {
                          Map<String, dynamic> storeData = recentData[index];

                          return ListTile(
                            onTap: () {
                              //!Cleanse
                              context
                                  .read<HomeProvider>()
                                  .clearEveryRequestsRelatedData();
                              //...
                              //! Save the store fp and store name
                              Map tmpData = {
                                'store_fp': storeData['fp'],
                                'name': storeData['fd_name'],
                                'structured': storeData['structured'] ?? false
                              };
                              //...
                              context
                                  .read<HomeProvider>()
                                  .updateSelectedStoreData(data: tmpData);
                              //...
                              Navigator.of(context).pushNamed('/catalogue');
                            },
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                                width: 60,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: HexColor(storeData['background']),
                                    border: Border.all(
                                        width: 1,
                                        color: HexColor(storeData['border']))),
                                child: CachedNetworkImage(
                                  // fit: BoxFit.contain,
                                  imageUrl: storeData['logo'],
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          SizedBox(
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
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                    Icons.error,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                                )),
                            title: Text(
                              storeData['fd_name'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text('${storeData['timeString']}'),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_sharp,
                              size: 15,
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: recentData.length),
              )
            ],
          ),
        ),
      ),
    );
  }

  //Render Empty recent data
  Widget renderEmptyRecent({required BuildContext context}) {
    return Container(
      // color: Colors.red,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag,
            size: 45,
            color: AppTheme().getGenericDarkGrey(),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'No recent shopping',
            style:
                TextStyle(fontSize: 15, color: AppTheme().getGenericDarkGrey()),
          ),
        ],
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
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        selections(
            context: context,
            imagePath: 'assets/Images/box_delivery.png',
            title: 'home.delivery'.tr(),
            actuator: () {
              GetWallet().exec(context: context);
              //!Cleanse
              context.read<HomeProvider>().clearEveryRequestsRelatedData();
              //...
              context
                  .read<HomeProvider>()
                  .updateLoadingRequestStatus(status: false);
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
            title: 'Groceries',
            actuator: () {
              GetWallet().exec(context: context);
              //!Cleanse
              context.read<HomeProvider>().clearEveryRequestsRelatedData();
              //...
              context
                  .read<HomeProvider>()
                  .updateLoadingRequestStatus(status: false);
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
              style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 17),
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
                InkWell(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Icon(
                    Icons.menu,
                    size: 30,
                    color: Colors.white,
                  ),
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
