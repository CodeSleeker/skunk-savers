import 'package:cloud_firestore/cloud_firestore.dart';

class Saving {
  double? amount;
  Timestamp? date;
  String? status;
  String? id;

  Saving({
    this.amount,
    this.date,
    this.status,
    this.id,
  });

  Saving.fromJson(Map<String, dynamic> json) {
    amount = double.parse(json['amount']);
    date = json['date'];
    status = json['status'];
  }

  static List<Saving> fromList(List<dynamic> list) {
    List<Saving> savings = [];
    list.forEach((element) {
      Saving saving = Saving.fromJson(element.data());
      saving.id = element.id;
      savings.add(saving);
    });
    return savings;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount.toString();
    data['date'] = date;
    data['status'] = status;
    return data;
  }
}
