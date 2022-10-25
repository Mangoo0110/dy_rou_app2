//import 'dart:html';

//import 'dart:js';


import 'package:dy_rou/auth_view/auth_login_view.dart';
import 'package:dy_rou/auth_view/auth_register_view.dart';
import 'package:dy_rou/auth_view/auth_verify_email.dart';
import 'package:dy_rou/constants/routes.dart';
import 'package:dy_rou/services/auth/auth_services.dart';
import 'package:dy_rou/services/theme_services.dart';
import 'package:dy_rou/task_view/create_update_task_view.dart';
import 'package:dy_rou/task_view/tasks_view.dart';
import 'package:dy_rou/workspace/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
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
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        homeRoute: (context) => const HomePage(),
        tasksRoute: (context) => const Taskview(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateTaskRoute: (context) => const CreateUpdateTaskView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user =AuthService.firebase().currentUser;
            if (user != null) {
              devtools.log('User is>>$user');
              if (user.isEmailVerified) {
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
