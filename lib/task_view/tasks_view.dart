import 'package:dy_rou/constants/routes.dart';
import 'package:dy_rou/crud/crud_task.dart';
import 'package:dy_rou/enums/menu_actions.dart';
import 'package:dy_rou/services/auth/auth_services.dart';
import 'package:dy_rou/services/auth/firebase_auth_provider.dart';
import 'package:dy_rou/services/theme_services.dart';
import 'package:dy_rou/task_view/tasks_list_view.dart';
import 'package:dy_rou/utilities/dialogs/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class Taskview extends StatefulWidget {
  const Taskview({Key? key}) : super(key: key);

  @override
  State<Taskview> createState() => _TaskviewState();
}

class _TaskviewState extends State<Taskview> {
  late final TaskService _taskService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _taskService = TaskService();
    _taskService.open();
    super.initState();
  }

  @override
  void dispose() {
    _taskService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, 'Taskview'),
      body: FutureBuilder(
        future: _taskService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _taskService.allTasks,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allTasks = snapshot.data as List<DatabaseTask>;
                        return TasksListView(
                          tasks: allTasks,
                          onDeleteTask: (task) async {
                            await _taskService.deleteTask(id: task.id);
                          },
                          onTap: (task) {
                            Navigator.of(context).pushNamed(
                              createOrUpdateTaskRoute,
                              arguments: task,
                            );
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
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
        print(DateTime.now().day);
      },
      child: const Icon(
        Icons.nightlight_round,
        size: 20,
      ),
    ),
    toolbarHeight: MediaQuery.of(context).size.height * 0.06,
    actions: [
      IconButton(
        onPressed: () {
          Navigator.of(context).pushNamed(createOrUpdateTaskRoute);
        },
        icon: const Icon(Icons.add),
      ),
      PopupMenuButton<MenuAction>(
        onSelected: (value) async {
          switch (value) {
            case MenuAction.logout:
              final shouldLogout = await showLogOutDialog(context);
              if (shouldLogout) {
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
