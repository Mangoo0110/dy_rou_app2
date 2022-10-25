import 'package:dy_rou/utilities/dialogs/generic_dialog_box.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete?',
    optionBuilder: ()=>{
      'Cancel': false,
      'Yes': true,
    },
  ).then((value) => value ?? false);
}
