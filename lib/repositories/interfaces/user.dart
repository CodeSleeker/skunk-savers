import 'package:skunk_savers/models/response.dart';
import 'package:skunk_savers/models/user.dart';

abstract class IUserRepository {
  Future<SSCUser> getUserDetails(String uid);
  Future<SSCResponse> sendMail(String name, String email, String password);
  Future<SSCResponse> saveUser(SSCUser sscUser);
  Future<SSCResponse> updateUser(SSCUser sscUser);
  Future<SSCResponse> partialUpdateUser(String uid, Map<String, dynamic> data);
  Future<SSCResponse> saveFCMToken(String uid, String token);
}
