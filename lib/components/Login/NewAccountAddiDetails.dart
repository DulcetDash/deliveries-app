import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:nej/components/Helpers/AppTheme.dart';

class NewAccountAddiDetails extends StatefulWidget {
  const NewAccountAddiDetails({Key? key}) : super(key: key);

  @override
  _NewAccountAddiDetailsState createState() => _NewAccountAddiDetailsState();
}

class _NewAccountAddiDetailsState extends State<NewAccountAddiDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              ListTile(
                leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back,
                        size: AppTheme().getArrowBackSize(),
                        color: Colors.black)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Few more things",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'MoveBold',
                                  fontSize: 24,
                                  color: Colors.black)),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            '🇳🇦',
                            style: TextStyle(fontSize: 27),
                          )
                        ])),
              ),
              SizedBox(
                height: 15,
              ),
              InputUserDetails()
            ],
          ),
        ),
      ),
    );
  }
}

//Input user details: name, gender and email.
class InputUserDetails extends StatelessWidget {
  const InputUserDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                  autocorrect: false,
                  style: TextStyle(fontFamily: 'MoveTextRegular', fontSize: 20),
                  decoration: InputDecoration(
                      // prefixIcon: Icon(
                      //   Icons.person,
                      //   size: 40,
                      // ),
                      focusColor: Colors.amber,
                      labelText: "What's your name?",
                      floatingLabelBehavior: FloatingLabelBehavior.auto)),
            ),
            SizedBox(
              height: 18,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: InkWell(
                onTap: () => showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                          color: Colors.white,
                          child: SafeArea(
                              child: Container(
                            width: MediaQuery.of(context).size.width,
                            color: Colors.white,
                            child: ModalForGenderSelection(),
                          )));
                    }),
                child: TextField(
                    autocorrect: false,
                    style: TextStyle(
                        fontFamily: 'MoveTextRegular',
                        fontSize: 20,
                        color: Colors.black),
                    decoration: InputDecoration(
                        // prefixIcon: Icon(
                        //   Icons.gesture
                        //   size: 40,
                        // ),
                        enabled: false,
                        focusColor: Colors.amber,
                        helperText: 'Choose your gender',
                        helperStyle:
                            TextStyle(color: Colors.grey, fontSize: 15),
                        labelText: 'Male',
                        labelStyle: TextStyle(
                            color: Colors.black, fontFamily: 'MoveTextMedium'),
                        suffixIcon: Icon(Icons.arrow_drop_down_outlined,
                            color: Colors.black),
                        floatingLabelBehavior: FloatingLabelBehavior.auto)),
              ),
            ),
            SizedBox(
              height: 18,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                  autocorrect: false,
                  style: TextStyle(fontFamily: 'MoveTextRegular', fontSize: 20),
                  decoration: InputDecoration(
                      // prefixIcon: Icon(
                      //   Icons.email_outlined,
                      //   size: 40,
                      // ),
                      focusColor: Colors.amber,
                      labelText: 'Email',
                      floatingLabelBehavior: FloatingLabelBehavior.auto)),
            ),
            Expanded(
              child: Container(
                child: SizedBox(
                  height: 1,
                ),
              ),
            ),
            ButtonUpdateMinimalAccount()
          ],
        ),
      ),
    );
  }
}

//Button update minimal account
class ButtonUpdateMinimalAccount extends StatelessWidget {
  const ButtonUpdateMinimalAccount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.black)),
            onPressed: () => print('pressed'),
            child: Padding(
                padding: EdgeInsets.only(bottom: 15, top: 15),
                child: Text(
                  'Finish',
                  style: TextStyle(fontFamily: 'MoveTextMedium', fontSize: 20),
                )),
          ),
        ));
  }
}

//Modal for choosing the gender
class ModalForGenderSelection extends StatelessWidget {
  const ModalForGenderSelection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: 17),
            child: Text(
              'Choose your gender',
              style: TextStyle(fontSize: 20, fontFamily: 'MoveTextMedium'),
            ),
          ),
          GenericGenderSelectButtons(
              leadingIcon: Icons.male,
              genderValue: 'male',
              textValue: 'Male',
              backgroundColor: Colors.black,
              textColor: Colors.white),
          GenericGenderSelectButtons(
              leadingIcon: Icons.female,
              genderValue: 'female',
              textValue: 'Female',
              backgroundColor: Colors.black,
              textColor: Colors.white),
          GenericGenderSelectButtons(
              leadingIcon: Icons.privacy_tip,
              genderValue: 'unknwon',
              textValue: 'Rather not say',
              backgroundColor: Colors.grey.shade300,
              textColor: Colors.black)
        ],
      ),
    );
  }
}

//Generic gender select button
class GenericGenderSelectButtons extends StatelessWidget {
  final String genderValue; //The gender value
  final String textValue; //The text of the button
  final Color backgroundColor; //The background color of the button
  final Color textColor; //The color of the text of the button
  final IconData leadingIcon; //The icon that will lead

  GenericGenderSelectButtons(
      {required this.genderValue,
      required this.textValue,
      required this.backgroundColor,
      required this.textColor,
      required this.leadingIcon});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Container(
          height: 65,
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(this.backgroundColor)),
            onPressed: () => print(this.genderValue),
            child: Padding(
                padding: EdgeInsets.only(bottom: 15, top: 15),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(this.leadingIcon, size: 25, color: this.textColor),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      this.textValue,
                      style: TextStyle(
                          fontFamily: 'MoveTextMedium',
                          color: this.textColor,
                          fontSize: 21),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 19,
                        color: this.textColor,
                      ),
                    ),
                  )
                ])),
          ),
        ));
  }
}
