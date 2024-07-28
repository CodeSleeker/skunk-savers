import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skunk_savers/models/payment.dart';

class Loan {
  double? amount;
  double? payable;
  Timestamp? timeStamp;
  double? balance;
  bool? paid;
  int? term;
  String? status;
  String? id;
  Payment? payment;
  List<Payment>? payments;

  Loan({
    this.amount,
    this.payable,
    this.timeStamp,
    this.balance,
    this.paid,
    this.term,
    this.status,
    this.id,
    this.payment,
    this.payments,
  });

  Loan.fromJson(Map<String, dynamic> json) {
    amount = double.parse(json['amount']);
    payable = double.parse(json['payable']);
    timeStamp = json['time_stamp'];
    balance = double.parse(json['balance']);
    paid = json['paid'];
    term = json['term'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount.toString();
    data['payable'] = payable.toString();
    data['time_stamp'] = timeStamp;
    data['balance'] = balance.toString();
    data['paid'] = paid;
    data['term'] = term;
    data['status'] = status;
    return data;
  }
}
