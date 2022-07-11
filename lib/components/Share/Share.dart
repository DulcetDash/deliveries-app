import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:orniss/components/GenericRectButton.dart';
import 'package:orniss/components/Helpers/AppTheme.dart';
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
                  'Share Orniss with your friends and family.',
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
                    'Share the app to allow others to also be able to enjoy safe rides, perform seamless deliveries and shopping.',
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
                      'Hi!, there this awesome app called Orniss available in Namibia that allows you to get reliable rides, do deliveries to anywhere and do shoppings. Try it out and you will be satisfied, download it today at [LINK TO THE SPECIFIC STORE HERE].',
                      subject:
                          'Download Orniss for free! (Rides, deliveries and shoppings)'))
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
                  'Share',
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
