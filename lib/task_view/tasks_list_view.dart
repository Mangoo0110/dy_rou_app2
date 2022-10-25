import 'package:dy_rou/crud/crud_task.dart';
import 'package:dy_rou/utilities/dialogs/delete_dialog.dart';
import 'package:flutter/material.dart';

typedef TaskCallBack = void Function(DatabaseTask task);

class TasksListView extends StatelessWidget {
  final List<DatabaseTask> tasks;
  final TaskCallBack onDeleteTask;
  final TaskCallBack onTap;
  const TasksListView({
    Key? key,
    required this.tasks,
    required this.onDeleteTask,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          onTap: () {
            onTap(task);
          },
          title: Text(
            task.taskName,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteTask(task);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
