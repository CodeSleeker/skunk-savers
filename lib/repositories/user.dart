import 'package:skunk_savers/controllers/interfaces/user.dart';
import 'package:skunk_savers/controllers/user.dart';
import 'package:skunk_savers/models/response.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/repositories/fund.dart';
import 'package:skunk_savers/repositories/interfaces/fund.dart';
import 'package:skunk_savers/repositories/interfaces/user.dart';

class UserRepository implements IUserRepository {
  IUserController userController = UserController();
  IFundRepository fundRepository = FundRepository();

  @override
  Future<SSCUser> getUserDetails(String uid) async {
    SSCUser user = await userController.getUserDetails(uid);
    return user;
  }

  @override
  Future<SSCResponse> sendMail(
      String name, String email, String password) async {
    return await userController.sendmail(name, email, password);
  }

  @override
  Future<SSCResponse> saveUser(SSCUser sscUser) async {
    return await userController.saveUser(sscUser);
  }

  @override
  Future<SSCResponse> updateUser(SSCUser sscUser) async {
    return await userController.updateUser(sscUser);
  }

  @override
  Future<SSCResponse> partialUpdateUser(
      String uid, Map<String, dynamic> data) async {
    return userController.partialUpdateUser(uid, data);
  }

  @override
  Future<SSCResponse> saveFCMToken(String uid, String token) async {
    return await userController.saveFCMToken(uid, token);
  }
}
