import 'package:flutter/material.dart';

String? notEmptyValidator(var value) {
  if (value == null || value.isEmpty) {
    return "Field cannot be empty";
  } else {
    return null;
  }
}

String? passConfirmationValidator(
    var value, TextEditingController passController) {
  String? notEmpty = notEmptyValidator(value);
  if (notEmpty != null) {
    return notEmpty;
  }

  if (value.length < 6) {
    return "Password must be at least 6 characters";
  }

  if (value != passController.value.text) {
    return "Password does not match";
  }

  return null;
}
