import 'package:dulcetdash/components/Modules/GenericRectButton/GenericRectButton.dart';
import 'package:flutter/material.dart';

class TransactionFinalReport extends StatefulWidget {
  const TransactionFinalReport({Key? key}) : super(key: key);

  @override
  _TransactionFinalReportState createState() => _TransactionFinalReportState();
}

class _TransactionFinalReportState extends State<TransactionFinalReport> {
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
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    child: Text("Transfer successful!",
                        style: TextStyle(
                            fontFamily: 'MoveBold',
                            fontSize: 28,
                            color: Colors.black))),
              ),
              SizedBox(
                height: 10,
              ),
              AvatarAndServerDetails(),
              GenericRectButton(
                  label: 'Done',
                  isArrowShow: false,
                  actuatorFunctionl: () => print('clicked'))
            ],
          ),
        ),
      ),
    );
  }
}

//Avatar and server answer
class AvatarAndServerDetails extends StatelessWidget {
  const AvatarAndServerDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 3, color: Color.fromRGBO(14, 132, 145, 1)),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 10)
                    ]),
                child: CircleAvatar(
                  backgroundImage: AssetImage('Assets/Images/girl.jpg'),
                  radius: 45,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 25),
                child: Container(
                  child: Text('Jessica',
                      style: TextStyle(
                          fontFamily: 'MoveTextMedium', fontSize: 22)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25),
                child: Column(
                  children: [
                    Icon(Icons.check,
                        size: 35, color: Color.fromRGBO(14, 132, 145, 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Container(
                        child: Text(
                          'Sent N\$100',
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'MoveBold'),
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        'Your transaction was successful.',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromRGBO(14, 132, 145, 1)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
