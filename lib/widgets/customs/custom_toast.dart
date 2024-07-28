import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:skunk_savers/res/size_config.dart';

class CustomToast {
  BuildContext context;
  FToast fToast = FToast();
  CustomToast(this.context) {
    fToast.init(context);
  }
  Widget toast(
    IconData iconData,
    Color color,
    String msg,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      width: double.infinity,
      color: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: Colors.white,
            size: SizeConfig.safeBlockHorizontal! * 6,
          ),
          SizedBox(
            width: SizeConfig.safeBlockHorizontal! * 3,
          ),
          Text(
            msg,
            style: TextStyle(
              fontFamily: 'Raleway',
              color: Colors.white,
              fontSize: SizeConfig.safeBlockHorizontal! * 5,
            ),
          ),
        ],
      ),
    );
  }

  success({
    int duration = 3,
    ToastGravity gravity = ToastGravity.TOP,
    required String msg,
  }) {
    fToast.removeCustomToast();
    fToast.removeQueuedCustomToasts();
    fToast.showToast(
      child: toast(Icons.check_circle, Colors.green, msg),
      toastDuration: Duration(seconds: duration),
      gravity: gravity,
    );
  }

  error({
    int duration = 3,
    required String msg,
  }) {
    fToast.removeCustomToast();
    fToast.removeQueuedCustomToasts();
    fToast.showToast(
      child: toast(Icons.error, Colors.red, msg),
      toastDuration: Duration(seconds: duration),
      gravity: ToastGravity.TOP,
    );
  }

  warning({
    int duration = 3,
    required String msg,
  }) {
    fToast.removeCustomToast();
    fToast.removeQueuedCustomToasts();
    fToast.showToast(
      child: toast(Icons.warning, Colors.amber, msg),
      toastDuration: Duration(seconds: duration),
      gravity: ToastGravity.TOP,
    );
  }
}
