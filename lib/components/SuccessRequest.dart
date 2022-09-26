import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:orniss/components/GenericRectButton.dart';
import 'package:orniss/components/Helpers/AppTheme.dart';
import 'package:orniss/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';

class SuccessRequest extends StatelessWidget {
  const SuccessRequest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
          child: Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
        child: Column(
          children: [
            Icon(Icons.check_circle,
                size: 50, color: AppTheme().getPrimaryColor()),
            SizedBox(
              height: 15,
            ),
            Text(
              'utils.successRequestTitle'.tr(),
              style: TextStyle(
                fontFamily: 'MoveTextMedium',
                fontSize: 19,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Text(
                context.read<HomeProvider>().selectedService == 'delivery'
                    ? 'utils.deliverySuccess'.tr()
                    : context.read<HomeProvider>().selectedService == 'shopping'
                        ? 'utils.shoppingSuccess'.tr()
                        : 'utils.rideSuccess'.tr(),
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(child: SizedBox.shrink()),
            GenericRectButton(
              label: context.read<HomeProvider>().selectedService == 'delivery'
                  ? 'utils.trackDelivery'.tr()
                  : context.read<HomeProvider>().selectedService == 'shopping'
                      ? 'utils.trackShopping'.tr()
                      : 'utils.trackRide'.tr(),
              labelFontSize: 20,
              actuatorFunctionl: () {
                //! Clear the shopping cart
                context.read<HomeProvider>().clearCart();

                ///...
                Navigator.of(context).pushNamed('/');
              },
            )
          ],
        ),
      )),
    ));
  }
}
