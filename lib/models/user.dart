import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skunk_savers/models/loan.dart';
import 'package:skunk_savers/models/saving.dart';

class SSCUser {
  Timestamp? timestamp;
  String? firstname;
  String? lastname;
  String? email;
  String? mobile;
  String? uid;
  String? role;
  bool isActive;
  List<Loan>? loans = [];
  List<Saving>? savings = [];
  bool passwordUpdated = false;
  int? sequenceNumber;
  double? totalSavings;
  double? totalLoans;
  Loan? loan;
  double? profits;
  double? payments;
  double? percentShare;
  String? token;
  SSCUser({
    this.email,
    this.uid,
    this.firstname,
    this.lastname,
    this.mobile,
    this.role,
    this.isActive = false,
    this.loans,
    this.savings,
    this.passwordUpdated = false,
    this.sequenceNumber,
    this.totalSavings,
    this.totalLoans,
    this.profits,
    this.loan,
    this.payments,
    this.timestamp,
    this.percentShare,
    this.token,
  });
  Map<String, dynamic> toJson() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'mobile': mobile,
      'uid': uid,
      'role': role,
      'is_active': isActive,
      'password_updated': passwordUpdated,
      'sequence_number': sequenceNumber,
      'timestamp': timestamp,
      'percent_share': percentShare,
    };
  }

  static isEmpty(SSCUser sscUser) {
    return sscUser.email == null ||
        sscUser.email == '' ||
        sscUser.firstname == null ||
        sscUser.firstname == '' ||
        sscUser.lastname == null ||
        sscUser.lastname == '' ||
        sscUser.mobile == null ||
        sscUser.role == null ||
        sscUser.role == '' ||
        sscUser.mobile == '';
  }

  factory SSCUser.fromJson(Map<String, dynamic> userJson) => SSCUser(
        firstname: userJson['firstname'],
        lastname: userJson['lastname'],
        email: userJson['email'],
        mobile: userJson['mobile'],
        uid: userJson['uid'],
        role: userJson['role'],
        isActive: userJson['is_active'],
        passwordUpdated: userJson['password_updated'],
        sequenceNumber: userJson['sequence_number'],
        timestamp: userJson['timestamp'],
        percentShare:
            userJson['percent_share'] == null ? 0 : userJson['percent_share'],
        token: userJson['token'],
      );
}
