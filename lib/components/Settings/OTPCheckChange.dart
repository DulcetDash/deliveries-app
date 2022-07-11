import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:orniss/components/GenericRectButton.dart';
import 'package:orniss/components/Helpers/AppTheme.dart';
import 'package:orniss/components/Helpers/OTPVerificationInput/OTPVerificationInput.dart';
import 'package:orniss/components/Helpers/PhoneNumberInput/PhoneNumberInputEntry.dart';
import 'package:orniss/components/Helpers/TopLoader.dart';
import 'package:orniss/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';

class OTPCheckChange extends StatefulWidget {
  const OTPCheckChange({Key? key}) : super(key: key);

  @override
  State<OTPCheckChange> createState() => _OTPCheckChangeState();
}

class _OTPCheckChangeState extends State<OTPCheckChange> {
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
              child: OTPVerificationInput(
                sendAgain_actuator: () => checkAndOTPRequest(context: context),
                checkOTP_actuator: () => validateOTPCode(context: context),
              )),
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
                    'Unable to send the code',
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
                      "We were unable to send you the 4-digit code due to an unexpected error, please check your internet connection and try again.",
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

  //Check otp
  Future validateOTPCode({required BuildContext context}) async {
    //? Start the loader
    context.read<HomeProvider>().updateLoadingRequestStatus(status: true);

    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/validateUserOTP_changeNumber'));

    //Assemble the bundle data
    //? For the request
    Map<String, String> bundleData = {
      "phone":
          '${context.read<HomeProvider>().selectedCountryCodeData['dial_code']}${context.read<HomeProvider>().enteredPhoneNumber}',
      "hasAccount": 'true',
      "otp": context.read<HomeProvider>().otp_code.toString(),
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

        if (responseInfo['response']['status'] == 'success') //?Correct
        {
          showSuccessModal(context: context);
        } else //!Wrong code
        {
          showErrorModalError_otpCheck(context: context);
        }
      } else //Has some errors
      {
        log(response.toString());
        showErrorModalError_otpCheck(context: context);
      }
    } catch (e) {
      log('8');
      log(e.toString());
      showErrorModalError_otpCheck(context: context);
    }
  }

  //Show error modal checking otp
  void showErrorModalError_otpCheck({required BuildContext context}) {
    //! Swhitch loader to false
    context.read<HomeProvider>().updateLoadingRequestStatus(status: false);
    //! Clear the OTP field and code
    context.read<HomeProvider>().otpFieldController.clear();
    context.read<HomeProvider>().updateOTPCode(data: '');
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
                  Icon(Icons.info, size: 50, color: AppTheme().getErrorColor()),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Wrong code entered',
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
                      "The code that you have entered is not correct, please double check in your SMS the latest 4-digit code that we've sent.",
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

  void showSuccessModal({required BuildContext context}) {
    //! Swhitch loader to false
    context.read<HomeProvider>().updateLoadingRequestStatus(status: false);
    //! Clear the OTP field and code
    context.read<HomeProvider>().otpFieldController.clear();
    context.read<HomeProvider>().updateOTPCode(data: '');
    //...
    showMaterialModalBottomSheet(
      backgroundColor: Colors.white,
      expand: false,
      bounce: true,
      enableDrag: false,
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
                  Icon(Icons.check_circle,
                      size: 50, color: AppTheme().getPrimaryColor()),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Successfully changed',
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
                      "Your phone number has been successfully changed to ${context.read<HomeProvider>().selectedCountryCodeData['dial_code']}${context.read<HomeProvider>().enteredPhoneNumber}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                    label: 'Done',
                    labelFontSize: 20,
                    actuatorFunctionl: () {
                      Navigator.of(context).pushNamed('/Settings');
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
                Text(
                    'at ${context.read<HomeProvider>().selectedCountryCodeData['dial_code']}${context.read<HomeProvider>().enteredPhoneNumber}',
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
