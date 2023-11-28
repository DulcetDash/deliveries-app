import 'package:dulcetdash/components/Modules/GenericRectButton/GenericRectButton.dart';
import 'package:flutter/material.dart';

class SendFundsConfirmation extends StatelessWidget {
  const SendFundsConfirmation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.arrow_back),
          title: Text('Confirmation',
              style: TextStyle(fontFamily: 'MoveTextRegular', fontSize: 22)),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.white,
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'You are about to send taxi or delivery fares. Please make sure that the recipient is the right one.',
                      style:
                          TextStyle(fontSize: 18, fontFamily: 'MoveTextLight'),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20, left: 20),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "Receiver's information",
                    style: TextStyle(fontFamily: 'MoveBold', fontSize: 25),
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Icon(Icons.person),
                              ),
                              Text('Josh',
                                  style: TextStyle(
                                      fontFamily: 'MoveTextMedium',
                                      fontSize: 22)),
                            ],
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: Icon(Icons.phone),
                              ),
                              Text(
                                '+26481788990',
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Color.fromRGBO(14, 132, 145, 1)),
                              ),
                            ],
                          )),
                      Divider(
                        height: 40,
                        thickness: 1,
                      ),
                      Container(
                        child: Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 18, color: Colors.grey.shade600),
                            Text('Windhoek, Namibia',
                                style: TextStyle(
                                    fontSize: 17, color: Colors.grey.shade600))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        child: Text('There will be no handling fees deducted',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey.shade600)),
                      ),
                    ),
                    Container(
                      height: 100,
                      child: GenericRectButton(
                          label: 'Send N\$100',
                          actuatorFunctionl: () => print('clicked')),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
