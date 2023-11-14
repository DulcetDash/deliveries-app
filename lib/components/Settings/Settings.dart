import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:badges/badges.dart' as badges;
import 'package:dulcetdash/components/Helpers/Networking.dart';
import 'package:dulcetdash/components/Helpers/SuperHttp.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:dulcetdash/components/GenericRectButton.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:dulcetdash/components/Helpers/SnackBarMother/SnackBarMother.dart';
import 'package:dulcetdash/components/Providers/HomeProvider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart' as share_external;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageSelected;

  bool isLoading = false; //If a process is loading or not

  //Request for information update only for profile picture
  Future RequestForInformationUpdateProfile(
      {required BuildContext context}) async {
    setState(() {
      isLoading = true;
    });
    //....
    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/updateUsersInformation'));

    String profilePhotoExtension = _imageSelected!.path
        .split('.')[_imageSelected!.path.split('.').length - 1];
    List<int> profilePhotoBytes =
        await XFile(_imageSelected!.path).readAsBytes();
    String profilePhotoBase64 = base64Encode(profilePhotoBytes);

    //Assemble the bundle data
    //* @param type: the type of request (past, scheduled, business)
    Map<String, String> bundleData = {
      'user_identifier':
          context.read<HomeProvider>().userData['user_identifier'],
      'data_type': 'profile_picture',
      'data_value': profilePhotoBase64,
      'extension': profilePhotoExtension
    };

    try {
      SuperHttp superHttp = SuperHttp();
      var response = await superHttp.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        String tmpResponse = json.decode(response.body)['response'];

        if (tmpResponse == 'success') {
          dismissModalSuccess(context: context);
          GetUserData().exec(context: context);
        } else //Some error
        {
          dismissModalError(context: context);
        }
      } else //Has some errors
      {
        dismissModalError(context: context);
        log(response.toString());
      }
    } catch (e) {
      log('8');
      log(e.toString());
      dismissModalError(context: context);
    }
  }

  //Dismiss modal - error
  void dismissModalError({required BuildContext context}) {
    SnackBarMother _snackBarMother = SnackBarMother(
        context: context,
        snackChild: Text('settings.unableToChangeProfile'.tr()),
        snackPaddingBottom: 0,
        snackBackgroundcolor: AppTheme().getErrorColor());
    _snackBarMother.showSnackBarMotherChild();
    //...
    setState(() {
      isLoading = false;
    });
  }

  //Success
  void dismissModalSuccess({required BuildContext context}) {
    SnackBarMother _snackBarMother = SnackBarMother(
        context: context,
        snackChild: Text('settings.successfullyChangedProfile'.tr()),
        snackPaddingBottom: 0,
        snackBackgroundcolor: AppTheme().getSecondaryColor());
    _snackBarMother.showSnackBarMotherChild();
    //...
    setState(() {
      isLoading = false;
    });
  }

  //Camera
  void openCameraHandler(
      {required BuildContext context, required bool shouldOpenCam}) async {
    final XFile? image = await _picker.pickImage(
        source: shouldOpenCam ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 700,
        maxHeight: 700,
        imageQuality: 70,
        preferredCameraDevice: CameraDevice.front);
    // final XFile? image = await _picker.pickImage(
    //     maxWidth: 700,
    //     maxHeight: 700,
    //     imageQuality: 70,
    //     source: ImageSource.gallery);
    // print(image);
    setState(() {
      _imageSelected = image;
    });
    //...Update
    if (image != null) RequestForInformationUpdateProfile(context: context);
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> userData = context.watch<HomeProvider>().userData;

    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: userData['user_identifier'] == null
            ? Text('settings.restartApp'.tr())
            : SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Header(),
                    Expanded(
                      child: ListView(
                          padding: EdgeInsets.only(bottom: 50),
                          children: [
                            Divider(
                              color: Colors.white,
                              height: 25,
                            ),
                            ListTile(
                              horizontalTitleGap: 20,
                              leading: InkWell(
                                onTap: () => openCameraHandler(
                                    context: context, shouldOpenCam: false),
                                child: badges.Badge(
                                  badgeContent: Icon(
                                    Icons.edit,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                  badgeStyle: badges.BadgeStyle(
                                    badgeColor: Colors.black,
                                  ),
                                  position: badges.BadgePosition.bottomEnd(),
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.4),
                                            blurRadius: 7,
                                            spreadRadius: 0)
                                      ],
                                    ),
                                    child: CircleAvatar(
                                        radius: 35,
                                        backgroundColor: Colors.black,
                                        backgroundImage: NetworkImage(
                                          userData['profile_picture'],
                                        ),
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(1000)),
                                        )),
                                  ),
                                ),
                              ),
                              title: Text(
                                userData['name'].toString(),
                                style: TextStyle(
                                    fontFamily: 'MoveTextMedium', fontSize: 19),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  userData['phone'].toString(),
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              trailing: isLoading
                                  ? SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1,
                                        color: AppTheme().getSecondaryColor(),
                                      ))
                                  : null,
                            ),
                            Divider(
                              height: 30,
                            ),
                            GenericTitle(
                                title: 'settings.personalInformation'.tr()),
                            GenericInformationDisplayer(
                              fieldName: 'settings.name'.tr(),
                              valueText: userData['name'].toString(),
                              actuator: () => showMaterialModalBottomSheet(
                                backgroundColor: Colors.white,
                                expand: false,
                                bounce: true,
                                duration: Duration(milliseconds: 250),
                                context: context,
                                builder: (context) => LocalModal(
                                  scenario: 'name',
                                  valueField: userData['name'].toString(),
                                  parentContext: context,
                                ),
                              ),
                            ),
                            GenericInformationDisplayer(
                              fieldName: 'settings.surname'.tr(),
                              valueText: userData['surname'].toString(),
                              actuator: () => showMaterialModalBottomSheet(
                                backgroundColor: Colors.white,
                                expand: false,
                                bounce: true,
                                duration: Duration(milliseconds: 250),
                                context: context,
                                builder: (context) => LocalModal(
                                  scenario: 'surname',
                                  valueField: userData['surname'].toString(),
                                  parentContext: context,
                                ),
                              ),
                            ),
                            Divider(
                              height: 30,
                            ),
                            GenericTitle(title: 'settings.contact'.tr()),
                            GenericInformationDisplayer(
                                fieldName: 'settings.phone'.tr(),
                                valueText: userData['phone'].toString(),
                                actuator: () {
                                  //! Clear the tmp phone number entered
                                  context
                                      .read<HomeProvider>()
                                      .updateEnteredPhoneNumber(phone: '');
                                  //...
                                  Navigator.of(context)
                                      .pushNamed('/PhoneInputChange');
                                }),
                            GenericInformationDisplayer(
                              fieldName: 'settings.email'.tr(),
                              valueText: userData['email'].toString(),
                              actuator: () => showMaterialModalBottomSheet(
                                backgroundColor: Colors.white,
                                expand: false,
                                bounce: true,
                                duration: Duration(milliseconds: 250),
                                context: context,
                                builder: (context) => LocalModal(
                                  scenario: 'email',
                                  valueField: userData['email'].toString(),
                                  parentContext: context,
                                ),
                              ),
                            ),
                            Divider(
                              height: 30,
                            ),
                            GenericTitle(title: 'settings.privacy'.tr()),
                            InkWell(
                              onTap: () async {
                                if (!await launchUrl(Uri.parse(
                                    'https://dulcetdash.com/privacy'))) {
                                  throw 'Could not launch the URL';
                                }
                              },
                              child: const GenericInformationDisplayer_terms_co(
                                  valueText: 'Terms & conditions'),
                            ),
                            InkWell(
                              onTap: () async {
                                if (!await launchUrl(Uri.parse(
                                    'https://dulcetdash.com/privacy'))) {
                                  throw 'Could not launch the URL';
                                }
                              },
                              child: const GenericInformationDisplayer_terms_co(
                                  valueText: 'Privacy statement'),
                            ),
                            const Divider(
                              height: 30,
                            ),
                            GenericInformationLogOUT(
                                valueText: 'settings.logout'.tr())
                          ]),
                    ),
                  ],
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
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Container(
        // color: Colors.red,
        child: Row(
          children: [
            InkWell(
              // onTap: () => Navigator.of(context).pushNamed('/home'),
              onTap: () => Navigator.of(context).popAndPushNamed('/home'),
              child: Container(
                alignment: Alignment.centerLeft,
                width: 100,
                child: Icon(
                  Icons.arrow_back,
                  size: AppTheme().getArrowBackSize(),
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: Text(
                  'settings.settings'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'MoveBold',
                      fontSize: AppTheme().getHeaderPagesTitleSize()),
                ),
              ),
            ),
            Container(width: 100, child: Text(''))
          ],
        ),
      ),
    );
  }
}

