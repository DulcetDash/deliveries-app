import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';

class TopLoader extends StatelessWidget {
  const TopLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 2.5,
      child: LinearProgressIndicator(
        backgroundColor: Colors.white,
        color: Colors.black,
      ),
    );
  }
}
