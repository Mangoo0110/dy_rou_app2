import 'package:dy_rou/services/cloud/User_details_storage/user_details_storage_constant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
@immutable
class UserDetails{
  final String userName;
  final String userEmail;
  final List<dynamic> userFriends;
  final List<dynamic> userNotAcceptedFriends;
  final List<dynamic> userRequestedFriends;
  const UserDetails({required this.userName, required this.userEmail, required this.userFriends, required this.userNotAcceptedFriends, required this.userRequestedFriends});

  UserDetails.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot):
  userName = snapshot.data()[name] as String,
  userEmail = snapshot.data()[email] as String,
  userFriends = (snapshot.data()[friends] as List<dynamic>) ,
  userNotAcceptedFriends =(snapshot.data()[notAcceptedFriends] as List<dynamic>),
  userRequestedFriends = (snapshot.data()[requestedFriends] as List<dynamic>);
}
