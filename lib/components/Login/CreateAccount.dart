import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:nej/components/GenericRectButton.dart';
import 'package:nej/components/Helpers/AppTheme.dart';
import 'package:nej/components/Helpers/OTPVerificationInput/OTPVerificationInput.dart';
import 'package:nej/components/Helpers/PhoneNumberInput/PhoneNumberInputEntry.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Header(),
          Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Image.asset(
              "assets/Images/newaccount.gif",
              height: 125.0,
              width: 125.0,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 25),
            child: Text(
              'No account? No problems!',
              style: TextStyle(fontFamily: 'MoveBold', fontSize: 25),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Text(
              'With a Nej account you will be able to make seamless rides, deliveries a even shop from various stores from the comfort of your couch.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          Expanded(child: SizedBox.shrink()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
                child: RichText(
                    text: TextSpan(
                        style: TextStyle(
                            color: AppTheme().getGenericDarkGrey(),
                            fontFamily: 'MoveTextRegular',
                            fontSize: 14),
                        children: [
                  TextSpan(text: 'By clicking '),
                  TextSpan(
                      text: 'Create your account',
                      style: TextStyle(
                          fontFamily: 'MoveTextBold', color: Colors.black)),
                  TextSpan(text: ', you automatically accept our '),
                  TextSpan(
                      text: 'terms and conditions.',
                      style: TextStyle(
                          fontFamily: 'MoveTextMedium',
                          color: AppTheme().getPrimaryColor()))
                ]))),
          ),
          GenericRectButton(
              label: 'Create your account',
              labelFontSize: 22,
              isArrowShow: false,
              actuatorFunctionl: () {})
        ],
      )),
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
            Container(
              width: MediaQuery.of(context).size.width,
              // color: Colors.red,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Howdy!',
                      style: TextStyle(
                          fontFamily: 'MoveTextMedium', fontSize: 20)),
                ],
              ),
            ),
            Divider(
              height: 15,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
