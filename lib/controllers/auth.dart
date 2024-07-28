import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:skunk_savers/controllers/interfaces/auth.dart';
import 'package:skunk_savers/models/response.dart';
import 'package:firebase_admin/firebase_admin.dart';

class AuthController implements IAuthController {
  FirebaseAdmin firebaseAdmin = FirebaseAdmin.instance;

  @override
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Future signInWithEmail(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address';
      }
      return e.code;
    }
  }

  @override
  Future<SSCResponse> createUserWithEmail(String email, String password) async {
    try {
      FirebaseApp app = await Firebase.initializeApp(name: 'secondary', options: Firebase.app().options);
      UserCredential response = await FirebaseAuth.instanceFor(app: app).createUserWithEmailAndPassword(email: email, password: password);
      app.delete();
      return SSCResponse(success: true, uid: response.user!.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return SSCResponse(success: false, errorMessage: 'Invalid email address');
      }
      return SSCResponse(success: true, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> deleteUser(String uid) async {
    try {
      return SSCResponse(success: true);
    } on FirebaseAuthException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future signOut() async {
    await auth.signOut();
  }

  @override
  Future<SSCResponse> validatePassword(String password) async {
    try {
      User firebaseUser = auth.currentUser!;
      AuthCredential credential = EmailAuthProvider.credential(email: firebaseUser.email!, password: password);
      await firebaseUser.reauthenticateWithCredential(credential);
      return SSCResponse(success: true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return SSCResponse(success: false, errorMessage: 'Current password is not correct');
      }
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> updatePassword(String password) async {
    try {
      User firebaseUser = auth.currentUser!;
      await firebaseUser.updatePassword(password);
      return SSCResponse(success: true);
    } on FirebaseAuthException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }
}
