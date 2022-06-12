import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:nej/components/GenericRectButton.dart';

class Entry extends StatefulWidget {
  const Entry({Key? key}) : super(key: key);

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  @override
  void initState() {
    // Adjust the provider based on the image type

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: InkWell(
        onTap: () => Navigator.of(context).pushNamed('/PhoneInput'),
        child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: SafeArea(
                child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 105,
                    height: 105,
                    child: Image.asset(
                      'assets/Images/nej.jpeg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                //Theme image
                Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.30,
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    'assets/Images/cityscape.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  'Move Confidently',
                  style: TextStyle(fontFamily: 'MoveTextBold', fontSize: 26),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Rides',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      width: 15,
                      child: Icon(Icons.circle, size: 5),
                    ),
                    Text(
                      'Deliveries',
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      width: 15,
                      child: Icon(Icons.circle, size: 5),
                    ),
                    Text(
                      'Shopping',
                      style: TextStyle(fontSize: 15),
                    )
                  ],
                ),
                Expanded(child: SizedBox.shrink()),
                GenericRectButton(
                    label: 'Get started',
                    labelFontSize: 19,
                    actuatorFunctionl: () {})
              ],
            ))),
      ),
    );
  }
}
