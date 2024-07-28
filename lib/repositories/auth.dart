import 'package:firebase_auth/firebase_auth.dart';
import 'package:skunk_savers/controllers/auth.dart';
import 'package:skunk_savers/controllers/interfaces/auth.dart';
import 'package:skunk_savers/models/response.dart';
import 'package:skunk_savers/repositories/interfaces/auth.dart';

class AuthRepository implements IAuthRepository {
  IAuthController authController = AuthController();
  @override
  Stream<User?> get authStateChanges => authController.auth.authStateChanges();

  @override
  Future signInWithEmail(String email, String password) async {
    return await authController.signInWithEmail(email, password);
  }

  @override
  Future<SSCResponse> createUserWithEmail(String email, String password) {
    return authController.createUserWithEmail(email, password);
  }

  @override
  Future<SSCResponse> deleteUser(String uid) async {
    return authController.deleteUser(uid);
  }

  @override
  Future signOut() async {
    await authController.signOut();
  }

  @override
  Future<SSCResponse> validatePassword(String password) async {
    return await authController.validatePassword(password);
  }

  @override
  Future<SSCResponse> updatePassword(String password) async {
    return await authController.updatePassword(password);
  }
}
