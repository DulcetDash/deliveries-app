import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:nej/components/GenericRectButton.dart';
import 'package:provider/provider.dart';

import 'Providers/HomeProvider.dart';

class PaymentSetting extends StatefulWidget {
  const PaymentSetting({Key? key}) : super(key: key);

  @override
  State<PaymentSetting> createState() => _PaymentSettingState();
}

class _PaymentSettingState extends State<PaymentSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(
          children: [
            Header(),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: ListView(
                    children: [
                      MethodChoice(
                        paymentMethod: 'Mobile money',
                        subtitle: 'Ewallet, Blue wallet or Easy wallet',
                        isSelected:
                            context.watch<HomeProvider>().paymentMethod ==
                                'mobile_money',
                        actuator: (newValue) {
                          context
                              .read<HomeProvider>()
                              .updatePaymentMethod(data: 'mobile_money');
                        },
                      ),
                      Divider(
                        height: 50,
                      ),
                      MethodChoice(
                        paymentMethod: 'Cash',
                        subtitle: 'Pay using cash',
                        hasPickupFee: true,
                        isSelected:
                            context.watch<HomeProvider>().paymentMethod ==
                                'cash',
                        actuator: (newValue) {
                          context
                              .read<HomeProvider>()
                              .updatePaymentMethod(data: 'cash');
                        },
                      )
                    ],
                  )),
            ),
            GenericRectButton(
                label: 'Next',
                labelFontSize: 22,
                actuatorFunctionl: () {
                  Navigator.of(context).pushNamed('/locationDetails');
                })
          ],
        )));
  }
}

//Header
class Header extends StatelessWidget {
  const Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 20, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back),
                      SizedBox(
                        width: 4,
                      ),
                      Text('Payment',
                          style: TextStyle(
                              fontFamily: 'MoveTextBold', fontSize: 24))
                    ],
                  ),
                )
              ],
            ),
            Divider(
              height: 40,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}

//Payment method choice
class MethodChoice extends StatelessWidget {
  final String paymentMethod;
  final String subtitle;
  final bool hasPickupFee;
  final bool isSelected;
  final actuator;

  const MethodChoice(
      {Key? key,
      required this.paymentMethod,
      this.subtitle = '',
      this.hasPickupFee = false,
      required this.isSelected,
      required this.actuator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        // color: Colors.red,
        alignment: Alignment.centerLeft,
        child: CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: Colors.green,
          title: Text(
            paymentMethod,
            style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 18),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: hasPickupFee,
                  child: Text(
                    '+N\$45 to pick it up.',
                    style: TextStyle(
                        fontFamily: 'MoveTextMedium',
                        color: Colors.green,
                        fontSize: 17),
                  ),
                )
              ],
            ),
          ),
          value: isSelected,
          onChanged: actuator,
          controlAffinity:
              ListTileControlAffinity.trailing, //  <-- leading Checkbox
        ));
  }
}
