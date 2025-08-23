import 'package:flutter/material.dart';

String? validateNonEmpty(String? value) {
  if (value == null || value.isEmpty) {
    return 'Field cannot be empty';
  }
  return null;
}

InputDecoration textFieldStyle(BuildContext context, String helperText) {
  return InputDecoration(
    contentPadding: const EdgeInsets.all(12),
    helperText: helperText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        width: 1,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        width: 1,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        width: 1,
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
    ),
  );
}
