import 'package:flutter/material.dart';

class SendFundsEntry extends StatelessWidget {
  const SendFundsEntry({Key? key}) : super(key: key);

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
                    'Easily send ca fares to anyone',
                    style: TextStyle(fontFamily: 'MoveBold', fontSize: 28),
                  ),
                ),
              ),
              SendingFaresOptionsPart()
            ],
          ),
        ));
  }
}

//Sending fares options part
class SendingFaresOptionsPart extends StatelessWidget {
  const SendingFaresOptionsPart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
              child: ListTile(
                leading: Container(
                    alignment: Alignment.topCenter,
                    width: 40,
                    height: 55,
                    child: Icon(Icons.face, size: 35, color: Colors.black)),
                horizontalTitleGap: 5,
                contentPadding: EdgeInsets.only(left: 0),
                title: Text(
                  'Send to friends',
                  style: TextStyle(
                      fontFamily: 'MoveTextMedium',
                      fontSize: 20,
                      color: Color.fromRGBO(14, 132, 145, 1)),
                ),
                subtitle: Text(
                    'Send rides or delivery fare to your friends and family instantly and hustle free.'),
                trailing: Container(
                    width: 40,
                    height: 55,
                    child: Icon(Icons.arrow_forward_ios,
                        size: 17, color: Colors.black)),
              ),
            ),
            Divider(
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 15, top: 15, left: 20, right: 20),
              child: ListTile(
                leading: Container(
                    alignment: Alignment.topCenter,
                    width: 40,
                    height: 55,
                    child: Icon(Icons.mobile_friendly_outlined,
                        size: 35, color: Colors.black)),
                horizontalTitleGap: 5,
                contentPadding: EdgeInsets.only(left: 0),
                title: Text(
                  'Pay a driver',
                  style: TextStyle(
                      fontFamily: 'MoveTextMedium',
                      fontSize: 20,
                      color: Color.fromRGBO(14, 132, 145, 1)),
                ),
                subtitle:
                    Text('Directly send payments to your driver seamlessly.'),
                trailing: Container(
                    width: 40,
                    height: 55,
                    child: Icon(Icons.arrow_forward_ios,
                        size: 17, color: Colors.black)),
              ),
            )
          ],
        ),
      ),
    ));
  }
}
