import 'package:dy_rou/constants/routes.dart';
import 'package:dy_rou/services/auth/auth_exceptions.dart';
import 'package:dy_rou/services/auth/auth_services.dart';
import 'package:dy_rou/services/theme_services.dart';
import 'package:dy_rou/utilities/showErrorDialogs.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, 'Register'),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email here',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your password here',
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
               await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );
                final user = AuthService.firebase().currentUser;
                print('user is ${user.toString()}');
               if(user!=null) {
                await AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(verifyEmailRoute);
               }
              //  else {
              //     await showErrorDialog(
              //     context,
              //     'Wrong credentials',
              //   );
              //  }
                
              } 
               on WeekPasswordAuthException {
                print('Week Password');
                await showErrorDialog(
                  context,
                  'Week Password',
                );
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(
                  context,
                  'Email is already in use. You can login with this email.',
                );
              } on InvalidEmailAuthException {
                print("GOt the email problem but..");
                await showErrorDialog(
                  context,
                  'Invalid email address.',
                );
              } on GenericAuthException catch (e) {
                await showErrorDialog(
                  context,
                  'Failed to register',
                );
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            child: const Text('Already registered? Login here!'),
          ),
        ],
      ),
    );
  }
}

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
