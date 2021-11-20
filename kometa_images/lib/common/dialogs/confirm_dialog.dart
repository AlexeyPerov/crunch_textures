import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ConfirmDialogParams {
  final String title;
  final String contents;

  final String cancelButtonText;
  final String approveButtonText;
  final Function approveAction;
  final Function disapproveAction;

  ConfirmDialogParams(this.title, this.contents, this.cancelButtonText,
      this.approveButtonText, this.approveAction, this.disapproveAction);
}

Future<void> showConfirmDialog(
    BuildContext context, ConfirmDialogParams arguments) async {
  return Alert(
    context: context,
    type: AlertType.none,
    title: arguments.title,
    desc: arguments.contents,
    buttons: [
      DialogButton(
        child: Text(
          arguments.cancelButtonText,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          Navigator.pop(context);
          arguments.disapproveAction();
        },
        color: Color.fromRGBO(0, 179, 134, 1.0),
      ),
      DialogButton(
        child: Text(
          arguments.approveButtonText,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        onPressed: () {
          Navigator.pop(context);
          arguments.approveAction();
        },
        gradient: LinearGradient(colors: [
          Color.fromRGBO(116, 116, 191, 1.0),
          Color.fromRGBO(52, 138, 199, 1.0)
        ]),
      )
    ],
  ).show();
}
