import 'package:firebase_admin/firebase_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skunk_savers/models/response.dart';

abstract class IAuthController {
  late FirebaseAuth auth;
  Future signInWithEmail(String email, String password);
  Future<SSCResponse> createUserWithEmail(String email, String password);
  Future<SSCResponse> deleteUser(String uid);
  Future<SSCResponse> validatePassword(String password);
  Future<SSCResponse> updatePassword(String password);
  Future signOut();
}
