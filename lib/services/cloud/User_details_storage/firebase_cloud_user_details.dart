import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dy_rou/services/cloud/User_details_storage/user_details.dart';
import 'package:dy_rou/services/cloud/User_details_storage/user_details_exceptions.dart';
import 'package:dy_rou/services/cloud/User_details_storage/user_details_storage_constant.dart';
import 'package:flutter/material.dart';

class FirebaseCloudUserDetailsStorage{

CollectionReference<Map<String,dynamic>> userDetailsFirestoreInstance(String userId){
   return FirebaseFirestore.instance.collection(userId);
  }

  Stream<Iterable<UserDetails>>getUserDetails( {required String userId} )  {
    try {
      return   userDetailsFirestoreInstance(userId).snapshots().map((event) => event.docs.map((value) => UserDetails.fromSnapshot(value))) ;
          
    } catch (_) {
      throw CouldNotGetUserDetailsException();
    }
}

  Future<void>upDateAll({
  required String userName,
    required String userId,
    required String userEmail,
    required List<String> userFriends,
    required List<String> userNotAcceptedFriends,
    required List<String> userRequestedFriends,
}) async{
 var user = UserDetails(userName: userName, userEmail: userEmail, userFriends: userFriends, userNotAcceptedFriends: userNotAcceptedFriends, userRequestedFriends: userRequestedFriends);
 //user.checkList();
}
 
 Future<void> deleteUserDetails({required String userId}) async{
 try{
  await userDetailsFirestoreInstance(userId).doc().delete();
 }
 catch(_){

 }
 }

 Future<void> createNewUserDetails({required String userId, required String userEmail}) async {
    try{ await userDetailsFirestoreInstance(userId).add({
     name: '',
     email: userEmail,
     friends: [],
     notAcceptedFriends: [],
     requestedFriends: [],
     image: null,

    });
    }
    catch(_){
      throw CouldDeleteException();
    }
    
  }

  Future<void> updateUserName({
    required String userName,
    required String userId,
  }) async {
    try {
      await userDetailsFirestoreInstance(userId).doc().update({name: userName});
    } catch (_) {
      throw CouldNotUpdateUserNameException();
    }
  }

  Future<void> updateUserEmail({
    required String userEmail,
    required String userId,
  }) async {
    try {
      await userDetailsFirestoreInstance(userId).doc().update({ email: userEmail});
    } catch (_) {
      throw CouldNotUpdateUserEmailException();
    }
  }

  Future<void> updateUserFriends({
    required String userId,
    required List<String> userFriends,
    required bool remove,
    required bool add,
    required String value,
  }) async {
    if(add){
      userFriends.add(value);
    }
    if(remove){
      userFriends.removeWhere((element) => element==value);
    }
    try {
      await userDetailsFirestoreInstance(userId).doc().update({ friends: userFriends});
    } catch (_) {
      throw CouldNotUpdateUserFriendsException();
    }
  }

  Future<void> updateUserNotAcceptedFriends({
    required String userId,
    required List<String> userNotAcceptedFriends,
    required bool remove,
    required bool add,
    required String value,
  }) async {
    if(add){
      userNotAcceptedFriends.add(value);
    }
    if(remove){
      userNotAcceptedFriends.removeWhere((element) => element==value);
    }
    try {
      await userDetailsFirestoreInstance(userId).doc().update({ notAcceptedFriends: userNotAcceptedFriends});
    } catch (_) {
      throw CouldNotUpdateUserNotAcceptedFriendsException();
    }
  }

  Future<void> updateUserRequestedFriends({
    required String userId,
    required List<String> userRequestedFriends,
    required bool remove,
    required bool add,
    required String value,
  }) async {
    if(add){
      userRequestedFriends.add(value);
    }
    if(remove){
      userRequestedFriends.removeWhere((element) => element==value);
    }
    try {
      await userDetailsFirestoreInstance(userId).doc().update({ requestedFriends: userRequestedFriends});
    } catch (_) {
      throw CouldNotUpdateUserRequestedFriendsException();
    }
  }

  /*Future<void> updateUserProfileImage({
    required String userId,
    required Image userProfileImage,
  }) async {
    try {
      await userDetailsFirestoreInstance(userId).doc().update({ image: userProfileImage});
    } catch (_) {
      throw CouldNotUpdateUserImageException();
    }
  }
  */

}
