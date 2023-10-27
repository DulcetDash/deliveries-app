import 'dart:convert';
import 'dart:developer';

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
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
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
              'create_account.noAccountNoProbs'.tr(),
              style: TextStyle(fontFamily: 'MoveBold', fontSize: 25),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Text(
              'create_account.accountDescription'.tr(),
              style: TextStyle(
                  fontSize: 15, color: AppTheme().getGenericDarkGrey()),
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
                  TextSpan(text: 'create_account.byClicking '.tr()),
                  TextSpan(
                      text: 'create_account.createAccountTitle'.tr(),
                      style: TextStyle(
                          fontFamily: 'MoveTextBold', color: Colors.black)),
                  TextSpan(text: ', create_account.autoAccept '.tr()),
                  TextSpan(
                      text: 'create_account.termsAndConds'.tr(),
                      style: TextStyle(
                          fontFamily: 'MoveTextMedium',
                          color: AppTheme().getPrimaryColor()))
                ]))),
          ),
          GenericRectButton(
              label: context.watch<HomeProvider>().isLoadingForRequest
                  ? 'LOADING'
                  : 'create_account.createAccountLabel'.tr(),
              labelFontSize: 22,
              isArrowShow:
                  context.watch<HomeProvider>().isLoadingForRequest == false,
              actuatorFunctionl:
                  context.watch<HomeProvider>().isLoadingForRequest
                      ? () {}
                      : () {
                          createBasicAccount(context: context);
                        })
        ],
      )),
    );
  }

  Future createBasicAccount({required BuildContext context}) async {
    //? Start the loader
    context.read<HomeProvider>().updateLoadingRequestStatus(status: true);

    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/createBasicUserAccount'));

    //Assemble the bundle data
    //? For the request
    Map<String, String> bundleData = {
      "phone":
          '${context.read<HomeProvider>().selectedCountryCodeData['dial_code']}${context.read<HomeProvider>().enteredPhoneNumber}'
    };

    // print(bundleData);
    try {
      Response response = await post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        context.read<HomeProvider>().updateLoadingRequestStatus(status: false);
        log(response.body.toString());
        Map<String, dynamic> responseInfo = json.decode(response.body);

        if (responseInfo['response'] == 'success') //?Created
        {
          //!Update long 1 data
          context
              .read<HomeProvider>()
              .updateLoginPhase1Data(data: responseInfo);
          //? Move to additional details
          Navigator.of(context).pushNamed('/NewAccountDetails');
        } else //Error
        {
          if (responseInfo['response'] ==
              'phone_already_in_use') //Already linked to another account
          {
            showErrorModalError(context: context);
          } else //Some random error
          {
            showErrorModalError_alreadyInUse(context: context);
          }
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
                    'create_account.unableToCreateAcc'.tr(),
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
                      "create_account.unableToCreateAccUnexpected".tr(),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                    label: 'create_account.generic_text'.tr(),
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
                    'create_account.phoneNoTaken'.tr(),
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
                      "create_account.phoneTakenErrorUnexpected".tr(),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                    label: 'create_account.generic_text'.tr(),
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
                onTap: context.watch<HomeProvider>().isLoadingForRequest
                    ? () {}
                    : () => Navigator.of(context).pop(),
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
                  Text('create_account.howdy'.tr(),
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
