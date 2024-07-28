import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  double? amount;
  double? interest;
  String? status;
  Timestamp? timeStamp;
  String? id;
  Payment({
    this.amount,
    this.interest,
    this.status,
    this.timeStamp,
    this.id,
  });
  Payment.fromJson(Map<String, dynamic> json) {
    amount = double.parse(json['amount']);
    interest = double.parse(json['interest']);
    status = json['status'];
    timeStamp = json['time_stamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount.toString();
    data['interest'] = interest.toString();
    data['status'] = status;
    data['time_stamp'] = timeStamp;
    return data;
  }
}
