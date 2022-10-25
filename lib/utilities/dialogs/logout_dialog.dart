import 'package:dy_rou/utilities/dialogs/generic_dialog_box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Log Out',
    content: 'Are you sure you want to logout?',
    optionBuilder: ()=>{
      'Cancel': false,
      'Log out': true,
    },
  ).then((value) => value ?? false);
}
