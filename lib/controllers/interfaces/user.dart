import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skunk_savers/models/response.dart';
import 'package:skunk_savers/models/user.dart';

abstract class IUserController {
  late CollectionReference users;
  Future<SSCUser> getUserDetails(String uid);
  Future<SSCResponse> sendmail(String name, String email, String password);
  Future<SSCResponse> saveUser(SSCUser sscUser);
  Future<SSCResponse> updateUser(SSCUser sscUser);
  Future<SSCResponse> partialUpdateUser(String uid, Map<String, dynamic> data);
  Future<SSCResponse> saveFCMToken(String uid, String token);
}
