//import 'package:dy_rou/crud/crud_task.dart';
import 'package:dy_rou/constants/routes.dart';
import 'package:dy_rou/services/auth/auth_services.dart';
import 'package:dy_rou/task_view/tasks_view.dart';
import 'package:dy_rou/utilities/generics/get_arguments.dart';
import 'package:flutter/material.dart';
import 'package:dy_rou/services/cloud/firebase_cloud_storage.dart';
import 'package:dy_rou/services/cloud/cloud_task.dart';
import 'package:dy_rou/services/cloud/cloud_exceptions.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreateUpdateTaskView extends StatefulWidget {
  const CreateUpdateTaskView({super.key});

  @override
  State<CreateUpdateTaskView> createState() => _CreateUpdateTaskViewState();
}

class _CreateUpdateTaskViewState extends State<CreateUpdateTaskView> {
  //DatabaseTask? _task;
  late DateTime taskStartsAt;
  late DateTime taskFinishesAt;
  bool changingDateTimes= false;
  bool updating = false;
  bool creating = false;
  //bool changingDateTimes = false; 
  // DateTime fromTask = DateTime.now();
  // DateTime toTask = DateTime.now().add(const Duration(hours: 1));
  late int t;
  //int startDate = DateTime.now();
  //int endDate = DateTime.now().millisecond;

  CloudTask? _task;
  //late final TaskService _taskService;
  late FirebaseCloudStorage _taskService;
  late TextEditingController _textController;
  String updateText='';
  @override
  void initState() {
    _taskService = FirebaseCloudStorage();
    _textController = TextEditingController();
    taskStartsAt = DateTime.now();
    taskFinishesAt = DateTime.now().add(const Duration(hours: 1));
    t=0;
    //print("Count1 is $t ......\n");
    super.initState();
  }

  /*
  void _textControllerListener() async {
    final task = _task;
    if (task == null) return;
    final text = _textController.text;
    await _taskService.updateTask(
      documentId: task.documentId,
      title: text,
      taskStartsAt: taskStartsAt,
      taskFinishesAt: taskFinishesAt,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }*/

  Future<CloudTask> createOrGetExistingTask(buildContext) async {
    final widgetTask = context.getArgument<CloudTask>();

    if (widgetTask != null) {
      _task = widgetTask;
      _textController.text = widgetTask.title;
      updating =true;
     if(!changingDateTimes){
      _textController.text = widgetTask.title;
      taskStartsAt = widgetTask.taskStartsAt;
      taskFinishesAt = widgetTask.taskFinishesAt;
     }
     else {
      _textController.text = updateText;
     }
      return widgetTask;
    }
    final existingTask = _task;
    if (existingTask != null) {
     updating =true;
     if(!changingDateTimes){
      _textController.text = existingTask.title;
      taskStartsAt = existingTask.taskStartsAt;
      taskFinishesAt = existingTask.taskFinishesAt;
     }
     else {
      _textController.text = updateText;
     }
      return existingTask;
    }
    else{
    creating = true;
    final currentUser = AuthService.firebase().currentUser!;
    //final email = currentUser.email;
    final userId = currentUser.id;
    //final owner = await _taskService.getUser(email: email);
    final newTask = await _taskService.createNewTask(
      userId: userId,
      taskStartsAt: taskStartsAt,
      taskFinishesAt: taskFinishesAt,
    );
    _task = newTask;
    return newTask;
    }
  }

  void _deleteTaskIfTextIsEmpty() {
    final task = _task;
    print("delete called");
    if (task != null) {
      _taskService.deleteTask(documentId: task.documentId);
    }
  }

