// ignore_for_file: file_names

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:nej/components/Helpers/AppTheme.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
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
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 200,
            alignment: Alignment.centerLeft,
            child: DrawerHeader(
                padding: const EdgeInsets.only(left: 0, top: 30),
                margin: EdgeInsets.zero,
                decoration: const BoxDecoration(color: Colors.white),
                child: SafeArea(
                    bottom: false,
                    child: ListTile(
                        minVerticalPadding: 0,
                        onTap: () => Navigator.of(context)
                            .pushReplacementNamed('/Settings'),
                        horizontalTitleGap: 10,
                        leading: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.black,
                            // backgroundImage: Image.network(context.watch<HomeProvider>().userAccountDetails['profile_pciture']),
                            child: Image.network(
                              '',
                              fit: BoxFit.cover,
                              width: 70.0,
                              height: 70.0,
                              errorBuilder: (context, error, stackTrace) {
                                return const CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.white,
                                  backgroundImage: AssetImage(
                                    'assets/Images/user.png',
                                  ),
                                );
                              },
                            )),
                        title: Text(
                          'Dominique',
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
                                : 'Searching...',
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
          DriverForNej(),
          MenuOption(
            titleOption: 'Your rides',
            showDivider: true,
            actuatorFnc: () =>
                Navigator.of(context).pushReplacementNamed('/YourRides'),
          ),
          MenuOption(
            titleOption: 'Settings',
            showDivider: true,
            actuatorFnc: () =>
                Navigator.of(context).pushReplacementNamed('/Settings'),
          ),
          MenuOption(
            titleOption: 'Support',
            showDivider: false,
            actuatorFnc: () =>
                Navigator.of(context).pushReplacementNamed('/Support'),
          ),
          MenuOption(
            titleOption: 'Share',
            showDivider: false,
            actuatorFnc: () =>
                Navigator.of(context).pushReplacementNamed('/Support'),
          ),
          Expanded(
              child: SafeArea(
            child: Container(
                alignment: Alignment.bottomLeft,
                // decoration:
                //     BoxDecoration(border: Border.all(color: Colors.red)),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(
                                width: 1,
                                color: Colors.grey.withOpacity(0.2)))),
                    child: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: ListTile(
                        leading: InkWell(
                            onTap: () async {
                              if (!await launch(
                                  'https://www.somehtingawesomehere.com')) {
                                throw 'Could not launch the URL';
                              }
                            },
                            child: const Text('Legal',
                                style: TextStyle(fontSize: 16))),
                        trailing: const Text('v1.2.1',
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

//Drive for Nej
class DriverForNej extends StatelessWidget {
  const DriverForNej({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () => print('Drive for Nej'),
        child: Container(
          height: 50,
          decoration: BoxDecoration(color: AppTheme().getPrimaryColor()),
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              children: [
                Icon(
                  Icons.star_rate,
                  size: 16,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 2,
                ),
                Text(
                  'Drive or deliver with Nej',
                  style: TextStyle(fontSize: 15, color: Colors.white),
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
