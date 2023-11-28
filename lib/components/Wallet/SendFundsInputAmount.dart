import 'package:dulcetdash/components/Modules/GenericCircButton/GenericCircButton.dart';
import 'package:flutter/material.dart';

class SendFundsInputAmount extends StatelessWidget {
  const SendFundsInputAmount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.arrow_back),
          title: Text('Transfer fare',
              style: TextStyle(fontFamily: 'MoveTextRegular', fontSize: 22)),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.white,
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'How much?',
                    style: TextStyle(fontFamily: 'MoveBold', fontSize: 28),
                  ),
                ),
              ),
              InputAmountToSendPart(),
              Expanded(child: NoticePart()),
              ValidationButtonsPart()
            ],
          ),
        ));
  }
}

//Input amount to send part
class InputAmountToSendPart extends StatelessWidget {
  const InputAmountToSendPart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
          child: ListTile(
        horizontalTitleGap: 0,
        contentPadding: EdgeInsets.only(left: 0, right: 0, top: 20),
        leading: Container(
          alignment: Alignment.centerLeft,
          decoration:
              BoxDecoration(border: Border(bottom: BorderSide(width: 2))),
          width: 40,
          height: 50,
          child: Text('N\$',
              style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 21)),
        ),
        title: Container(
          height: 50,
          decoration:
              BoxDecoration(border: Border(bottom: BorderSide(width: 2))),
          child: TextField(
            style: TextStyle(fontSize: 25),
            decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelText: 'Amount',
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 15)),
          ),
        ),
      )),
    );
  }
}

//Notice part
class NoticePart extends StatelessWidget {
  const NoticePart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Container(
        width: MediaQuery.of(context).size.width,
        //decoration: BoxDecoration(border: Border.all(width: 1)),
        child: ListTile(
          horizontalTitleGap: -12,
          contentPadding: EdgeInsets.only(left: 0, right: 0),
          leading: Container(
              alignment: Alignment.centerLeft,
              height: 30,
              width: 30,
              child: Icon(
                Icons.info,
                size: 20,
                color: Color.fromRGBO(14, 132, 145, 1),
              )),
          title: Container(
            child: RichText(
                text: TextSpan(
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'MoveTextLight'),
                    children: [
                  TextSpan(text: 'Your maximum amount is '),
                  TextSpan(
                      text: 'N\$1000',
                      style: TextStyle(fontFamily: 'MoveTextRegular'))
                ])),
          ),
        ),
      ),
    );
  }
}

//Validation buttons part
class ValidationButtonsPart extends StatelessWidget {
  const ValidationButtonsPart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 25),
        child: Container(
          height: 100, //? Set height
          child: ListTile(
            leading: Container(
              width: MediaQuery.of(context).size.width / 2.2,
              child: RichText(
                text: TextSpan(
                    style: TextStyle(fontSize: 15, color: Colors.black),
                    children: [
                      TextSpan(text: 'Visit the '),
                      TextSpan(
                          text: 'Support tab ',
                          style: TextStyle(fontFamily: 'MoveTextBold')),
                      TextSpan(text: 'for any queries.')
                    ]),
              ),
            ),
            trailing: GenericCircButton(
              actuatorFunctionl: () => print('Navigator kicked'),
            ),
          ),
        ));
  }
}
