import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skunk_savers/controllers/interfaces/fund.dart';
import 'package:skunk_savers/models/loan.dart';
import 'package:skunk_savers/models/payment.dart';
import 'package:skunk_savers/models/response.dart';
import 'package:skunk_savers/models/saving.dart';
import 'package:skunk_savers/models/settings.dart';

class FundController implements IFundController {
  @override
  CollectionReference funds = FirebaseFirestore.instance.collection('funds');
  @override
  Future<SSCResponse> addSavings(String uid, Saving saving) async {
    try {
      var res = await funds.doc(uid).collection('savings').add(saving.toJson());
      return SSCResponse(success: true, docId: res.id);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCSettings> getSettings() async => await funds.doc('settings').get().then((value) {
        if (value.data() == null) {
          SSCSettings();
        }
        return SSCSettings.fromJson(value.data() as Map<String, dynamic>);
      }).catchError((e) {
        return SSCSettings();
      });

  @override
  Future<SSCResponse> updateSettings(SSCSettings sscSettings) async {
    try {
      await funds.doc('settings').update(sscSettings.toJson());
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<Saving> getSaving(String id, String uid) async {
    try {
      var res = await funds.doc(uid).collection('savings').doc(id).get();
      var saving = Saving.fromJson(res.data()!);
      saving.id = res.id;
      return saving;
    } on FirebaseException catch (e) {
      return Saving();
    }
  }

  @override
  Future<SSCResponse> updateSaving(String id, String uid, Map<String, dynamic> data) async {
    try {
      await funds.doc(uid).collection('savings').doc(id).update(data);
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> addUserTotalSavings(String uid, Map<String, dynamic> data) async {
    try {
      await funds.doc(uid).set(data, SetOptions(merge: true));
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> updateUserTotalFunds(String uid, Map<String, dynamic> data) async {
    try {
      await funds.doc(uid).set(data, SetOptions(merge: true));
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<double> getTotalSavings(String uid) async {
    try {
      var res = await funds.doc(uid).get();
      if (res.data() == null) {
        return 0;
      }
      var data = res.data() as Map<String, dynamic>;
      if (!data.containsKey('savings')) return 0;
      return double.parse((res.data() as Map<String, dynamic>)['savings']);
    } on FirebaseException catch (e) {
      return 0;
    }
  }

  @override
  Future<SSCResponse> updateAccounts(Map<String, dynamic> data) async {
    try {
      await funds.doc('total').set(data, SetOptions(merge: true));
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> addLoan(String uid, Loan loan) async {
    try {
      var res = await funds.doc(uid).collection('loans').add(loan.toJson());
      return SSCResponse(success: true, docId: res.id);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<Loan> getLoan(String uid, String id) async {
    try {
      var res = await funds.doc(uid).collection('loans').doc(id).get();
      var loan = Loan.fromJson(res.data()!);
      loan.id = res.id;
      return loan;
    } on FirebaseException catch (e) {
      return Loan();
    }
  }

  @override
  Future<SSCResponse> updateFund(String uid, String id, Map<String, dynamic> data, String fundName) async {
    try {
      await funds.doc(uid).collection(fundName).doc(id).set(data, SetOptions(merge: true));
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<SSCResponse> updatePayment(String uid, String loanId, String id, Map<String, dynamic> data) async {
    try {
      await funds.doc(uid).collection('loans').doc(loanId).collection('payments').doc(id).set(data, SetOptions(merge: true));
      return SSCResponse(success: true);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<double> getTotalLoans(String uid) async {
    try {
      var res = await funds.doc(uid).get();
      if (res.data() == null) {
        return 0;
      }
      var data = res.data() as Map<String, dynamic>;
      if (!data.containsKey('loans')) return 0;
      return double.parse((res.data() as Map<String, dynamic>)['loans']);
    } on FirebaseException catch (e) {
      return 0;
    }
  }

  @override
  Future<SSCResponse> addPayment(String uid, String id, Payment payment) async {
    try {
      var res = await funds.doc(uid).collection('loans').doc(id).collection('payments').add(payment.toJson());
      return SSCResponse(success: true, docId: res.id);
    } on FirebaseException catch (e) {
      return SSCResponse(success: false, errorMessage: e.code);
    }
  }

  @override
  Future<Payment> getPayment(String uid, String loanId, String id) async {
    try {
      var res = await funds.doc(uid).collection('loans').doc(loanId).collection('payments').doc(id).get();
      var payment = Payment.fromJson(res.data()!);
      payment.id = res.id;
      return payment;
    } on FirebaseException catch (e) {
      return Payment();
    }
  }

  @override
  Future<List<Saving>> getSavings(String uid) async {
    try {
      var res = await funds.doc(uid).collection('savings').get();
      return Saving.fromList(res.docs);
    } on FirebaseException catch (e) {
      return [];
    }
  }

  @override
  Future<double> getUserSavings(String uid) async {
    try {
      var res = await funds.doc(uid).collection('savings').get();
      double savings = 0;
      for (var doc in res.docs) {
        Saving saving = Saving.fromJson(doc.data());
        savings += saving.amount!;
      }
      return savings;
    } on FirebaseException catch (e) {
      return 0;
    }
  }
}
