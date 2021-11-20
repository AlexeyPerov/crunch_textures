import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Shortcut methods for Navigator calls.
class NavigatorUtilities {
  static void pop(BuildContext context, GetWidget fallback) {
    var navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (c) => fallback(c)),
          (Route<dynamic> route) => false);
    }
  }

  static pushWithNoTransition(BuildContext context, RoutePageBuilder function) {
    return Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: function, transitionDuration: Duration(seconds: 0)));
  }

  static pushAndRemoveUntil(BuildContext context, WidgetBuilder builder) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: builder), (Route<dynamic> route) => false);
  }
}

typedef Widget GetWidget(BuildContext context);
