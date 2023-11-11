import 'dart:convert';
import 'dart:developer';

import 'package:dulcetdash/components/Helpers/SuperHttp.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:dulcetdash/components/GenericRectButton.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Helpers/OTPVerificationInput/OTPVerificationInput.dart';
import 'package:dulcetdash/components/Helpers/PhoneNumberInput/PhoneNumberInputEntry.dart';
import 'package:dulcetdash/components/Helpers/TopLoader.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
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
        '${context.read<HomeProvider>().bridge}/checkPhoneAndSendOTP_status'));

    //Assemble the bundle data
    //? For the request
    Map<String, String> bundleData = {
      "phone":
          '${context.read<HomeProvider>().selectedCountryCodeData['dial_code']}${context.read<HomeProvider>().enteredPhoneNumber}'
    };

    // print(bundleData);
    try {
      SuperHttp superHttp = SuperHttp();
      var response = await superHttp.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        context.read<HomeProvider>().updateLoadingRequestStatus(status: false);
        log(response.body.toString());
        Map<String, dynamic> responseInfo = json.decode(response.body);

        //Update the login phase 1 check data
        context.read<HomeProvider>().updateLoginPhase1Data(data: responseInfo);
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
                    'otp_check.unableToSendCode_title'.tr(),
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
                      "otp_check.unableToSendCode_msg".tr(),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                    label: 'generic_text.tryAgain'.tr(),
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
        '${context.read<HomeProvider>().bridge}/validateUserOTP'));

    //Assemble the bundle data
    //? For the request
    Map<String, String> bundleData = {
      "phone":
          '${context.read<HomeProvider>().selectedCountryCodeData['dial_code']}${context.read<HomeProvider>().enteredPhoneNumber}',
      "hasAccount": context
          .read<HomeProvider>()
          .loginPhase1Data['response']['hasAccount']
          .toString(),
      "otp": context.read<HomeProvider>().otp_code.toString(),
      "user_identifier": context
                  .read<HomeProvider>()
                  .loginPhase1Data['response']['user_identifier'] !=
              null
          ? context.read<HomeProvider>().loginPhase1Data['response']
              ['user_identifier']
          : "false"
    };

    // print(bundleData);
    try {
      SuperHttp superHttp = SuperHttp();
      var response = await superHttp.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        context.read<HomeProvider>().updateLoadingRequestStatus(status: false);
        // log(response.body.toString());
        Map<String, dynamic> responseInfo = json.decode(response.body);
        print(responseInfo);

        if (responseInfo['response'] == 'success') //?Correct
        {
          //! Clear the OTP field and code
          context.read<HomeProvider>().otpFieldController.clear();
          context.read<HomeProvider>().updateOTPCode(data: '');

          if (responseInfo['account_state'] ==
              'full') //Already has an account - update
          {
            context
                .read<HomeProvider>()
                .updateUserDataErrorless(data: responseInfo['userData']);
            //! Persist data
            context.read<HomeProvider>().peristDataMap();
            // //?Move to home
            Navigator.of(context).pushNamed('/home');
          } else if (responseInfo['account_state'] == 'half') {
            //Move to additional details
            context
                .read<HomeProvider>()
                .updateUserDataErrorless(data: responseInfo['userData']);
            // //?Move to home
            Navigator.of(context).pushNamed('/NewAccountDetails');
          } else //New account
          {
            Navigator.of(context).pushNamed('/CreateAccount');
          }
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
                    'otp_check.wrongCodeEntered'.tr(),
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
                      "otp_check.incorrectCodeEntered".tr(),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                    label: 'generic_text.tryAgain'.tr(),
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
