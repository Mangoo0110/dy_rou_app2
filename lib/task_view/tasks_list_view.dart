import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dy_rou/crud/crud_task.dart';
import 'package:dy_rou/services/cloud/cloud_task.dart';
import 'package:dy_rou/utilities/dialogs/delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

typedef TaskCallBack = void Function(CloudTask task);

class TasksListView extends StatelessWidget {
  final Iterable<CloudTask> tasks;
  final TaskCallBack onDeleteTask;
  final TaskCallBack onTap;
  
  const TasksListView({
    Key? key,
    required this.tasks,
    required this.onDeleteTask,
    required this.onTap,
  }) : super(key: key);

  
  
  Iterable<CloudTask> tasksThatDone(){
    return tasks.where((element) => element.taskFinishesAt.isBefore(DateTime.now()));
  }

  Iterable<CloudTask> tasksThatOngoing(){
    return tasks.where((element) => element.taskFinishesAt.isAfter(DateTime.now()) && !element.taskStartsAt.isAfter(DateTime.now()));
  }

  Iterable<CloudTask> tasksThatUpcoming(){
    return tasks.where((element) => element.taskStartsAt.isAfter(DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    Iterable<CloudTask>tasksDone,tasksOngoing,tasksUpcoming;
    tasksDone = tasksThatDone();
    tasksOngoing = tasksThatOngoing();
    tasksUpcoming = tasksThatUpcoming();

    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
      final task = tasks.elementAt(index);
        return AnimatedContainer(
            duration: Duration(milliseconds: index * 500),
            curve: Curves.easeInOut,
            //transform: Matrix4.translationValues(MediaQuery.of(context).size.width, 0, 0),
            padding:  EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width)/20) ,
            margin: const EdgeInsets.only(bottom: 9),
            decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: DateTime.now().isAfter(task.taskFinishesAt)?Colors.grey:Colors.green,
          ),
          child: ListTile(  
            onTap: () {
              onTap(task);
            },
            subtitle: Text(timeDomain(task.taskStartsAt, task.taskFinishesAt)),
            title: Text(
                    task.title,
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
          ),
        );
      },
    ); 
  }
  Widget listViewExtra(Color colorOfTiles,Iterable<CloudTask>tasksM){
    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: tasksM.length,
      itemBuilder: (context, index) {
      final task = tasksM.elementAt(index);
        return AnimatedContainer(
            
            duration: Duration(milliseconds: index * 500),
            curve: Curves.easeInOut,
            //transform: Matrix4.translationValues(MediaQuery.of(context).size.width, 0, 0),
            padding:  EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width)/20) ,
            margin: const EdgeInsets.only(bottom: 9),
            decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: colorOfTiles,//DateTime.now().isAfter(task.taskFinishesAt)?Colors.grey:Colors.green,
          ),
          child: ListTile(  
            onTap: () {
              onTap(task);
            },
            subtitle: Text(timeDomain(task.taskStartsAt, task.taskFinishesAt)),
            title: Text(
                    task.title,
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
          ),
        );
      },
    );
  }
  
  
  String timeDomain(DateTime taskStartsAt, DateTime taskFinishesAt){
    DateTime today = DateTime.now();
    if(today.year==taskFinishesAt.year && today.month==taskFinishesAt.month && today.day==taskFinishesAt.day){
      if( today.year!=taskFinishesAt.year || today.month!=taskFinishesAt.month || today.day!=taskFinishesAt.day ){
        var time = DateFormat.jm().format(taskFinishesAt);
        return "Untill $time";
      }
      else{
        var from = DateFormat.jm().format(taskStartsAt);
        var to = DateFormat.jm().format(taskFinishesAt);
        return "$from - $to";
      }
    }
    else{
      var from = DateFormat("yMMMMd").format(taskStartsAt);
      var to = DateFormat("yMMMMd").format(taskFinishesAt);
      return "$from - $to";
    }
    
  }
}
