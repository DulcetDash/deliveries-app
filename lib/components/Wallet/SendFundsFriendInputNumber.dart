import 'package:dulcetdash/components/Helpers/PhoneNumberInput/PhoneNumberInputEntry.dart';
import 'package:dulcetdash/components/Modules/GenericCircButton/GenericCircButton.dart';
import 'package:flutter/material.dart';

class SendFundsFriendInputNumber extends StatefulWidget {
  const SendFundsFriendInputNumber({Key? key}) : super(key: key);

  @override
  _SendFundsFriendInputNumberState createState() =>
      _SendFundsFriendInputNumberState();
}

class _SendFundsFriendInputNumberState
    extends State<SendFundsFriendInputNumber> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              ListTile(
                leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child:
                        Icon(Icons.arrow_back, size: 33, color: Colors.black)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Text("Who's receiving?",
                        style: TextStyle(
                            fontFamily: 'MoveBold',
                            fontSize: 28,
                            color: Colors.black))),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: PhoneNumberInputEntry(),
                      ))),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 25),
                  child: Container(
                    height: 100,
                    child: ListTile(
                      leading: Container(
                        width: MediaQuery.of(context).size.width / 2.2,
                        child: RichText(
                          text: TextSpan(
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15),
                              children: [
                                TextSpan(text: 'You can only send fares to '),
                                TextSpan(
                                    text: 'active TaxiConnect ',
                                    style: TextStyle(
                                        fontFamily: 'MoveTextMedium',
                                        color:
                                            Color.fromRGBO(14, 132, 145, 1))),
                                TextSpan(text: 'accounts.')
                              ]),
                        ),
                      ),
                      trailing: GenericCircButton(
                        actuatorFunctionl: () => print('Navigator kicked'),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
