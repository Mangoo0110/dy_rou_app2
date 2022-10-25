import 'package:dy_rou/crud/crud_task.dart';
import 'package:dy_rou/services/auth/auth_services.dart';
import 'package:dy_rou/utilities/generics/get_arguments.dart';
import 'package:flutter/material.dart';

class CreateUpdateTaskView extends StatefulWidget {
  const CreateUpdateTaskView({super.key});

  @override
  State<CreateUpdateTaskView> createState() => _CreateUpdateTaskViewState();
}

class _CreateUpdateTaskViewState extends State<CreateUpdateTaskView> {
  DatabaseTask? _task;
  late final TaskService _taskService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _taskService = TaskService();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final task = _task;
    if (task == null) return;
    final text = _textController.text;
    await _taskService.updateTask(
      task: task,
      taskName: text,
    );
  }

  void _setupTextControllerListener(){
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<DatabaseTask> createOrGetExistingTask(BuildContext) async {
    final widgetTask = context.getArgument<DatabaseTask>();

    if(widgetTask!=null){
      _task = widgetTask;
      _textController.text= widgetTask.taskName;
      return widgetTask;
    }
    final existingTask = _task;
    if (existingTask != null) {
      return existingTask;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _taskService.getUser(email: email);
    final newTask = await _taskService.createTask(owner: owner);
    _task = newTask;
    return newTask;
  }

  void _deleteTaskIfTextIsEmpty() {
    final task = _task;
    if (_textController.text.isEmpty && task != null) {
      _taskService.deleteTask(id: task.id);
    }
  }

  void _saveTaskIfTextIsNotEmpty() async {
    final task = _task;
    if(task==null)return;
    final text = _textController.text;
    if (text != null && text.isNotEmpty) {
      await _taskService.updateTask(
        task: task,
        taskName: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteTaskIfTextIsEmpty();
    _saveTaskIfTextIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New task'),
      ),
      body: FutureBuilder(
        future: createOrGetExistingTask(BuildContext),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.done:
            //_task = snapshot.data as DatabaseTask;
            _setupTextControllerListener();
            return TextField(
              controller: _textController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Start typing your task.....',
              ),
            );
            default:
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
