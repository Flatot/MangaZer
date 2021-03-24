import 'dart:async';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:mangazer/main.dart';

class CustomSplashScreen extends StatefulWidget {
  CustomSplashScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CustomSplashScreenState createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  final timeout = Duration(seconds: 4);
  final ms = Duration(milliseconds: 500);

  void handleTimeout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MyHomePage(title: 'MangaZer'),
      ),
    );
  }

  Timer startTimeout([int milliseconds]) {
    var duration = milliseconds == null ? timeout : ms * milliseconds;
    return Timer(duration, handleTimeout);
  }

  @override
  void initState() {
    super.initState();
    startTimeout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 2,
                child: FlareActor("assets/akatsuki.flr",
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                    animation: "Animate"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("MangaZer",
                    style: Theme.of(context)
                        .textTheme
                        .headline2
                        .copyWith(color: Theme.of(context).primaryColor)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
