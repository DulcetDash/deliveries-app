// ignore_for_file: file_names
//Drawer

import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> userData = context.watch<HomeProvider>().userData;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 150,
            alignment: Alignment.centerLeft,
            child: DrawerHeader(
                padding: const EdgeInsets.only(
                  left: 0,
                  top: 30,
                ),
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(color: Colors.white),
                child: SafeArea(
                    bottom: false,
                    child: ListTile(
                        minVerticalPadding: 0,
                        onTap: () => Navigator.of(context)
                            .pushReplacementNamed('/Settings'),
                        horizontalTitleGap: 10,
                        leading: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  blurRadius: 7,
                                  spreadRadius: 0)
                            ],
                          ),
                          child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.black,
                              backgroundImage: NetworkImage(
                                userData['profile_picture'],
                              ),
                              child: null),
                        ),
                        title: Text(
                          userData['name'],
                          style: const TextStyle(
                              fontFamily: 'MoveBold',
                              fontSize: 20,
                              color: Colors.black),
                        ),
                        subtitle: Text(
                            context
                                        .watch<HomeProvider>()
                                        .userLocationDetails['osm_id'] !=
                                    null
                                ? context
                                    .watch<HomeProvider>()
                                    .userLocationDetails['city']
                                : 'drawer.searching'.tr(),
                            style: const TextStyle(
                                color: Colors.black, fontSize: 15)),
                        trailing: null
                        // const Icon(
                        //   Icons.arrow_forward_ios,
                        //   color: Colors.white,
                        //   size: 15,
                        // ),
                        ))),
          ),
          const SizedBox(
            height: 50,
          ),
          MenuOption(
            titleOption: 'drawer.yourRides'.tr(),
            showDivider: true,
            actuatorFnc: () =>
                Navigator.of(context).pushReplacementNamed('/YourRides'),
          ),
          MenuOption(
            titleOption: 'drawer.settings'.tr(),
            showDivider: true,
            actuatorFnc: () =>
                Navigator.of(context).pushReplacementNamed('/Settings'),
          ),
          MenuOption(
            titleOption: 'drawer.support'.tr(),
            showDivider: false,
            actuatorFnc: () =>
                Navigator.of(context).pushReplacementNamed('/Support'),
          ),
          MenuOption(
            titleOption: 'drawer.share'.tr(),
            showDivider: false,
            actuatorFnc: () =>
                Navigator.of(context).pushReplacementNamed('/Share'),
          ),
          Expanded(
              child: SafeArea(
            child: Container(
                alignment: Alignment.bottomLeft,
                // decoration:
                //     BoxDecoration(border: Border.all(color: Colors.red)),
                child: Container(
                    alignment: Alignment.centerLeft,
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    decoration: BoxDecoration(
                        // color: Colors.red,
                        border: Border(
                            top: BorderSide(
                                width: 1,
                                color: Colors.grey.withOpacity(0.2)))),
                    child: Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: ListTile(
                        leading: InkWell(
                            onTap: () async {
                              if (!await launchUrl(Uri.parse(
                                  'https://dulcetdash.com/privacy'))) {
                                throw 'Could not launch the URL';
                              }
                            },
                            child: Text('drawer.legal'.tr(),
                                style: TextStyle(fontSize: 16))),
                        trailing: const Text('v1.0.3',
                            style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                    ))),
          ))
        ],
      ),
    );
  }
}

class MenuOption extends StatelessWidget {
  final String titleOption;
  final bool showDivider;
  final actuatorFnc;

  const MenuOption(
      {Key? key,
      required this.titleOption,
      required this.showDivider,
      required this.actuatorFnc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: actuatorFnc,
          child: ListTile(
            title: Text(
              titleOption,
              style: const TextStyle(fontFamily: 'MoveTextBold', fontSize: 22),
            ),
          ),
        ),
        showDivider
            ? const Divider(
                color: Colors.white,
              )
            : const Text('')
      ],
    );
  }
}

//Drive for DulcetDash
class DriverForNej extends StatelessWidget {
  const DriverForNej({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, top: 25),
      child: InkWell(
        onTap: () async {
          if (!await launch('https://www.ornisstechnologies.com/contact')) {
            throw 'Could not launch the URL';
          }
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(color: AppTheme().getPrimaryColor()),
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              children: [
                Icon(
                  Icons.square,
                  size: 10,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 2,
                ),
                Text(
                  'Become a shopper',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontFamily: 'MoveTextMedium'),
                ),
                Expanded(child: SizedBox.shrink()),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
