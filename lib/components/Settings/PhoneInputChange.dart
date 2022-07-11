import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:orniss/components/GenericRectButton.dart';
import 'package:orniss/components/Helpers/AppTheme.dart';
import 'package:orniss/components/Helpers/PhoneNumberInput/PhoneNumberInputEntry.dart';
import 'package:orniss/components/Helpers/TopLoader.dart';
import 'package:orniss/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';

class PhoneInputChange extends StatefulWidget {
  const PhoneInputChange({Key? key}) : super(key: key);

  @override
  State<PhoneInputChange> createState() => _PhoneInputChangeState();
}

class _PhoneInputChangeState extends State<PhoneInputChange> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
              visible: context.watch<HomeProvider>().isLoadingForRequest,
              child: TopLoader()),
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
          Visibility(
            visible: context.watch<HomeProvider>().isLoadingForRequest == false,
            child: Padding(
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
                            fontSize: 14,
                            color: AppTheme().getGenericDarkGrey()),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: context.watch<HomeProvider>().isLoadingForRequest == false,
            child: Opacity(
              opacity:
                  context.watch<HomeProvider>().enteredPhoneNumber.isNotEmpty &&
                          context.watch<HomeProvider>().isPhoneEnteredValid
                      ? 1
                      : AppTheme().getFadedOpacityValue(),
              child: GenericRectButton(
                  horizontalPadding: 20,
                  label: 'Next',
                  labelFontSize: 20,
                  isArrowShow: false,
                  actuatorFunctionl: context
                              .watch<HomeProvider>()
                              .enteredPhoneNumber
                              .isNotEmpty &&
                          context.watch<HomeProvider>().isPhoneEnteredValid
                      ? () {
                          checkAndOTPRequest(context: context);
                        }
                      : () {}),
            ),
          )
        ],
      )),
    );
  }

  Future checkAndOTPRequest({required BuildContext context}) async {
    //? Start the loader
    context.read<HomeProvider>().updateLoadingRequestStatus(status: true);

    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/checkPhoneAndSendOTP_changeNumber_status'));

    //Assemble the bundle data
    //? For the request
    Map<String, String> bundleData = {
      "phone":
          '${context.read<HomeProvider>().selectedCountryCodeData['dial_code']}${context.read<HomeProvider>().enteredPhoneNumber}',
      "user_identifier":
          context.read<HomeProvider>().userData['user_identifier']
    };

    // print(bundleData);
    try {
      Response response = await post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        context.read<HomeProvider>().updateLoadingRequestStatus(status: false);
        log(response.body.toString());
        Map<String, dynamic> responseInfo = json.decode(response.body);

        if (responseInfo['response']['status'] ==
            'success') //Successfully checked
        {
          Navigator.of(context).pushNamed('/OTPCheckChange');
        } else if (responseInfo['response']['status'] ==
            'already_linked_toAnother') //Already in use
        {
          showErrorModalError_alreadyInUse(context: context);
        } else //Some Error
        {
          showErrorModalError(context: context);
        }
      } else //Has some errors
      {
        log(response.toString());
        showErrorModalError(context: context);
      }
    } catch (e) {
      log('8');
      log(e.toString());
      showErrorModalError(context: context);
    }
  }

  //Show error modal
  void showErrorModalError({required BuildContext context}) {
    //! Swhitch loader to false
    context.read<HomeProvider>().updateLoadingRequestStatus(status: false);
    //...
    showMaterialModalBottomSheet(
      backgroundColor: Colors.white,
      expand: false,
      bounce: true,
      duration: Duration(milliseconds: 250),
      context: context,
      builder: (context) => SafeArea(
        child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.05),
              child: Column(
                children: [
                  Icon(Icons.warning,
                      size: 50, color: AppTheme().getErrorColor()),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Unable to check your number',
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
                      "We were unable to check your mobile number due to an unexpected error, please check your internet connection and try again.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                    label: 'Try again',
                    labelFontSize: 20,
                    actuatorFunctionl: () {
                      Navigator.of(context).pop();
                    },
                    isArrowShow: false,
                  )
                ],
              ),
            )),
      ),
    );
  }

  //Phone number already linked to another user account
  //Error phone number already in use
  void showErrorModalError_alreadyInUse({required BuildContext context}) {
    //! Swhitch loader to false
    context.read<HomeProvider>().updateLoadingRequestStatus(status: false);
    //...
    showMaterialModalBottomSheet(
      backgroundColor: Colors.white,
      expand: false,
      bounce: true,
      duration: Duration(milliseconds: 250),
      context: context,
      builder: (context) => SafeArea(
        child: Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.05),
              child: Column(
                children: [
                  Icon(Icons.warning,
                      size: 50, color: AppTheme().getErrorColor()),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Phone number taken',
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
                      "We were unable to create your account because the phone number which which you are trying to proceed is already linked to another account. Please use another phone number and try again.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                    label: 'Try again',
                    labelFontSize: 20,
                    actuatorFunctionl: () {
                      Navigator.of(context).pop();
                    },
                    isArrowShow: false,
                  )
                ],
              ),
            )),
      ),
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
            Text('Change your mobile number',
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
