import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dy_rou/services/cloud/task_storage/cloud_storage_constants.dart';
@immutable
class CloudTask {
  final String documentId;
  final String ownerUserIdNo;
  final String title;
  final DateTime taskStartsAt;
  final DateTime taskFinishesAt;
  const CloudTask({
    required this.documentId,
    required this.ownerUserIdNo,
    required this.title,
    required this.taskStartsAt,
    required this.taskFinishesAt,
   });

   CloudTask.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot):
   documentId = snapshot.id,
   ownerUserIdNo = snapshot.data()[ownerUserId],
   title = snapshot.data()[taskTitle] as  String,
   taskStartsAt = (snapshot.data()[fromDate] as Timestamp).toDate(),
   taskFinishesAt = (snapshot.data()[toDate] as Timestamp).toDate();
   
} 
