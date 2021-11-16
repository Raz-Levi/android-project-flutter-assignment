// ================= Utils =================
import 'package:flutter/material.dart';

void displaySnackBar(BuildContext context, String msg) {
  final snackBar = SnackBar(content: Text(msg));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void displayAlertDialog(BuildContext context, String alertTitle, String alertContent, List<Widget> alertActions) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(alertTitle),
      content: Text(alertContent),
      actions: alertActions,
    ),
  );
}
