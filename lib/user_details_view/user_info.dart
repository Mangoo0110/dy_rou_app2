import 'dart:math';

import 'package:dy_rou/services/auth/auth_services.dart';
import 'package:dy_rou/services/cloud/User_details_storage/firebase_cloud_user_details.dart';
import 'package:dy_rou/services/cloud/User_details_storage/user_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserInformation extends StatelessWidget {
  const UserInformation({
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    FirebaseCloudUserDetailsStorage userDetails = FirebaseCloudUserDetailsStorage();
    
    
    var homeUser = AuthService.firebase().currentUser!.id;
    var size = MediaQuery.of(context).size;
    //Stream<Iterable<UserDetails>>user = userDetails.getUserDetails(userId: homeUser);
    //Future<Iterable<UserDetails>> details = user.elementAt(0);
    return Scaffold(
      body: StreamBuilder(
                      stream: userDetails.getUserDetails(userId: homeUser),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            if (snapshot.hasData) {
                              final all = snapshot.data as Iterable<UserDetails>;
                              final userDetails = all.elementAt(0);
                              String name = userDetails.userName;
                              if(name=='')name = userDetails.userEmail;
                              //print("Hi, $name");
                              return SingleChildScrollView(
                                padding: EdgeInsets.only(top: size.height * .05),
                                child: Column(children: [
                                 SizedBox(
                                   width: size.width,
                                   child: Row(children:[
                                  CircleAvatar(child: Icon(Icons.person,size: min(size.height,size.width)*.1,color: Colors.deepOrange.shade200,),),
                                  Text("Hi, $name", style: TextStyle(fontSize: size.width * .05),), 
                                                                 ]),
                                 ),
                                ],),
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
}