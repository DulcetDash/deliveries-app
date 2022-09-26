import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:orniss/components/GenericRectButton.dart';

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
                      width: 105,
                      height: 105,
                      child: Image.asset(
                        'assets/Images/nej.png',
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
                      'entry.big_title'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'MoveBold', fontSize: 27),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'entry.rides'.tr(),
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        width: 15,
                        child: Icon(Icons.circle, size: 5),
                      ),
                      Text(
                        'entry.deliveries'.tr(),
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        width: 15,
                        child: Icon(Icons.circle, size: 5),
                      ),
                      Text(
                        'entry.shopping'.tr(),
                        style: TextStyle(fontSize: 15),
                      )
                    ],
                  ),
                  Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                      label: 'entry.btn_label'.tr(),
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
