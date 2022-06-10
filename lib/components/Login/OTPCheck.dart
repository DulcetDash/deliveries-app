import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:nej/components/GenericRectButton.dart';
import 'package:nej/components/Helpers/AppTheme.dart';
import 'package:nej/components/Helpers/OTPVerificationInput/OTPVerificationInput.dart';
import 'package:nej/components/Helpers/PhoneNumberInput/PhoneNumberInputEntry.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';

class OTPCheck extends StatefulWidget {
  const OTPCheck({Key? key}) : super(key: key);

  @override
  State<OTPCheck> createState() => _OTPCheckState();
}

class _OTPCheckState extends State<OTPCheck> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(),
          //! Phone number input
          Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: OTPVerificationInput()),
          // Padding(
          //   padding: const EdgeInsets.only(left: 20, right: 20),
          //   child: Visibility(
          //       visible:
          //           context.watch<HomeProvider>().isPhoneEnteredValid == false,
          //       child: ErrorOtp()),
          // )
        ],
      )),
    );
  }
}

//Error phone number
class ErrorOtp extends StatelessWidget {
  const ErrorOtp({Key? key}) : super(key: key);

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
            'Incorrect code entered.',
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter the 5-digit code sent to you',
                    style:
                        TextStyle(fontFamily: 'MoveTextMedium', fontSize: 19)),
                SizedBox(
                  height: 7,
                ),
                Text('at +264856997167',
                    style: TextStyle(
                        fontFamily: 'MoveTextMedium',
                        fontSize: 19,
                        color: AppTheme().getPrimaryColor()))
              ],
            ),
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
