import 'package:dy_rou/utilities/dialogs/generic_dialog_box.dart';
import 'package:flutter/cupertino.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
    context: context,
    title: 'An error has occured!',
    content: text,
    optionBuilder: ()=>{
      'OK':null,
    },
  );
}
