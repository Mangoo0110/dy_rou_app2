import 'package:dy_rou/constants/routes.dart';
import 'package:dy_rou/services/auth/auth_exceptions.dart';
import 'package:dy_rou/services/auth/auth_services.dart';
import 'package:dy_rou/services/theme_services.dart';
import 'package:dy_rou/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;


class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
      appBar: _appBar(context, 'Login'),
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
               await AuthService.firebase().login(
                  email: email,
                  password: password,
                );

                final user = AuthService.firebase().currentUser;
                if (user != null) {
                  if (user.isEmailVerified) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      tasksRoute,
                      (route) => false,
                    );
                  } else {
                    devtools.log('user is duck');
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      verifyEmailRoute,
                      (route) => false,
                    );
                  }
                } else {
                  await showErrorDialog(
                    context,
                    'Something went wrong!!',
                  );
                }
              } on UserNotFoundAuthException {
                await showErrorDialog(
                  context,
                  'User not found',
                );
              } on WrongPasswordAuthException {
                await showErrorDialog(
                  context,
                  'Wrong password!',
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  'Authentication error!',
                );
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text('Not registered yet? Register here!'),
          )
        ],

        /* switch (snapshot.connectionState) {
              case ConnectionState.done:
                // TODO: Handle this case.
                return Column(
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
                        final userCredential = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        print(userCredential);
                      },
                      child: const Text('Register'),
                    ),
                  ],
                );
              default:
                return const Text('Loading...');
            }*/
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
