import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nej/components/Providers/HomeProvider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/src/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final double sideLength = 150; //The side of the squre for the logo
  double superSideLength =
      100; //The side of the container above the logo for the scale out

  late final Animation<double> logoScaleAnimation;
  late final Animation<double> superScaleAnimation;
  late final Animation globalOpacityAnimation;

  final Interval forwardInterval =
      const Interval(0.0, 1.0, curve: Curves.easeInOutExpo);
  final Interval superInterval =
      const Interval(0.4, 1.0, curve: Curves.easeInOutCubic);
  final Interval opacityInterval = const Interval(0.6, 1.0, curve: Curves.ease);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);

    // logoScaleAnimation = Tween(begin: 1.0, end: 0.0)
    //     .animate(CurvedAnimation(parent: _controller, curve: forwardInterval));
    logoScaleAnimation = Tween(begin: 1.0, end: 50.0)
        .animate(CurvedAnimation(parent: _controller, curve: forwardInterval));

    superScaleAnimation = Tween(begin: 1.0, end: 50.0)
        .animate(CurvedAnimation(parent: _controller, curve: superInterval));

    globalOpacityAnimation = Tween(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: opacityInterval));

    globalOpacityAnimation.addListener(() {
      setState(() {
        //Do some stuff
      });
    });

    //Debug start
    Future.delayed(Duration(seconds: 1), () {
      _controller.forward().whenComplete(() {
        //Restore the home flow
        //Restore the registration flow
        context.read<HomeProvider>().restoreStateData(context: context);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Opacity(
          opacity: globalOpacityAnimation.value,
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.black, border: Border.all(width: 1)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ScaleTransition(
                      scale: superScaleAnimation,
                      child: Container(
                        alignment: Alignment.center,
                        width: superSideLength,
                        height: superSideLength,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                      ),
                    ),
                    ScaleTransition(
                      scale: logoScaleAnimation,
                      child: Container(
                          alignment: Alignment.center,
                          width: sideLength,
                          height: sideLength,
                          decoration: const BoxDecoration(color: Colors.black),
                          child: Image.asset(
                            'assets/Images/nejb.jpeg',
                            fit: BoxFit.contain,
                          )),
                    )
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
