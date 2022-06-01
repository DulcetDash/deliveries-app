// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:provider/src/provider.dart';
import 'dart:math' as math;
import 'countries_codes.dart';

class PhoneNumberInputModal extends StatefulWidget {
  const PhoneNumberInputModal({Key? key}) : super(key: key);

  @override
  _PhoneNumberInputModalState createState() => _PhoneNumberInputModalState();
}

class _PhoneNumberInputModalState extends State<PhoneNumberInputModal> {
  List countryCodes = CountriesCodesModel().countriesCodes;
  bool showSearchBar = false;
  TextEditingController textSearchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: InkWell(
            onTap: () {
              if (showSearchBar) {
                setState(() {
                  showSearchBar = false;
                  countryCodes = CountriesCodesModel().countriesCodes;
                  //Clear the text controller
                  textSearchController.clear();
                });
              } else //Close modal
              {
                Navigator.pop(context);
              }
            },
            child: const Icon(Icons.arrow_back, size: 28)),
        title: Container(
          child: showSearchBar == false
              ? const Text('Country or region',
                  style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 21))
              : TextField(
                  autofocus: true,
                  controller: textSearchController,
                  onChanged: (valueSearch) => setState(() {
                    if (valueSearch.isNotEmpty && showSearchBar) {
                      List originalList = CountriesCodesModel().countriesCodes;

                      countryCodes = originalList
                          .where((u) => (u['name']
                              .toLowerCase()
                              .contains(valueSearch.toLowerCase())))
                          .toList();
                    } else //Original list
                    {
                      countryCodes = CountriesCodesModel().countriesCodes;
                    }
                  }),
                  style: const TextStyle(color: Colors.white, fontSize: 19),
                  decoration: const InputDecoration(
                      hintText: 'Search your country',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 19),
                      border: InputBorder.none),
                ),
        ),
        centerTitle: false,
        actions: [
          Visibility(
            visible: showSearchBar == false,
            child: InkWell(
              onTap: () => setState(() {
                showSearchBar = true;
              }),
              child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: const Icon(Icons.search, size: 28))),
            ),
          )
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: ListView.separated(
            itemCount: countryCodes.length,
            separatorBuilder: (context, index) => const SizedBox(
              height: 10,
            ),
            itemBuilder: (context, index) {
              return InkWell(
                  onTap: () {
                    context.read<HomeProvider>().updateSelectedCountryCode(
                        dialData: countryCodes[index]);
                    //Clear the text controller
                    textSearchController.clear();
                    //Close the modal
                    Navigator.of(context).pop();
                  },
                  child: ListTile(
                    leading: Text('${countryCodes[index]['flag']}',
                        style: const TextStyle(fontSize: 33)),
                    title: Text(
                      '${countryCodes[index]['name']} (${countryCodes[index]['dial_code']})',
                      style: const TextStyle(fontSize: 19),
                    ),
                  ));
            },
          )),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    textSearchController.dispose();
  }
}
