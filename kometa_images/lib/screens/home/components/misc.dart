import 'package:flutter/material.dart';

String validateNonEmpty(String value) {
  if (value.isEmpty) {
    return 'Field cannot be empty';
  }
  return null;
}

InputDecoration textFieldStyle(BuildContext context, String helperText) {
  return InputDecoration(
    contentPadding: EdgeInsets.all(12),
    helperText: helperText,
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(width: 0.5, color: Theme.of(context).colorScheme.primary)),
        enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(width: 0.5, color:  Theme.of(context).colorScheme.primaryVariant)),
  );
}