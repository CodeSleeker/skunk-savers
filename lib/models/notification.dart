import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skunk_savers/models/loan.dart';
import 'package:skunk_savers/models/saving.dart';
import 'package:skunk_savers/models/user.dart';

class SSCNotification {
  String? id;
  late String type;
  late String uid;
  late bool isOpened;
  late Timestamp timeStamp;
  String? loanId;
  String? title;
  String? message;
  String? docId;
  SSCUser? sscUser;
  Saving? saving;
  Loan? loan;
  String? sub;
  bool? buttonHidden;
  String? name;
  Timestamp? modified;
  SSCNotification({
    this.id,
    required this.type,
    required this.uid,
    required this.isOpened,
    required this.timeStamp,
    this.title,
    this.message,
    this.sscUser,
    this.saving,
    this.docId,
    this.loan,
    this.sub,
    this.buttonHidden,
    this.loanId,
    this.name,
    this.modified,
  });
  SSCNotification.fromJson(Map<String, dynamic> json) {
    docId = json['doc_id'];
    type = json['type'];
    uid = json['uid'];
    loanId = json['loan_id'];
    isOpened = json['is_opened'];
    timeStamp = json['time_stamp'];
    title = json['title'];
    sub = json['sub'];
    message = json['message'];
    name = json['name'];
    modified = json['modified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['doc_id'] = docId;
    data['type'] = type;
    data['uid'] = uid;
    data['is_opened'] = isOpened;
    data['time_stamp'] = timeStamp;
    data['loan_id'] = loanId;
    data['title'] = title;
    data['sub'] = sub;
    data['message'] = message;
    data['name'] = name;
    data['modified'] = modified;
    return data;
  }
}