//Generic title
class GenericTitle extends StatelessWidget {
  final String title;
  const GenericTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 5),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
                fontFamily: 'MoveTextMedium',
                fontSize: 14,
                color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

//Generic information displayer
class GenericInformationDisplayer extends StatelessWidget {
  final String fieldName;
  final String valueText;
  final actuator;
  const GenericInformationDisplayer(
      {Key? key,
      required this.fieldName,
      required this.valueText,
      required this.actuator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        onTap: actuator,
        contentPadding: EdgeInsets.only(left: 20, right: 20),
        horizontalTitleGap: -15,
        leading: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Icon(Icons.circle, size: 6),
        ),
        title: Text(
          fieldName,
          style: TextStyle(fontFamily: 'MoveTextLight', fontSize: 14),
        ),
        subtitle: Text(
          valueText,
          style: TextStyle(
              fontFamily: 'MoveTextMedium', fontSize: 16, color: Colors.black),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 15,
          color: AppTheme().getPrimaryColor(),
        ),
      ),
    );
  }
}

//Generic information displayers - terms & co
class GenericInformationDisplayer_terms_co extends StatelessWidget {
  final String valueText;
  const GenericInformationDisplayer_terms_co(
      {Key? key, required this.valueText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 20, right: 20),
        horizontalTitleGap: -15,
        leading: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Icon(Icons.circle, size: 6),
        ),
        title: Text(
          valueText,
          style: TextStyle(
              fontFamily: 'MoveTextRegular', fontSize: 16, color: Colors.black),
        ),
        // trailing: Icon(
        //   Icons.arrow_forward_ios,
        //   size: 15,
        // ),
      ),
    );
  }
}

