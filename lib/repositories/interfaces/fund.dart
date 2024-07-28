import 'package:skunk_savers/models/loan.dart';
import 'package:skunk_savers/models/payment.dart';
import 'package:skunk_savers/models/response.dart';
import 'package:skunk_savers/models/saving.dart';
import 'package:skunk_savers/models/settings.dart';

abstract class IFundRepository {
  Future<SSCResponse> addSavings(String uid, Saving saving);
  Future<SSCSettings> getSettings();
  Future<SSCResponse> updateSettings(SSCSettings sscSettings);
  Future<Saving> getSaving(String id, String uid);
  Future<SSCResponse> updateSaving(String id, String uid, Map<String, dynamic> data);
  Future<SSCResponse> addUserTotalSavings(String uid, Map<String, dynamic> data);
  Future<SSCResponse> updateUserTotalFunds(String uid, Map<String, dynamic> data);
  Future<double> getTotalSavings(String uid);
  Future<double> getTotalLoans(String uid);
  Future<SSCResponse> updateAccounts(Map<String, dynamic> data);
  Future<SSCResponse> addLoan(String uid, Loan loan);
  Future<Loan> getLoan(String uid, String id);
  Future<SSCResponse> updateFund(String uid, String id, Map<String, dynamic> data, String fundName);
  Future<SSCResponse> addPayment(String uid, String id, Payment payment);
  Future<Payment> getPayment(String uid, String loanId, String id);
  Future<SSCResponse> updatePayment(String uid, String loanId, String id, Map<String, dynamic> data);
  Future<List<Saving>> getSavings(String uid);
  Future<double> getUserSavings(String uid);
}
