import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:orniss/components/GenericRectButton.dart';
import 'package:orniss/components/Helpers/AppTheme.dart';

class Language extends StatefulWidget {
  const Language({Key? key}) : super(key: key);

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  List<Map<String, String>> languages = [
    {'lang': 'English', 'code': 'en'},
    {'lang': 'Français', 'code': 'fr'}
  ];
  String selectedLang = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: MediaQuery.of(context).size.height * 0.05),
          child: Column(
            children: [
              Text('Hello!',
                  style: TextStyle(
                      fontFamily: 'MoveBold',
                      fontSize: 35,
                      color: AppTheme().getPrimaryColor())),
              Divider(
                color: Colors.transparent,
              ),
              Text('Select your language',
                  style: const TextStyle(
                      fontFamily: 'MoveBold',
                      fontSize: 30,
                      color: Colors.black)),
              Divider(
                height: 55,
                color: Colors.transparent,
              ),
              ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => ListTile(
                        onTap: () => setState(() {
                          selectedLang = languages[index]['lang']!;
                          //! Update the general local
                          context.setLocale(Locale(languages[index]['code']!));
                        }),
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${languages[index]['lang']}',
                          style: TextStyle(
                              fontFamily: 'MoveTextMedium',
                              fontSize: 17,
                              color: selectedLang == languages[index]['lang']
                                  ? AppTheme().getPrimaryColor()
                                  : Colors.black),
                        ),
                        trailing: selectedLang == languages[index]['lang']
                            ? Icon(
                                Icons.check_circle,
                                size: 25,
                                color: AppTheme().getPrimaryColor(),
                              )
                            : Icon(
                                Icons.arrow_forward_ios,
                                size: 15,
                              ),
                      ),
                  separatorBuilder: (context, index) => Divider(
                        color: Colors.grey,
                        height: 15,
                      ),
                  itemCount: languages.length),
              Expanded(child: SizedBox.shrink()),
              GenericRectButton(
                  horizontalPadding: 0,
                  label: 'Continue',
                  labelFontSize: 20,
                  isArrowShow: false,
                  actuatorFunctionl: () => print('Next'))
            ],
          ),
        ),
      ),
    ));
  }
}
