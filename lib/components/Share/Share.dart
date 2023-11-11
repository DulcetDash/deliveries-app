import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:dulcetdash/components/GenericRectButton.dart';
import 'package:dulcetdash/components/Helpers/AppTheme.dart';
import 'package:share_plus/share_plus.dart' as share_external;

class Share extends StatefulWidget {
  const Share({Key? key}) : super(key: key);

  @override
  State<Share> createState() => _ShareState();
}

class _ShareState extends State<Share> {
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
              ),
              Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                height: 300,
                child: Image.asset(
                  'assets/Images/share.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Divider(
                color: Colors.white,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                    child: Text(
                  'share.mainTitle'.tr(),
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
                    'share.explanation'.tr(),
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
              Expanded(child: SizedBox.shrink()),
              GenericRectButton(
                  label: 'Share',
                  labelFontFamily: 'MoveBold',
                  isArrowShow: false,
                  actuatorFunctionl: () => share_external.Share.share(
                      'share.shareMessage'.tr(),
                      subject: 'share.shareSubject'.tr()))
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
                  'share.share'.tr(),
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
