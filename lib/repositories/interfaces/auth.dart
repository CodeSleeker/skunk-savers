import 'package:firebase_auth/firebase_auth.dart';
import 'package:skunk_savers/models/response.dart';

abstract class IAuthRepository {
  Stream<User?> get authStateChanges;
  Future signInWithEmail(String email, String password);
  Future<SSCResponse> createUserWithEmail(String email, String password);
  Future<SSCResponse> deleteUser(String uid);
  Future<SSCResponse> validatePassword(String password);
  Future<SSCResponse> updatePassword(String password);
  Future signOut();
}
