// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:orniss/components/Helpers/PhoneNumberInput/PhoneNumberInputModal.dart';
import 'package:orniss/components/Providers/HomeProvider.dart';
import 'package:provider/src/provider.dart';
import 'countries_codes.dart';

class PhoneNumberInputEntry extends StatefulWidget {
  const PhoneNumberInputEntry({Key? key}) : super(key: key);

  @override
  _PhoneNumberInputEntryState createState() => _PhoneNumberInputEntryState();
}

class _PhoneNumberInputEntryState extends State<PhoneNumberInputEntry> {
  TextEditingController textInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey),
                borderRadius: BorderRadius.circular(3)),
            height: 60,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
              child: Row(
                children: [
                  const FlagPartPhoneEntry(),
                  const SizedBox(
                    width: 5,
                  ),
                  TextEntryPhoneInput(
                    textInputController: textInputController,
                  )
                ],
              ),
            ),
          )),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // textInputController.dispose();
  }
}

//First part of the flag entry
class FlagPartPhoneEntry extends StatelessWidget {
  const FlagPartPhoneEntry({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => showMaterialModalBottomSheet(
            backgroundColor: Colors.white,
            duration: const Duration(milliseconds: 350),
            context: context,
            builder: (context) {
              return Container(
                  color: Colors.black,
                  child: SafeArea(
                      bottom: false,
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: const PhoneNumberInputModal(),
                      )));
            }),
        child: Container(
            decoration: BoxDecoration(
                // color: Colors.grey.shade100,
                border: Border.all(width: 0.5, color: Colors.white),
                borderRadius: BorderRadius.circular(3)),
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 5),
              child: Row(
                children: [
                  Text(
                      '${context.watch<HomeProvider>().selectedCountryCodeData['flag']}',
                      style: const TextStyle(fontSize: 33)),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                  ),
                  Text(
                      context
                          .watch<HomeProvider>()
                          .selectedCountryCodeData['dial_code'],
                      style: const TextStyle(
                          fontSize: 20, fontFamily: 'UberMoveTextMedium'))
                ],
              ),
            )));
  }
}

//Second part text entry phone input
class TextEntryPhoneInput extends StatelessWidget {
  TextEditingController textInputController;

  TextEntryPhoneInput({Key? key, required this.textInputController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 1,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Container(
                height: MediaQuery.of(context).size.height,
                // decoration: const BoxDecoration(
                //     border: Border(bottom: BorderSide(width: 1.5))),
                child: TextField(
                  controller: textInputController,
                  //autofocus: true,
                  onChanged: (value) {
                    RegExp regExpCleaner = RegExp(r"^0");
                    RegExp regExpCleaner2 = RegExp(r"^\+");

                    // String numberBody = regExpCleaner.hasMatch(value.toString())
                    //     ? value.toString().replaceFirst('0', '')
                    //     : value.toString();
                    //...
                    String numberBody =
                        regExpCleaner2.hasMatch(value.toString())
                            ? value.toString().replaceFirst('+', '')
                            : value.toString();
                    //...
                    textInputController.text = numberBody;
                    textInputController.selection = TextSelection.fromPosition(
                        TextPosition(offset: textInputController.text.length));

                    //...remove first zero
                    numberBody = regExpCleaner.hasMatch(numberBody)
                        ? numberBody.substring(1, numberBody.length)
                        : numberBody;
                    // print(regExpCleaner.hasMatch(numberBody));
                    // print(numberBody.replaceFirst('0', ''));
                    // print(numberBody);

                    context
                        .read<HomeProvider>()
                        .updateEnteredPhoneNumber(phone: numberBody);

                    //! Check if the phone is valid
                    context.read<HomeProvider>().updatePhoneNumberStatus();
                  },
                  textAlignVertical: TextAlignVertical.center,
                  autocorrect: false,
                  showCursor: true,
                  style: const TextStyle(
                    fontSize: 20,
                    letterSpacing: 0,
                  ),
                  maxLength: 10, //! Should be conditional to the country
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: false, signed: false),
                  decoration: InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      labelText: context
                              .watch<HomeProvider>()
                              .enteredPhoneNumber
                              .isEmpty
                          ? "Phone number"
                          : context.watch<HomeProvider>().enteredPhoneNumber,
                      labelStyle: TextStyle(fontFamily: 'UberMoveTextMedium'),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      contentPadding: EdgeInsets.only(bottom: 21)),
                ))));
  }
}
