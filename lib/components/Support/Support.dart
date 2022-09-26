import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:orniss/components/GenericRectButton.dart';
import 'package:orniss/components/Helpers/AppTheme.dart';
import 'package:share_plus/share_plus.dart' as share_external;

class Support extends StatefulWidget {
  const Support({Key? key}) : super(key: key);

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Column(
        children: [
          Header(),
          Expanded(
            child: Column(children: [
              Divider(
                color: Colors.white,
                height: 25,
              ),
              Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                height: 80,
                child: Image.asset(
                  'assets/Images/24h.png',
                  fit: BoxFit.contain,
                ),
              ),
              Divider(
                color: Colors.white,
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                    child: Text(
                  'support.mainTitle'.tr(),
                  style: TextStyle(fontFamily: 'MoveBold', fontSize: 23),
                )),
              ),
              Divider(
                color: Colors.white,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  child: Text(
                    'support.explanation'.tr(),
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
              Expanded(child: SizedBox.shrink()),
              GenericRectButton(
                  label: 'support.callUs'.tr(),
                  labelFontFamily: 'MoveTextBold',
                  isArrowShow: false,
                  verticalPadding: 10,
                  labelFontSize: 20,
                  activateTrailing: true,
                  backgroundColor: AppTheme().getPrimaryColor(),
                  trailingIcon: Icons.whatsapp,
                  actuatorFunctionl: () => {}),
              GenericRectButton(
                  label: 'support.callThePolice'.tr(),
                  labelFontFamily: 'MoveTextBold',
                  isArrowShow: false,
                  labelFontSize: 20,
                  actuatorFunctionl: () => {})
            ]),
          ),
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
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Container(
        // color: Colors.red,
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).pushNamed('/home'),
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
                  'generic_text.support'.tr(),
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
