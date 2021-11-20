import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kometa_images/app/theme/theme_constants.dart';
import 'package:kometa_images/common/utilities/navigator_utilities.dart';
import 'dart:math';
import 'components/control_panel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: null, body: alignedBody());
  }

  Widget alignedBody() {
    var width = MediaQuery.of(context).size.width;
    return Align(
      alignment: Alignment.center,
      child: Container(
          width: min(kMinContainerWidth, width), child: ControlPanel()),
    );
  }
}

class HomeScreenNavigation {
  static navigate(BuildContext context) {
    NavigatorUtilities.pushAndRemoveUntil(context, (context) => HomeScreen());
  }
}
