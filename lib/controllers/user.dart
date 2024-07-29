import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skunk_savers/controllers/interfaces/user.dart';
import 'package:skunk_savers/models/response.dart';
import 'package:skunk_savers/models/saving.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/res/constant.dart';

class UserController implements IUserController {
  Dio dio = Dio();
  @override
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  Future<SSCUser> getUserDetails(String uid) async => await users.doc(uid).get().then((value) {
        if (value.data() == null) {
          return SSCUser();
        }

        return SSCUser.fromJson(value.data() as Map<String, dynamic>);
      }).catchError((e) {
        return SSCUser();
      });

  @override
  Future<SSCResponse> sendmail(name, email, password) async {
    List to = [
      {'email': email, 'name': name}
    ];
    var body = Global.emailBody;
    body['to'] = to;
    body['htmlContent'] = '<html><head></head><body><p>Greetings,</p>You can now login to your SSC Mobile app.<br/>Your password is <b>$password</b></p></body></html>';
    var headers = Constant.headers;
    headers['api-key'] = dotenv.env['SEND_BLUE_API']!;
    Response response = await dio.post(
      Constant.sendBlueApi,
      options: Options(
        headers: headers,
      ),
      data: body,
    );
    if (response.statusCode == 201) {
      return SSCResponse(success: true, password: password);
    }
    return SSCResponse(success: false, errorMessage: 'Error sending email');
  }

  @override
  Future<SSCResponse> saveUser(SSCUser sscUser) async {
    try {
      await users.doc(sscUser.uid).set(sscUser.toJson());
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> updateUser(SSCUser sscUser) async {
    try {
      await users.doc(sscUser.uid).update(sscUser.toJson());
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> partialUpdateUser(String uid, Map<String, dynamic> data) async {
    try {
      await users.doc(uid).set(data, SetOptions(merge: true));
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> saveFCMToken(String uid, String token) async {
    try {
      await users.doc(uid).set({'token': token}, SetOptions(merge: true));
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }
}
