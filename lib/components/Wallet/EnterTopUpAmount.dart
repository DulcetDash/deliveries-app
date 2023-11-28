import 'dart:convert';

import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Helpers/SuperHttp.dart';
import 'package:dulcetdash/components/Modules/GenericCircButton/GenericCircButton.dart';
import 'package:dulcetdash/components/Modules/GenericRectButton/GenericRectButton.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

class EnterTopUpAmount extends StatelessWidget {
  const EnterTopUpAmount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: context.watch<HomeProvider>().isLoadingPurchaseVoucher
                ? () {}
                : () {
                    context
                        .read<HomeProvider>()
                        .updateVoucherAmountToPurchase(voucher: 0);
                    Navigator.of(context).pop();
                  },
            child: Icon(
              Icons.arrow_back,
              size: AppTheme().getArrowBackSize(),
            ),
          ),
          title: Text('Purchase',
              style: TextStyle(
                  fontFamily: 'MoveBold',
                  fontSize: AppTheme().getHeaderPagesTitleSize())),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.white,
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: const Text(
                    'Voucher amount',
                    style: TextStyle(fontFamily: 'MoveBold', fontSize: 28),
                  ),
                ),
              ),
              const InputAmountToSendPart(),
              const Expanded(child: NoticePart()),
              const ValidationButtonsPart()
            ],
          ),
        ));
  }
}

//Input amount to send part
class InputAmountToSendPart extends StatelessWidget {
  const InputAmountToSendPart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
          child: ListTile(
        horizontalTitleGap: 0,
        contentPadding: const EdgeInsets.only(left: 0, right: 0, top: 20),
        leading: Container(
          alignment: Alignment.centerLeft,
          decoration:
              const BoxDecoration(border: Border(bottom: BorderSide(width: 2))),
          width: 40,
          height: 50,
          child: const Text('N\$',
              style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 21)),
        ),
        title: Container(
          height: 50,
          decoration:
              const BoxDecoration(border: Border(bottom: BorderSide(width: 2))),
          child: TextField(
            readOnly: context.watch<HomeProvider>().isLoadingPurchaseVoucher,
            onChanged: (value) {
              context
                  .read<HomeProvider>()
                  .updateVoucherAmountToPurchase(voucher: int.parse(value));
            },
            style: const TextStyle(fontSize: 25),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: 'Amount',
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 15)),
          ),
        ),
      )),
    );
  }
}

//Notice part
class NoticePart extends StatelessWidget {
  const NoticePart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: ListTile(
          horizontalTitleGap: -12,
          contentPadding: const EdgeInsets.only(left: 0, right: 0),
          leading: Container(
              alignment: Alignment.centerLeft,
              height: 30,
              width: 30,
              child: Icon(
                Icons.info,
                size: 20,
                color: AppTheme().getPrimaryColor(),
              )),
          title: Container(
            child: RichText(
                text: const TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'MoveTextLight'),
                    children: [
                  TextSpan(text: 'Your maximum amount is '),
                  TextSpan(
                      text: 'N\$5000',
                      style: TextStyle(fontFamily: 'MoveTextRegular'))
                ])),
          ),
        ),
      ),
    );
  }
}

//Validation buttons part
class ValidationButtonsPart extends StatelessWidget {
  const ValidationButtonsPart({Key? key}) : super(key: key);

  Future<void> _handleTopUp(BuildContext context) async {
    final amount = (context.read<HomeProvider>().voucherAmountToPurchase * 100)
        .toString(); //Convert to cents
    final isLoading = context.read<HomeProvider>().isLoadingPurchaseVoucher;

    if (amount.isEmpty || amount == '0' || isLoading) {
      // Handle empty amount case
      return;
    }

    context
        .read<HomeProvider>()
        .updateIsLoadingPurchaseVoucher(isLoading: true);

    try {
      SuperHttp superHttp = SuperHttp();

      Uri mainUrl = Uri.parse(
          Uri.encodeFull('${context.read<HomeProvider>().bridge}/topup'));

      final response = await superHttp.post(
        mainUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'userId': context.read<HomeProvider>().user_identifier
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        await _processPayment(responseData['clientSecret'], context);
      } else {
        // Handle server error
        context
            .read<HomeProvider>()
            .updateIsLoadingPurchaseVoucher(isLoading: false);
      }
    } catch (error) {
      context
          .read<HomeProvider>()
          .updateIsLoadingPurchaseVoucher(isLoading: false);
      // Handle network error
      showFailedPayment(context);
    }
  }

