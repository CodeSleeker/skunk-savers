import 'package:skunk_savers/controllers/fund.dart';
import 'package:skunk_savers/controllers/interfaces/fund.dart';
import 'package:skunk_savers/models/loan.dart';
import 'package:skunk_savers/models/payment.dart';
import 'package:skunk_savers/models/response.dart';
import 'package:skunk_savers/models/saving.dart';
import 'package:skunk_savers/models/settings.dart';
import 'package:skunk_savers/repositories/interfaces/fund.dart';

class FundRepository implements IFundRepository {
  IFundController fundController = FundController();
  @override
  Future<SSCResponse> addSavings(String uid, Saving saving) async {
    return await fundController.addSavings(uid, saving);
  }

  @override
  Future<SSCSettings> getSettings() async {
    return await fundController.getSettings();
  }

  @override
  Future<SSCResponse> updateSettings(SSCSettings sscSettings) async {
    return await fundController.updateSettings(sscSettings);
  }

  @override
  Future<Saving> getSaving(String id, String uid) async {
    return await fundController.getSaving(id, uid);
  }

  @override
  Future<SSCResponse> updateSaving(String id, String uid, Map<String, dynamic> data) async {
    return await fundController.updateSaving(id, uid, data);
  }

  @override
  Future<SSCResponse> addUserTotalSavings(String uid, Map<String, dynamic> data) async {
    return await fundController.addUserTotalSavings(uid, data);
  }

  @override
  Future<SSCResponse> updateUserTotalFunds(String uid, Map<String, dynamic> data) async {
    return await fundController.updateUserTotalFunds(uid, data);
  }

  @override
  Future<double> getTotalSavings(String uid) async {
    return await fundController.getTotalSavings(uid);
  }

  @override
  Future<SSCResponse> updateAccounts(Map<String, dynamic> data) async {
    return await fundController.updateAccounts(data);
  }

  @override
  Future<SSCResponse> addLoan(String uid, Loan loan) async {
    return await fundController.addLoan(uid, loan);
  }

  @override
  Future<Loan> getLoan(String uid, String id) async {
    return await fundController.getLoan(uid, id);
  }

  @override
  Future<SSCResponse> updateFund(String uid, String id, Map<String, dynamic> data, String fundName) async {
    return await fundController.updateFund(uid, id, data, fundName);
  }

  @override
  Future<double> getTotalLoans(String uid) async {
    return await fundController.getTotalLoans(uid);
  }

  @override
  Future<SSCResponse> addPayment(String uid, String id, Payment payment) async {
    return await fundController.addPayment(uid, id, payment);
  }

  @override
  Future<Payment> getPayment(String uid, String loanId, String id) async {
    return await fundController.getPayment(uid, loanId, id);
  }

  @override
  Future<SSCResponse> updatePayment(String uid, String loanId, String id, Map<String, dynamic> data) async {
    return await fundController.updatePayment(uid, loanId, id, data);
  }

  @override
  Future<List<Saving>> getSavings(String uid) async {
    return await fundController.getSavings(uid);
  }

  @override
  Future<double> getUserSavings(String uid) async {
    return fundController.getUserSavings(uid);
  }
}
