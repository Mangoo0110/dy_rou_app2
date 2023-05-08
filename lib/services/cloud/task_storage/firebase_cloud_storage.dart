import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dy_rou/services/cloud/task_storage/cloud_exceptions.dart';
import 'package:dy_rou/services/cloud/task_storage/cloud_storage_constants.dart';
import 'package:dy_rou/services/cloud/task_storage/cloud_task.dart';


class FirebaseCloudStorage {
  final tasks = FirebaseFirestore.instance.collection('tasks');
  String greater = "greater";
  String smaller = "smaller";
  String equal = "equal";
  //tasks = tasks.orderBy("taskStartsAt",descending: false);
  Future<void> deleteTask({required String documentId}) async {
    try {
      await tasks.doc(documentId).delete();
    } catch (_) {
      throw CouldNotDeleteTaskException();
    }
  }

  Future<void> updateTask({
    required String documentId,
    required String title,
    required DateTime taskStartsAt,
    required DateTime taskFinishesAt,
  }) async {
    try {
      await tasks.doc(documentId).update({taskTitle: title, fromDate: taskStartsAt, toDate: taskFinishesAt});
    } catch (_) {
      throw CouldNotUpdateTaskException();
    }
  }

  Stream<Iterable<CloudTask>> allTasks({required String ownerUserId, required DateTime date}){
    //date = date.add(const Duration(hours: 24));
   Query<Map<String,dynamic>> preTasks = tasks.orderBy("toDate");
   //preTasks = preTasks.orderBy("toDate");
    return  preTasks.snapshots().map((event) => event.docs
          .map((doc) => CloudTask.fromSnapshot(doc))
          .where((task) => (task.ownerUserIdNo == ownerUserId && (compareDate(task.taskStartsAt, date)!=greater && compareDate(task.taskFinishesAt, date)!=smaller))));
  }

  Future<Iterable<CloudTask>> getTasks({required String ownerUserId}) async {
    try {
      return await tasks
          .where(ownerUserId, isEqualTo: ownerUserId)
          .get()
          .then(
            (value) => value.docs.map((doc) => CloudTask.fromSnapshot(doc)),
          );
    } catch (_) {
      throw CouldNotGetTaskException();
    }
  }

  Future<CloudTask> createNewTask({required String userId, required taskStartsAt, required taskFinishesAt}) async {
    final document = await tasks.add({
      ownerUserId: userId,
      taskTitle: 'No title',
      fromDate: taskStartsAt,
      toDate: taskFinishesAt,
    });
    final fetchedTask = await document.get();
    return CloudTask(
      documentId: fetchedTask.id,
      ownerUserIdNo: userId,
      title: '',
      taskStartsAt: taskStartsAt,
      taskFinishesAt: taskFinishesAt,
    );
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  String compareDate(DateTime date1, DateTime date2){
    if(date1.year==date2.year){
      if(date1.month==date2.month){
        if(date1.day==date2.day){
        return equal;
        }
        else{
          if(date1.day>date2.day){
            return greater;
          }
          else {
           return smaller;
          }
        } 
      }
      else{
        if(date1.month>date2.month){
            return greater;
          }
          else {
           return smaller;
          }
      }
    }
    else{
      if(date1.year>date2.year){
            return greater;
          }
          else {
           return smaller;
          }
    }
    
  }
}