  Future<void> _processPayment(
      String clientSecret, BuildContext context) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
            billingDetailsCollectionConfiguration:
                const BillingDetailsCollectionConfiguration(
                    address: AddressCollectionMode.never),
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'DulcetDash',
            primaryButtonLabel:
                'Pay N\$${context.read<HomeProvider>().voucherAmountToPurchase}',
            customerId:
                context.read<HomeProvider>().userData['stripeCustomerId']),
      );

      await Stripe.instance.presentPaymentSheet().then((value) {
        context
            .read<HomeProvider>()
            .updateIsLoadingPurchaseVoucher(isLoading: false);
        showSuccessfulPayment(context);
      }).onError((error, stackTrace) {
        context
            .read<HomeProvider>()
            .updateIsLoadingPurchaseVoucher(isLoading: false);
        showFailedPayment(context);
      });
    } catch (e) {
      // Handle payment error
      context
          .read<HomeProvider>()
          .updateIsLoadingPurchaseVoucher(isLoading: false);
      showFailedPayment(context);
    }
  }

  void showSuccessfulPayment(BuildContext context) {
    showMaterialModalBottomSheet(
        backgroundColor: Colors.white,
        isDismissible: false,
        enableDrag: false,
        context: context,
        builder: (context) => Container(
            width: 300,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: SafeArea(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Divider(
                    height: MediaQuery.of(context).size.height * 0.1,
                    color: Colors.white,
                  ),
                  Icon(
                    Icons.check_circle,
                    size: 65,
                    color: AppTheme().getPrimaryColor(),
                  ),
                  const Divider(color: Colors.white),
                  const Text('Payment Successful',
                      style:
                          TextStyle(fontFamily: 'MoveTextBold', fontSize: 25)),
                  const Divider(
                    height: 20,
                    color: Colors.white,
                  ),
                  const Text(
                      'Your DulcetDash wallet has been successfully topped up with',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'MoveTextRegular', fontSize: 17)),
                  const Divider(
                    height: 35,
                    color: Colors.white,
                  ),
                  Text(
                      'N\$${context.read<HomeProvider>().voucherAmountToPurchase}',
                      style: TextStyle(
                          fontFamily: 'MoveBold',
                          fontSize: 35,
                          color: AppTheme().getPrimaryColor())),
                  const Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                    label: 'Done',
                    actuatorFunctionl: () {
                      Navigator.of(context).pushNamed('/WalletEntry');
                    },
                    isArrowShow: false,
                    horizontalPadding: 0,
                    labelFontSize: 24,
                  )
                ],
              ),
            ))));
  }

  void showFailedPayment(BuildContext context) {
    showMaterialModalBottomSheet(
        backgroundColor: Colors.white,
        isDismissible: false,
        enableDrag: false,
        context: context,
        builder: (context) => Container(
            width: 300,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: SafeArea(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Divider(
                    height: MediaQuery.of(context).size.height * 0.1,
                    color: Colors.white,
                  ),
                  Icon(
                    Icons.cancel,
                    size: 65,
                    color: AppTheme().getErrorColor(),
                  ),
                  Divider(color: Colors.white),
                  Text('Payment Failed',
                      style:
                          TextStyle(fontFamily: 'MoveTextBold', fontSize: 25)),
                  Divider(
                    height: 20,
                    color: Colors.white,
                  ),
                  Text(
                      'Sorry were we unable to conclude the purchase of you voucher',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'MoveTextRegular', fontSize: 17)),
                  Divider(
                    height: 35,
                    color: Colors.white,
                  ),
                  Text(
                      'N\$${context.read<HomeProvider>().voucherAmountToPurchase}',
                      style: TextStyle(fontFamily: 'MoveBold', fontSize: 35)),
                  Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                    label: 'Try again',
                    actuatorFunctionl: () {
                      Navigator.of(context).pop();
                    },
                    isArrowShow: false,
                    horizontalPadding: 0,
                    labelFontSize: 24,
                  )
                ],
              ),
            ))));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 25),
        child: Container(
          height: 100, //? Set height
          child: ListTile(
            leading: Container(
              width: MediaQuery.of(context).size.width / 2.2,
              child: RichText(
                text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                    children: [
                      const TextSpan(text: 'Your '),
                      TextSpan(
                          text: 'purchased voucher ',
                          style: TextStyle(
                              fontFamily: 'MoveTextBold',
                              color: AppTheme().getPrimaryColor())),
                      const TextSpan(text: 'will be automatically toped-up.')
                    ]),
              ),
            ),
            trailing: context.watch<HomeProvider>().isLoadingPurchaseVoucher
                ? CircularProgressIndicator(
                    color: AppTheme().getPrimaryColor(),
                  )
                : GenericCircButton(
                    backgroundColor: AppTheme().getPrimaryColor(),
                    actuatorFunctionl: () {
                      _handleTopUp(context);
                    },
                  ),
          ),
        ));
  }
}
