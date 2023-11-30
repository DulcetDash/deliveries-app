import 'dart:developer';

import 'package:dulcetdash/components/Helpers/Networking.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dulcetdash/components/GenericRectButton.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:provider/provider.dart';

import 'Providers/HomeProvider.dart';

class PaymentSetting extends StatefulWidget {
  const PaymentSetting({Key? key}) : super(key: key);

  @override
  State<PaymentSetting> createState() => _PaymentSettingState();
}

class _PaymentSettingState extends State<PaymentSetting> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GetWallet().exec(context: context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Reset selection to cash if wallet balance is not enough
    if (context.watch<HomeProvider>().paymentMethod == 'wallet' &&
        !context.read<HomeProvider>().isBalanceSufficient()) {
      context.read<HomeProvider>().updatePaymentMethod(data: 'cash');
    }

    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
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
                            isWallet: true,
                            paymentMethod: 'Wallet',
                            isSelected:
                                context.watch<HomeProvider>().paymentMethod ==
                                    'wallet',
                            subtitle: 'Cashless payment with ease',
                            actuator: (newValue) {
                              if (context
                                  .read<HomeProvider>()
                                  .isBalanceSufficient()) {
                                context
                                    .read<HomeProvider>()
                                    .updatePaymentMethod(data: 'wallet');
                              }
                            }),
                        const Divider(
                          height: 50,
                        ),
                        MethodChoice(
                          paymentMethod: 'payments.cash'.tr(),
                          subtitle:
                              context.read<HomeProvider>().selectedService ==
                                          'delivery' ||
                                      context
                                              .read<HomeProvider>()
                                              .selectedService ==
                                          'ride'
                                  ? 'payments.cashOnPickup'.tr()
                                  : 'payments.payWithCash'.tr(),
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
                  label: context.read<HomeProvider>().selectedService == 'ride'
                      ? 'rides.done'.tr()
                      : 'generic_text.next'.tr(),
                  labelFontSize: 22,
                  isArrowShow:
                      context.read<HomeProvider>().selectedService != 'ride',
                  actuatorFunctionl: () {
                    //?1. SHOPPING
                    if (context.read<HomeProvider>().selectedService ==
                        'shopping') {
                      //! Update the pickup location to THIS if not specified yet
                      if (context
                              .read<HomeProvider>()
                              .manuallySettedCurrentLocation_pickup['street'] ==
                          null) //No pickup location already set
                      {
                        //Preset to the automatically computed by default
                        context
                            .read<HomeProvider>()
                            .updateManualPickupOrDropoff(
                                location_type: 'pickup',
                                location: context
                                    .read<HomeProvider>()
                                    .userLocationDetails);
                        //...
                        Navigator.of(context).pushNamed('/locationDetails');
                      } else //Next
                      {
                        Navigator.of(context).pushNamed('/locationDetails');
                      }
                    }
                    //?2. DELIVERY
                    else if (context.read<HomeProvider>().selectedService ==
                        'delivery') {
                      if (context
                              .read<HomeProvider>()
                              .delivery_pickup['street'] ==
                          null) //No pickup location already set
                      {
                        //Preset to the automatically computed by default
                        context
                            .read<HomeProvider>()
                            .updateManualPickupOrDropoff_delivery(
                                location_type: 'pickup',
                                location: context
                                    .read<HomeProvider>()
                                    .userLocationDetails);
                        //...
                        Navigator.of(context).pushNamed('/DeliverySummary');
                      } else //Next
                      {
                        Navigator.of(context).pushNamed('/DeliverySummary');
                      }
                    }
                    //?3. RIDE
                    else if (context.read<HomeProvider>().selectedService ==
                        'ride') {
                      Navigator.of(context).pop();
                    }
                  })
            ],
          ))),
    );
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
                      Icon(Icons.arrow_back,
                          size: AppTheme().getArrowBackSize()),
                      const SizedBox(
                        width: 4,
                      ),
                      const Text('Payment',
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
  final String extraSubtitle;
  final bool isWallet;
  final bool hasPickupFee;
  final bool isSelected;
  final actuator;

  const MethodChoice(
      {Key? key,
      required this.paymentMethod,
      this.subtitle = '',
      this.extraSubtitle = '',
      this.isWallet = false,
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
          activeColor: AppTheme().getPrimaryColor(),
          title: Text(
            paymentMethod,
            style: const TextStyle(fontFamily: 'MoveTextMedium', fontSize: 21),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: hasPickupFee &&
                      context.read<HomeProvider>().selectedService ==
                          'shopping',
                  child: Text(
                    'payments.topPickupIt'.tr(args: ["N\$0"]),
                    style: TextStyle(
                        fontFamily: 'MoveTextMedium',
                        color: AppTheme().getPrimaryColor(),
                        fontSize: 17),
                  ),
                ),
                Visibility(
                  visible: isWallet,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.square,
                            size: 10,
                          ),
                          const Text(
                            'Balance: ',
                            style: TextStyle(
                                fontFamily: 'MoveTextMedium', fontSize: 17),
                          ),
                          Text(
                            'N\$${context.read<HomeProvider>().walletData['balance']}',
                            style: TextStyle(
                                fontFamily: 'MoveTextMedium',
                                color: AppTheme().getSecondaryColor(),
                                fontSize: 19),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: !context
                            .watch<HomeProvider>()
                            .isBalanceSufficient(),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0, top: 15),
                          child: Container(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(),
                              Row(
                                children: [
                                  // Icon(
                                  //   Icons.warning,
                                  //   color: AppTheme().getErrorColor(),
                                  //   size: 15,
                                  // ),
                                  // const SizedBox(
                                  //   width: 5,
                                  // ),
                                  Flexible(
                                    child: Text(
                                        'Insufficient balance, you need at least N\$${context.read<HomeProvider>().getGeneralMainTotal()}',
                                        style: TextStyle(
                                            color: AppTheme().getErrorColor(),
                                            fontSize: 16)),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Colors.white,
                              ),
                              InkWell(
                                onTap: () => Navigator.of(context)
                                    .pushNamed('/WalletEntry'),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: AppTheme().getSecondaryColor(),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Top-up your wallet',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontFamily: 'MoveBold')),
                                  ),
                                ),
                              )
                            ],
                          )),
                        ),
                      )
                    ],
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