//LOG OUT
class GenericInformationLogOUT extends StatelessWidget {
  final String valueText;
  const GenericInformationLogOUT({Key? key, required this.valueText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        onTap: () {
          context.read<HomeProvider>().clearEverything();
          //..
          Navigator.of(context).pushNamed('/Entry');
        },
        contentPadding: EdgeInsets.only(left: 20, right: 20),
        horizontalTitleGap: -15,
        leading: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Icon(
            Icons.circle,
            size: 6,
            color: Colors.white,
          ),
        ),
        title: Text(
          valueText,
          style: TextStyle(
              fontFamily: 'MoveTextMedium',
              fontSize: 16,
              color: AppTheme().getErrorColor()),
        ),
      ),
    );
  }
}

//Generic title modal
class GenericTitle_modal extends StatelessWidget {
  final String title;
  const GenericTitle_modal({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 5),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
                fontFamily: 'MoveBold', fontSize: 23, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

//Local modal
class LocalModal extends StatefulWidget {
  final String scenario;
  final String valueField;
  final parentContext;

  const LocalModal(
      {Key? key,
      required this.scenario,
      required this.valueField,
      required this.parentContext})
      : super(key: key);

  @override
  State<LocalModal> createState() => _LocalModalState(
      scenario: scenario, valueField: valueField, parentContext: parentContext);
}

class _LocalModalState extends State<LocalModal> {
  final String scenario;
  final String valueField;
  final parentContext;

  _LocalModalState(
      {Key? key,
      required this.scenario,
      required this.valueField,
      required this.parentContext});

  TextEditingController _editingController = TextEditingController();
  bool isLoading = false; //If a process is loading or not

  //Request for information update only for textual fields
  Future RequestForInformationUpdateTextual(
      {required BuildContext context}) async {
    setState(() {
      isLoading = true;
    });
    //....
    Uri mainUrl = Uri.parse(Uri.encodeFull(
        '${context.read<HomeProvider>().bridge}/updateUsersInformation'));

    //Assemble the bundle data
    //* @param type: the type of request (past, scheduled, business)
    Map<String, String> bundleData = {
      'user_identifier':
          context.read<HomeProvider>().userData['user_identifier'],
      'data_type': scenario,
      'data_value': _editingController.text.toString()
    };

    try {
      SuperHttp superHttp = SuperHttp();
      var response = await superHttp.post(mainUrl, body: bundleData);

      if (response.statusCode == 200) //Got some results
      {
        dismissModalSuccess(context: context);
        GetUserData().exec(context: parentContext);
        //? Update
      } else //Has some errors
      {
        dismissModalError(context: context);
      }
    } catch (e) {
      log('8');
      log(e.toString());
      dismissModalError(context: context);
    }
  }

  //Dismiss modal - error
  void dismissModalError({required BuildContext context}) {
    Navigator.of(context).pop();
    SnackBarMother _snackBarMother = SnackBarMother(
        context: context,
        snackChild: Text('settings.unableToChangeData'.tr(args: ['$scenario'])),
        snackPaddingBottom: 0,
        snackBackgroundcolor: AppTheme().getErrorColor());
    _snackBarMother.showSnackBarMotherChild();
    //...
    setState(() {
      isLoading = false;
    });
    // Navigator.of(context).pop();
  }

  //Success
  void dismissModalSuccess({required BuildContext context}) {
    Navigator.of(context).pop();
    SnackBarMother _snackBarMother = SnackBarMother(
        context: context,
        snackChild: Text('settings.successChangedData'.tr(args: ['$scenario'])),
        snackPaddingBottom: 0,
        snackBackgroundcolor: AppTheme().getSecondaryColor());
    _snackBarMother.showSnackBarMotherChild();
    //...
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (scenario) {
      case 'name':
        return SafeArea(
            top: false,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 20, top: 20),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 80,
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.arrow_back,
                                size: AppTheme().getArrowBackSize()),
                          ),
                        )
                      ],
                    ),
                  ),
                  GenericTitle_modal(title: 'settings.changeName'.tr()),
                  GenericTextField(
                      controller: _editingController,
                      placeholderText: 'settings.enterName'.tr()),
                  ListTile(
                    horizontalTitleGap: 0,
                    contentPadding:
                        EdgeInsets.only(top: 30, left: 20, right: 20),
                    leading: Icon(
                      Icons.info,
                      size: 20,
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'settings.namePrivacyExplanation'.tr(),
                        style: TextStyle(
                            fontSize: 14,
                            color: AppTheme().getGenericDarkGrey()),
                      ),
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                      label: isLoading ? 'LOADING' : 'rides.done'.tr(),
                      labelFontSize: 20,
                      isArrowShow: false,
                      actuatorFunctionl: () {
                        RequestForInformationUpdateTextual(context: context);
                      })
                ],
              ),
            ));

      case 'surname':
        return SafeArea(
            top: false,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 20, top: 20),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 80,
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.arrow_back,
                                size: AppTheme().getArrowBackSize()),
                          ),
                        )
                      ],
                    ),
                  ),
                  GenericTitle_modal(title: 'settings.changeSurname'.tr()),
                  GenericTextField(
                      controller: _editingController,
                      placeholderText: 'settings.enterSurname'.tr()),
                  ListTile(
                    horizontalTitleGap: 0,
                    contentPadding:
                        EdgeInsets.only(top: 30, left: 20, right: 20),
                    leading: Icon(
                      Icons.info,
                      size: 20,
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'settings.surnamePrivacyExplanation'.tr(),
                        style: TextStyle(
                            fontSize: 14,
                            color: AppTheme().getGenericDarkGrey()),
                      ),
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                      label: isLoading ? 'LOADING' : 'rides.done'.tr(),
                      labelFontSize: 20,
                      isArrowShow: false,
                      actuatorFunctionl: () {
                        RequestForInformationUpdateTextual(context: context);
                      })
                ],
              ),
            ));

      case 'email':
        return SafeArea(
            top: false,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 20, top: 20),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 80,
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.arrow_back,
                                size: AppTheme().getArrowBackSize()),
                          ),
                        )
                      ],
                    ),
                  ),
                  GenericTitle_modal(title: 'settings.changeEmail'.tr()),
                  GenericTextField(
                      controller: _editingController,
                      placeholderText: 'settings.enterEmail'.tr()),
                  ListTile(
                    horizontalTitleGap: 0,
                    contentPadding:
                        EdgeInsets.only(top: 30, left: 20, right: 20),
                    leading: Icon(
                      Icons.info,
                      size: 20,
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'settings.emailPrivacyExplanation'.tr(),
                        style: TextStyle(
                            fontSize: 14,
                            color: AppTheme().getGenericDarkGrey()),
                      ),
                    ),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  GenericRectButton(
                      label: isLoading ? 'LOADING' : 'rides.done'.tr(),
                      labelFontSize: 20,
                      isArrowShow: false,
                      actuatorFunctionl: () {
                        RequestForInformationUpdateTextual(context: context);
                      })
                ],
              ),
            ));
      default:
        return SizedBox.shrink();
    }
  }
}

