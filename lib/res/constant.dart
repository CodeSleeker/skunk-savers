import 'dart:math';

class Constant {
  static const fcmApi = 'https://fcm.googleapis.com/fcm/send';
  static const fcmHeaders = {
    'Content-Type': 'application/json',
    'Authorization':
        'key=AAAAYcko1TI:APA91bG207QMmvACjSewDmDXM8ElIrUYEhWjjajhb2LbBqVjCesUuaDyBRAuHcYBAQhGvm9qLhXjtaZmDqJ28HCpXo5Vg5VRGQQ6vNOMwo6OkD_LvqPcOAXH7oP0gQ_TnDO23YhJytVf',
  };
  static const sendBlueApi = 'https://api.sendinblue.com/v3/smtp/email';
  static const headers = {
    'Content-Type': 'application/json',
    'accept': 'application/json',
    'api-key':
        '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',
  };
  // static const String chars = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890!=\$&#*_";
  static const String chars =
      "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";
}

class Global {
  static String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length,
          (_) => Constant.chars
              .codeUnitAt(Random().nextInt(Constant.chars.length))));
  static Map<String, dynamic> emailBody = {
    'sender': {
      'name': 'SSC Admin',
      'email': 'info@kawal.com',
    },
    'to': [],
    'subject': 'You Password',
    'htmlContent': '',
  };
}
