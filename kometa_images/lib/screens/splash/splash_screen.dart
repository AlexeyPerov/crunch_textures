import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  static String routeName = "/splash";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Container(),
        ),
        body: Align(
            alignment: Alignment.center,
            child: LinearProgressIndicator()));
  }
}
