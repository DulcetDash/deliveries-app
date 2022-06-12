import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:nej/components/Helpers/AppTheme.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPVerificationInput extends StatefulWidget {
  const OTPVerificationInput({Key? key}) : super(key: key);

  @override
  _OTPVerificationInputState createState() => _OTPVerificationInputState();
}

class _OTPVerificationInputState extends State<OTPVerificationInput> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.white,
        child: PinCodeTextField(
          enablePinAutofill: true,
          showCursor: false,
          autoFocus: true,
          autovalidateMode: AutovalidateMode.disabled,
          autoDismissKeyboard: true,
          appContext: context,
          length: 5,
          obscureText: false,
          blinkDuration: Duration(milliseconds: 250),
          textStyle: TextStyle(
              fontSize: 25,
              fontFamily: 'MoveTextMedium',
              fontWeight: FontWeight.normal),
          animationType: AnimationType.none,
          pinTheme: PinTheme(
              shape: PinCodeFieldShape.underline,
              borderRadius: BorderRadius.circular(5),
              borderWidth: 3,
              fieldHeight: 60,
              activeColor: Colors.grey.shade700,
              inactiveColor: Colors.grey.shade400,
              selectedColor: AppTheme().getPrimaryColor(),
              fieldWidth: MediaQuery.of(context).size.width / 7,
              activeFillColor: Colors.white),
          animationDuration: Duration(milliseconds: 300),
          backgroundColor: Colors.white,
          onCompleted: (v) {
            print("Completed");
          },
          onChanged: (value) {
            print(value);
          },
          beforeTextPaste: (text) {
            print("Allowing to paste $text");
            //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
            //but you can show anything you want here, like your pop up saying wrong paste format or etc
            return false;
          },
        ),
      ),
      TimerAndErrorNotifiyer()
    ]);
  }
}

//Counter and error notifiyer class
class TimerAndErrorNotifiyer extends StatelessWidget {
  TimerAndErrorNotifiyer({Key? key}) : super(key: key);

  final int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Container(
          child: Row(
            children: [
              CountdownTimer(
                endTime: endTime,
                onEnd: () => print('TIMER DONE'),
                widgetBuilder:
                    (BuildContext context, CurrentRemainingTime? time) {
                  if (time == null) {
                    return InkWell(
                        onTap: () => print('Pressed on resend OTP'),
                        child: Text('Resend the code',
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'MoveTextMedium',
                                color: AppTheme().getPrimaryColor())));
                  }
                  // print(time);
                  //...
                  return Text(
                      'Resend the code in ${time.min == null ? '00' : time.min}:${time.sec! >= 10 ? time.sec : '0${time.sec}'}',
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'MoveTextRegular',
                      ));
                },
              )
            ],
          ),
        ));
  }
}
