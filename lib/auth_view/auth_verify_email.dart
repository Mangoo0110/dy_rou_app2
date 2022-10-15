import 'package:dy_rou/constants/routes.dart';
import 'package:dy_rou/services/auth/auth_services.dart';
import 'package:dy_rou/services/theme_services.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

_appBar(BuildContext context, String title) {
  return AppBar(
    title: Text(title),
    leading: GestureDetector(
      onTap: () {
        ThemeServices().switchTheme();
        devtools.log(DateTime.now().day.toString());
      },
      child: const Icon(
        Icons.nightlight_round,
        size: 20,
      ),
    ),
    toolbarHeight: MediaQuery.of(context).size.height * 0.06,
    actions: const [
      Icon(
        Icons.person,
        size: 20,
      ),
      SizedBox(
        width: 20,
      ),
    ],
  );
}

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, 'Verify email'),
      body: Column(children: [
        const Text(
            "we've sent you an email verification. Please open it to verify your account."),
        const Text(
            "If you haven't recieved a verification email yet, press the button again"),
        TextButton(
          onPressed: () async {
            final user = AuthService.firebase().currentUser;
            await AuthService.firebase().sendEmailVerification();
          },
          child: const Text('Send email verification'),
        ),
        TextButton(
          onPressed: () async {
            final user = AuthService.firebase().currentUser;
            if(user!=null){
            await AuthService.firebase().logOut();
            Navigator.of(context).pushNamedAndRemoveUntil(
              registerRoute,
              (route) => false,
            );
            }else{
               Navigator.of(context).pushNamedAndRemoveUntil(
              registerRoute,
              (route) => false,
            );
            }
          },
          child: const Text('Restart'),
        ),
      ]),
    );
  }
}