  void _saveTaskIfTextIsNotEmpty() async {
    final task = _task;
    if (task == null) return;
    final text = _textController.text;
    if (text.isNotEmpty) {
      await _taskService.updateTask(
        documentId: task.documentId,
        title: text,
        taskStartsAt: taskStartsAt,
        taskFinishesAt: taskFinishesAt,
      );
      print("updated!!!");
    }
  }
  @override
  void dispose() {
    //_deleteTaskIfTextIsEmpty();
    //_saveTaskIfTextIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //t++;
    print("Count is $t \n");
    final color = Colors.green.shade500;
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(onPressed: () {
          if(creating){
            _deleteTaskIfTextIsEmpty();
          }
          Navigator.of(context).pop(
                  createOrUpdateTaskRoute
                );
        },),
        title: const Text('Task'),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                _saveTaskIfTextIsNotEmpty();
                Navigator.of(context).pop(
                  createOrUpdateTaskRoute
                );
              },
              icon: const Icon(Icons.check),
          ),
        ],
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder(
        future: createOrGetExistingTask(BuildContext),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              //_task = snapshot.data as DatabaseTask;
              //_setupTextControllerListener();
              return Column(
                children: [
                  TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: ' Add title ',
                      hintStyle: TextStyle(color: Colors.white),
                      fillColor: Colors.black,
                      border: UnderlineInputBorder(),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Divider(height: 2,),
                  ListTile(
                    title: Column(children: [
                      from(),
                      to(),
                    ]),
                  )
                ],
              );
            default:
              return const Center(child: Text("Connecting to The Internet..."));
          }
        },
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget from() {
    return Row(
      children: [
        const Expanded(
            //flex: 2,
            child: Text(
              ' From',
              style: TextStyle(fontSize: 18),
            )),
        Expanded(
          //flex: 1,
          child: TextButton(
              onPressed: () async {
              final  fromTask =
                    await pickDate(taskStartsAt);
                if(fromTask==null){
                  print("null from fromTask Date picker\n");
                  return;
                }
                else{
                  changingDateTimes =true;
                  taskStartsAt = fromTask;
                  print("Date picked is $taskStartsAt ..."); 
                  t++;
                  //_saveTaskIfTextIsNotEmpty();
                  updateText = _textController.text;
                  if(taskFinishesAt.isBefore(taskStartsAt)) taskFinishesAt = taskStartsAt.add(const Duration(hours: 1));
                setState(() {});
                }
              },
              child: Text(toDate(taskStartsAt))),
        ),
        Expanded(
          child: TextButton(
              onPressed: () async {
              final  fromTask =
                    await pickTime(taskStartsAt);
                if (fromTask == null){
                  print("null from fromTask Time picker\n");
                  return;
                }
                else {
                  changingDateTimes = true;
                  taskStartsAt = fromTask;
                  updateText = _textController.text;
                  if(taskFinishesAt.isBefore(taskStartsAt)) taskFinishesAt = taskStartsAt.add(const Duration(hours: 1));
                  setState(() {
                  });
                }
              },
              child: Text(toTime(taskStartsAt))),
        ),
      ],
    );
  }

  Widget to() {
    return Row(
      children: [
        const Expanded(
            //flex: 2,
            child: Text(
              ' To',
              style: TextStyle(fontSize: 18),
            )),
        Expanded(
          //flex: 1,
          child: TextButton(
              onPressed: () async {
                final toTask =
                    await pickDate(taskFinishesAt);
                if (toTask == null){
                  print("null from toTask Date picker\n");
                  return;
                }
                else {
                  changingDateTimes = true;
                  taskFinishesAt = toTask;
                  updateText = _textController.text;
                  print("Date picked is $toTask ...");
                  if(taskFinishesAt.isBefore(taskStartsAt)) taskStartsAt = taskFinishesAt.subtract(const Duration(hours: 1));
                  setState(() {
                   });
                }
              },
              child: Text(toDate(taskFinishesAt))),
        ),
        Expanded(
          child: TextButton(
              onPressed: () async {
              final toTask =
                    await pickTime(taskFinishesAt);
                if (toTask == null){
                  print("null from toTask Time picker\n");
                  return;
                }
                else {
                  changingDateTimes = true;
                  taskFinishesAt = toTask;
                  updateText = _textController.text;
                  if(taskFinishesAt.isBefore(taskStartsAt)) taskStartsAt = taskFinishesAt.subtract(const Duration(hours: 1));
                  setState(() {
                  });
                }
              },
              child: Text(toTime(taskFinishesAt))),
        ),
      ],
    );
  }
  Future<DateTime?> pickDate(initialDate) async {
  var date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000,1),
      lastDate: DateTime(2200));
  if (date == null) return null;
  print("initial date is $initialDate ");
  final time = Duration(hours: initialDate.hour, minutes: initialDate.minute);

  print("initial time is $time  ");
  //date.add(time);
  date = date.add(time);
  print("Date is $date  ");
  return date;
 }

Future<DateTime?> pickTime(initialDate) async {
  var timeOfDay = await showTimePicker(
      context: context, initialTime: TimeOfDay.fromDateTime(initialDate),);
  if (timeOfDay == null) return null;
  var date = DateTime(initialDate.year, initialDate.month, initialDate.day);
  final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);
  
  date = date.add(time);
  print("Time Date is $date ....");
  return date;
 }
}

String toDate(DateTime dateAndTime) {
  final date = DateFormat.yMMMEd().format(dateAndTime);
  print("Date is $date\n");
  return date;
}

String toTime(DateTime dateAndTime) {
  final time = DateFormat.jm().format(dateAndTime);
  print("Time is $time\n");
  return time;
}