//Generic text field
class GenericTextField extends StatefulWidget {
  final String placeholderText;
  final TextEditingController controller;
  const GenericTextField(
      {Key? key, required this.controller, required this.placeholderText})
      : super(key: key);

  @override
  State<GenericTextField> createState() => _GenericTextFieldState(
      controller: controller, placeholderText: placeholderText);
}

class _GenericTextFieldState extends State<GenericTextField> {
  final String placeholderText;
  final TextEditingController controller;

  _GenericTextFieldState(
      {Key? key, required this.controller, required this.placeholderText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: SizedBox(
        height: 50,
        child: TextField(
            controller: controller,
            autocorrect: false,
            onChanged: (value) {
              //! Place the cursor at the end
              controller.text = value;
              controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length));

              // print(value);
            },
            style: TextStyle(
                fontFamily: 'MoveTextRegular',
                fontSize: 18,
                color: Colors.black),
            decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    controller.clear();
                  },
                  icon: Icon(Icons.clear),
                ),
                contentPadding: EdgeInsets.only(top: 0, left: 10, right: 10),
                filled: true,
                fillColor: Colors.grey.shade300,
                floatingLabelStyle: const TextStyle(color: Colors.black),
                label: Text(placeholderText),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(1)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(1)))),
      ),
    );
  }
}
