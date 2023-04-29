import 'package:dy_rou/constants/routes.dart';
import 'package:dy_rou/crud/crud_task.dart';
import 'package:dy_rou/enums/menu_actions.dart';
import 'package:dy_rou/services/auth/auth_services.dart';
import 'package:dy_rou/services/auth/firebase_auth_provider.dart';
import 'package:dy_rou/services/cloud/cloud_task.dart';
import 'package:dy_rou/services/cloud/firebase_cloud_storage.dart';
import 'package:dy_rou/services/theme_services.dart';
import 'package:dy_rou/task_view/tasks_list_view.dart';
import 'package:dy_rou/utilities/dialogs/logout_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Taskview extends StatefulWidget {
  const Taskview({Key? key}) : super(key: key);

  @override
  State<Taskview> createState() => _TaskviewState();
}

class _TaskviewState extends State<Taskview> {
  late final FirebaseCloudStorage _taskService;
  String get userId => AuthService.firebase().currentUser!.id;
  DateTime kdate = DateTime.now(); 
  //String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _taskService = FirebaseCloudStorage();
    //_taskService.open();
    super.initState();
  }

  @override
  void dispose() {
    _taskService;
    //_taskService.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: 
          StreamBuilder(
                    stream: _taskService.allTasks(ownerUserId: userId, date: kdate),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          if (snapshot.hasData) {
                            final allTasks = snapshot.data as Iterable<CloudTask>;
                            return TasksListView(
                              tasks: allTasks,
                              onDeleteTask: (task) async {
                                await _taskService.deleteTask(documentId: task.documentId);
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
                  ),
      );
  }
      /* FutureBuilder(
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
                        final allTasks = snapshot.data as List<CloudTask>;
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
      ),*/

    _appBar() {
  return AppBar(
    title: Text(dateWhen(kdate)),
    leading: GestureDetector(
      onTap: () {
        ThemeServices().switchTheme();
      },
      child: const Icon(
        Icons.nightlight_round,
        size: 28,
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
      IconButton(
        onPressed: () async{
          final pickedDate = await pickDate(kdate);
          if(pickedDate==null)return;
          else{
             kdate = pickedDate;
             setState(() {
             });
          }
        },
        icon: const Icon(Icons.calendar_month),
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
Future<DateTime?> pickDate(initialDate) async {
  final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2200));
  if (date == null) return null;
  return date;
}

  }
  
  String dateWhen(DateTime kdate) {
    var millisecondsPerDay = 86400000;
    var today = (DateTime.now().millisecondsSinceEpoch)/millisecondsPerDay;
    var tommorrow = today + Duration.millisecondsPerDay/millisecondsPerDay;
    var yesterday = today - Duration.millisecondsPerDay/millisecondsPerDay;
    var exp = kdate.millisecondsSinceEpoch/millisecondsPerDay;
    
    return DateFormat("yMMMMd").format(kdate);
    
  }

 

