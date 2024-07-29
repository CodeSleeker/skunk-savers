import 'dart:math';

class Constant {
  static const fcmApi = 'https://fcm.googleapis.com/fcm/send';
  static const fcmHeaders = {
    'Content-Type': 'application/json',
    'Authorization': '',
  };
  static const sendBlueApi = 'https://api.sendinblue.com/v3/smtp/email';
  static const headers = {
    'Content-Type': 'application/json',
    'accept': 'application/json',
    'api-key': '',
  };
  // static const String chars = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890!=\$&#*_";
  static const String chars = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";
}

class Global {
  static String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => Constant.chars.codeUnitAt(Random().nextInt(Constant.chars.length))));
  static Map<String, dynamic> emailBody = {
    'sender': {
      'name': 'SSC Admin',
      'email': 'info@ssc.com',
    },
    'to': [],
    'subject': 'You Password',
    'htmlContent': '',
  };
}
