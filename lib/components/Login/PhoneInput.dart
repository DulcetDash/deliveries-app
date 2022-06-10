import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:nej/components/GenericRectButton.dart';
import 'package:nej/components/Helpers/AppTheme.dart';
import 'package:nej/components/Helpers/PhoneNumberInput/PhoneNumberInputEntry.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';

class PhoneInput extends StatefulWidget {
  const PhoneInput({Key? key}) : super(key: key);

  @override
  State<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(),
          //! Phone number input
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: PhoneNumberInputEntry(),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Visibility(
                visible:
                    context.watch<HomeProvider>().isPhoneEnteredValid == false,
                child: ErrorPhone()),
          ),
          Expanded(child: SizedBox.shrink()),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error,
                    size: 17,
                    color: AppTheme().getGenericDarkGrey(),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Flexible(
                    child: Text(
                      'By continuing you will receive an SMS for verification. Message and data rates my apply.',
                      style: TextStyle(
                          fontSize: 14, color: AppTheme().getGenericDarkGrey()),
                    ),
                  )
                ],
              ),
            ),
          ),
          GenericRectButton(
              horizontalPadding: 20,
              label: 'Next',
              labelFontSize: 20,
              isArrowShow: false,
              actuatorFunctionl: () {})
        ],
      )),
    );
  }
}

//Error phone number
class ErrorPhone extends StatelessWidget {
  const ErrorPhone({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        child: Row(children: [
          Icon(
            Icons.error,
            size: 16,
            color: AppTheme().getErrorColor(),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            'Invalid phone number',
            style: TextStyle(fontSize: 16, color: AppTheme().getErrorColor()),
          )
        ]),
      ),
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
        padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.arrow_back,
                    size: AppTheme().getArrowBackSize())),
            SizedBox(
              height: 15,
            ),
            Text('Enter your mobile number',
                style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 20)),
            Divider(
              height: 30,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
