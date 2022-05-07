import 'package:flutter/material.dart';
import 'package:nej/components/GenericRectButton.dart';
import 'package:nej/components/Helpers/AppTheme.dart';

class SuccessRequest extends StatelessWidget {
  const SuccessRequest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
          child: Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
        child: Column(
          children: [
            Icon(Icons.check_circle,
                size: 50, color: AppTheme().getPrimaryColor()),
            SizedBox(
              height: 15,
            ),
            Text(
              'Successfully requested',
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
                "Your shopping request has been successfully made, please click on the button below to track it.",
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(child: SizedBox.shrink()),
            GenericRectButton(
              label: 'Track your shopping',
              labelFontSize: 20,
              actuatorFunctionl: () {
                Navigator.of(context).pushNamed('/');
              },
            )
          ],
        ),
      )),
    ));
  }
}
