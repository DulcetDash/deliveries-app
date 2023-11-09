import 'package:dulcetdash/components/Helpers/AppTheme.dart';
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
                  top: false,
                  child: Column(
                    children: [
                      //Theme image
                      Container(
                        color: Colors.white,
                        height: MediaQuery.of(context).size.height * 0.45,
                        width: MediaQuery.of(context).size.width,
                        child: Image.asset(
                          'assets/Images/ddentry.jpg',
                          fit: BoxFit.fill,
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'Shop Easy, Delivered Fast.',
                          style:
                              TextStyle(fontFamily: 'MoveBold', fontSize: 28),
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
                            style: const TextStyle(fontSize: 19),
                          ),
                          const SizedBox(
                            width: 15,
                            child: Icon(Icons.circle, size: 5),
                          ),
                          const Text(
                            'Groceries',
                            style: TextStyle(fontSize: 19),
                          )
                        ],
                      ),
                      const Expanded(child: SizedBox.shrink()),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 15, right: 15),
                      //   child: Container(
                      //       child: RichText(
                      //           text: TextSpan(
                      //               style: TextStyle(
                      //                   color: AppTheme().getGenericDarkGrey(),
                      //                   fontFamily: 'MoveTextRegular',
                      //                   fontSize: 14),
                      //               children: [
                      //         TextSpan(
                      //             text:
                      //                 'By tapping Get started you agree to DulcetDash\'s '),
                      //         TextSpan(
                      //             text: 'Terms & Conditions',
                      //             style: TextStyle(
                      //                 fontFamily: 'MoveTextMedium',
                      //                 color: AppTheme().getPrimaryColor())),
                      //         TextSpan(text: ' and '),
                      //         TextSpan(
                      //             text: 'Privacy Policy',
                      //             style: TextStyle(
                      //                 fontFamily: 'MoveTextMedium',
                      //                 color: AppTheme().getPrimaryColor()))
                      //       ]))),
                      // ),
                      GenericRectButton(
                          label: 'Get started',
                          labelFontFamily: 'MoveTextBold',
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
