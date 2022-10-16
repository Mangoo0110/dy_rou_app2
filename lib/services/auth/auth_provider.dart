import 'package:dy_rou/services/auth/auth_user.dart';
//import 'dart:html';
abstract class AuthProvider {
  Future<void>initialize();
  AuthUser? get currentUser;
   Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  Future<AuthUser> login({
    required String email,
    required String password,
  });
 

   Future<void> logOut();
    Future<void> sendEmailVerification();
}
