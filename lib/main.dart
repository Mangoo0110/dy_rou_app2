//import 'dart:html';

//import 'dart:js';

import 'package:dy_rou/auth_view/auth_login_view.dart';
import 'package:dy_rou/auth_view/auth_register_view.dart';
import 'package:dy_rou/auth_view/auth_verify_email.dart';
import 'package:dy_rou/firebase_options.dart';
import 'package:dy_rou/services/theme_services.dart';
import 'package:dy_rou/workspace/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as devtools show log;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(
    GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeServices().theme,
      home: const HomePage(),
      routes: {
        '/login/': (context) => const LoginView(),
        '/register/': (context) => const RegisterView(),
        '/home/': (context) => const HomePage(),
        '/tasks/': (context) => const Taskview(), 
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              devtools.log('User is>>$user');
              if (user.emailVerified) {
                devtools.log('email is verified');
                return const Taskview();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }

          // return const LoginView();

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

enum MenuAction { logout }

class Taskview extends StatefulWidget {
  const Taskview({Key? key}) : super(key: key);

  @override
  State<Taskview> createState() => _TaskviewState();
}

class _TaskviewState extends State<Taskview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, 'Taskview'),
      body: const Text('Main UI'),
    );
  }
}

_appBar(BuildContext context, String title) {
  return AppBar(
    title: Text(title),
    leading: GestureDetector(
      onTap: () {
        ThemeServices().switchTheme();
        print(DateTime.now().day);
      },
      child: const Icon(
        Icons.nightlight_round,
        size: 20,
      ),
    ),
    toolbarHeight: MediaQuery.of(context).size.height * 0.06,
    actions: [
      PopupMenuButton<MenuAction>(
        onSelected: (value) async {
          switch (value) {
            case MenuAction.logout:
              final shouldLogout = await showLogOutDialog(context);
              if(shouldLogout){
                await FirebaseAuth.instance.signOut();
                 Navigator.of(context).pushNamedAndRemoveUntil(
                '/login/',
                (_) => false,
              );
              }
              devtools.log(shouldLogout.toString());
              break;
          }
        },
        itemBuilder: (context) {
          return const [
            PopupMenuItem<MenuAction>(
              value: MenuAction.logout,
              child: Text('Log out'),
            ),
          ];
        },
      ),
    ],
  );
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
             
            },
            child: const Text('Log out '),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
