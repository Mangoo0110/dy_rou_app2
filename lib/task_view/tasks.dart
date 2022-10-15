
import 'package:dy_rou/constants/routes.dart';
import 'package:dy_rou/enums/menu_actions.dart';
import 'package:dy_rou/services/auth/auth_services.dart';
import 'package:dy_rou/services/theme_services.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

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
                await AuthService.firebase().logOut();
                 Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
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
