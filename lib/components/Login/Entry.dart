import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:dulcetdash/components/GenericRectButton.dart';

class Entry extends StatefulWidget {
  const Entry({Key? key}) : super(key: key);

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  @override
  void initState() {
    // Adjust the provider based on the image type

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
        body: InkWell(
          onTap: () => Navigator.of(context).pushNamed('/PhoneInput'),
          child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: SafeArea(
                  child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 225,
                      height: 115,
                      child: Image.asset(
                        'assets/Images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  //Theme image
                  Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height * 0.30,
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset(
                      'assets/Images/cityscape.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      'Shop Confidently',
                      style: TextStyle(fontFamily: 'MoveBold', fontSize: 27),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'entry.deliveries'.tr(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        width: 15,
                        child: Icon(Icons.circle, size: 5),
                      ),
                      const Text(
                        'Groceries',
                        style: TextStyle(fontSize: 18),
                      )
                    ],
                  ),
                  const Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                      label: 'Get started',
                      labelFontSize: 19,
                      actuatorFunctionl: () =>
                          Navigator.of(context).pushNamed('/PhoneInput'))
                ],
              ))),
        ),
      ),
    );
  }
}
