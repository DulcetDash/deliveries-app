import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nej/components/GenericRectButton.dart';
import 'package:nej/components/Helpers/AppTheme.dart';
import 'package:nej/components/Helpers/DataParser.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';

class NewAccountAddiDetails extends StatefulWidget {
  const NewAccountAddiDetails({Key? key}) : super(key: key);

  @override
  _NewAccountAddiDetailsState createState() => _NewAccountAddiDetailsState();
}

class _NewAccountAddiDetailsState extends State<NewAccountAddiDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              ListTile(
                leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back,
                        size: AppTheme().getArrowBackSize(),
                        color: Colors.black)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Few more things",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'MoveBold',
                                  fontSize: 24,
                                  color: Colors.black)),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '🇳🇦',
                            style: TextStyle(fontSize: 27),
                          )
                        ])),
              ),
              SizedBox(
                height: 15,
              ),
              InputUserDetails()
            ],
          ),
        ),
      ),
    );
  }
}

//Input user details: name, gender and email.
class InputUserDetails extends StatelessWidget {
  const InputUserDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                  autocorrect: false,
                  onChanged: (value) => context
                      .read<HomeProvider>()
                      .updateAdditionalAccountInfos(data: value, type: 'name'),
                  style: TextStyle(fontFamily: 'MoveTextRegular', fontSize: 20),
                  decoration: InputDecoration(
                      // prefixIcon: Icon(
                      //   Icons.person,
                      //   size: 40,
                      // ),
                      focusColor: Colors.amber,
                      labelText: "What's your name?",
                      floatingLabelBehavior: FloatingLabelBehavior.auto)),
            ),
            Visibility(
                visible: context.watch<HomeProvider>().name.isNotEmpty &&
                    context.watch<HomeProvider>().name.length < 2,
                child: ErrorValidation(
                    message: 'Should be at least 2 characters long.')),
            SizedBox(
              height: 18,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: () => showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                          color: Colors.white,
                          child: SafeArea(
                              child: Container(
                            width: MediaQuery.of(context).size.width,
                            color: Colors.white,
                            child: ModalForGenderSelection(),
                          )));
                    }),
                child: TextField(
                    autocorrect: false,
                    style: TextStyle(
                        fontFamily: 'MoveTextRegular',
                        fontSize: 20,
                        color: Colors.black),
                    decoration: InputDecoration(
                        // prefixIcon: Icon(
                        //   Icons.gesture
                        //   size: 40,
                        // ),
                        enabled: false,
                        focusColor: Colors.amber,
                        helperText: 'Choose your gender',
                        helperStyle:
                            TextStyle(color: Colors.grey, fontSize: 15),
                        labelText: DataParser()
                            .ucFirst(context.watch<HomeProvider>().gender),
                        labelStyle: TextStyle(
                            color: Colors.black, fontFamily: 'MoveTextMedium'),
                        suffixIcon: Icon(Icons.arrow_drop_down_outlined,
                            color: Colors.black),
                        floatingLabelBehavior: FloatingLabelBehavior.auto)),
              ),
            ),
            SizedBox(
              height: 18,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                  autocorrect: false,
                  onChanged: (value) => context
                      .read<HomeProvider>()
                      .updateAdditionalAccountInfos(data: value, type: 'email'),
                  style: TextStyle(fontFamily: 'MoveTextRegular', fontSize: 20),
                  decoration: InputDecoration(
                      // prefixIcon: Icon(
                      //   Icons.email_outlined,
                      //   size: 40,
                      // ),
                      focusColor: Colors.amber,
                      labelText: 'Email',
                      floatingLabelBehavior: FloatingLabelBehavior.auto)),
            ),
            Visibility(
                visible:
                    context.watch<HomeProvider>().is_additional_emailValid ==
                            false &&
                        context.watch<HomeProvider>().email.isNotEmpty,
                child: ErrorValidation(message: 'Invalid email.')),
            Expanded(
              child: Container(
                child: SizedBox(
                  height: 1,
                ),
              ),
            ),
            //BUTTON
            Opacity(
              opacity: context.watch<HomeProvider>().is_additional_emailValid &&
                      context.watch<HomeProvider>().name.isNotEmpty &&
                      context.watch<HomeProvider>().name.length >= 2
                  ? 1
                  : AppTheme().getFadedOpacityValue(),
              child: GenericRectButton(
                  label: context.watch<HomeProvider>().isLoadingForRequest
                      ? 'LOADING'
                      : 'Finish',
                  labelFontSize: 20,
                  isArrowShow: false,
                  actuatorFunctionl:
                      context.watch<HomeProvider>().isLoadingForRequest
                          ? () {}
                          : () {
                              updateBasicAccount(context: context);
                            }),
            )
          ],
        ),
      ),
    );
  }

  //...
  Future updateBasicAccount({required BuildContext context}) async {
    //? Start the loader
    context.read<HomeProvider>().updateLoadingRequestStatus(status: true);

    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/addAdditionalUserAccDetails'));

    //Assemble the bundle data
    List surnameTmp = context.read<HomeProvider>().name.split(' ');
    surnameTmp.removeAt(0);

    Map<String, String> additionalData = {
      "name": context.read<HomeProvider>().name.split(' ')[0],
      "surname": surnameTmp.join(' ').trim(),
      "gender": context.read<HomeProvider>().gender,
      "email": context.read<HomeProvider>().email,
      "profile_picture_generic":
          '${context.read<HomeProvider>().gender.toLowerCase()}.png'
    };
    //? For the request
    String user_identifierTMP =
        context.read<HomeProvider>().loginPhase1Data['userData'] != null
            ? context.read<HomeProvider>().loginPhase1Data['userData']
                ['user_identifier']
            : context.read<HomeProvider>().loginPhase1Data['response']
                ['user_identifier'];

    Map<String, String> bundleData = {
      'user_identifier': user_identifierTMP,
      "additional_data": json.encode(additionalData).toString()
    };

    print(bundleData);
    try {
      Response response = await post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        context.read<HomeProvider>().updateLoadingRequestStatus(status: false);
        log(response.body.toString());
        Map<String, dynamic> responseInfo = json.decode(response.body);

        if (responseInfo['response'] == 'success') //Success
        {
          //! Update the general user_fingerprint
          context
              .read<HomeProvider>()
              .updateGeneral_userIdenfier(data: user_identifierTMP);
          //! Persist data
          context.read<HomeProvider>().peristDataMap();
          //Move to home
          Navigator.of(context).pushNamed('/home');
        } else //An error happened
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
                    'Unable to update account',
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
                      "We were unable to update your account due to an unexpected error, please check your internet connection and try again.",
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

//Error data
class ErrorValidation extends StatelessWidget {
  final String message;
  const ErrorValidation({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
      child: Container(
        child: Row(children: [
          Icon(
            Icons.error,
            size: 15,
            color: AppTheme().getErrorColor(),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            message,
            style: TextStyle(fontSize: 15, color: AppTheme().getErrorColor()),
          )
        ]),
      ),
    );
  }
}

//Modal for choosing the gender
class ModalForGenderSelection extends StatelessWidget {
  const ModalForGenderSelection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: 17),
            child: Text(
              'Choose your gender',
              style: TextStyle(fontSize: 20, fontFamily: 'MoveTextMedium'),
            ),
          ),
          GenericGenderSelectButtons(
              leadingIcon: Icons.male,
              genderValue: 'male',
              textValue: 'Male',
              backgroundColor: Colors.black,
              textColor: Colors.white),
          GenericGenderSelectButtons(
              leadingIcon: Icons.female,
              genderValue: 'female',
              textValue: 'Female',
              backgroundColor: Colors.black,
              textColor: Colors.white),
          GenericGenderSelectButtons(
              leadingIcon: Icons.privacy_tip,
              genderValue: 'unknwon',
              textValue: 'Rather not say',
              backgroundColor: Colors.grey.shade300,
              textColor: Colors.black)
        ],
      ),
    );
  }
}

//Generic gender select button
class GenericGenderSelectButtons extends StatelessWidget {
  final String genderValue; //The gender value
  final String textValue; //The text of the button
  final Color backgroundColor; //The background color of the button
  final Color textColor; //The color of the text of the button
  final IconData leadingIcon; //The icon that will lead

  GenericGenderSelectButtons(
      {required this.genderValue,
      required this.textValue,
      required this.backgroundColor,
      required this.textColor,
      required this.leadingIcon});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Container(
          height: 65,
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(this.backgroundColor)),
            onPressed: () {
              context.read<HomeProvider>().updateAdditionalAccountInfos(
                  data: genderValue, type: 'gender');
              //Close modal
              Navigator.of(context).pop();
            },
            child: Padding(
                padding: EdgeInsets.only(bottom: 15, top: 15),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(this.leadingIcon, size: 25, color: this.textColor),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      this.textValue,
                      style: TextStyle(
                          fontFamily: 'MoveTextMedium',
                          color: this.textColor,
                          fontSize: 21),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 19,
                        color: this.textColor,
                      ),
                    ),
                  )
                ])),
          ),
        ));
  }
}
