import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skunk_savers/models/fund.dart';
import 'package:skunk_savers/models/loan.dart';
import 'package:skunk_savers/models/payment.dart';
import 'package:skunk_savers/models/saving.dart';

class HomeVM extends ChangeNotifier {
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  Fund fund = Fund();
  double savings = 0;
  bool hasPendingLoanApplication = false;
  bool hasApprovedLoanApplication = false;
  bool hasPendingSavingsDeposit = false;
  Loan? loan;

  late StreamSubscription savingsSubscription;
  late StreamSubscription loansSubscription;

  stopListening() async {
    savings = 0;
    loan = null;
    fund = Fund();
    hasApprovedLoanApplication = false;
    hasPendingSavingsDeposit = false;
    hasPendingLoanApplication = false;
    savingsSubscription.cancel();
    loansSubscription.cancel();
  }

  listenSavings(String uid) {
    var reference = firestoreInstance.collection('funds').doc(uid).collection('savings');
    savingsSubscription = reference.snapshots().listen((event) {
      for (var snapshot in event.docChanges) {
        Saving saving = Saving.fromJson(snapshot.doc.data()!);
        saving.id = snapshot.doc.id;
        switch (snapshot.type) {
          case DocumentChangeType.added:
            fund.savings ??= [];
            fund.savings!.add(saving);
            if (saving.status == 'approved') {
              savings += saving.amount!;
            } else {
              hasPendingSavingsDeposit = true;
            }
            break;
          case DocumentChangeType.modified:
            int index = fund.savings!.indexWhere((element) => element.id == saving.id);
            if (index >= 0) {
              fund.savings![index] = saving;
              if (saving.status == 'approved') {
                savings += saving.amount!;
                hasPendingSavingsDeposit = false;
              }
            }
            break;
          case DocumentChangeType.removed:
            int index = fund.savings!.indexWhere((element) => element.id == saving.id);
            if (index >= 0) {
              fund.savings!.removeAt(index);
              savings -= saving.amount!;
            }
            break;
          default:
            break;
        }
      }
      notifyListeners();
    });
  }

  listenLoans(String uid) {
    var reference = firestoreInstance.collection('funds').doc(uid).collection('loans');
    loansSubscription = reference.snapshots().listen((event) async {
      for (var snapshot in event.docChanges) {
        Loan loan = Loan.fromJson(snapshot.doc.data()!);
        loan.id = snapshot.doc.id;
        switch (snapshot.type) {
          case DocumentChangeType.added:
            fund.loans ??= [];
            fund.loans!.add(loan);
            if (loan.status == 'pending' || loan.status == 'pre_approved') {
              hasPendingLoanApplication = true;
              this.loan = loan;
            }
            if (!loan.paid! && loan.status == 'approved') {
              hasApprovedLoanApplication = true;
              this.loan = loan;
            }
            if (this.loan != null) {
              var paymentCollection = await reference.doc(loan.id).collection('payments').get();
              for (var paymentData in paymentCollection.docs) {
                Payment payment = Payment.fromJson(paymentData.data());
                payment.id = paymentData.id;
                loan.payments ??= [];
                loan.payments!.add(payment);
                if (payment.status != 'approved') {
                  this.loan!.payment = payment;
                }
                // if (payment.status == 'approved') {
                //   this.profits += payment.interest!;
                // }
              }
            }
            break;
          case DocumentChangeType.modified:
            int index = fund.loans!.indexWhere((element) => element.id == loan.id);
            if (index >= 0) {
              fund.loans![index] = loan;
              if (loan.status == 'pending' || loan.status == 'pre_approved') {
                hasPendingLoanApplication = true;
                this.loan = loan;
              }
              if (!loan.paid! && loan.status == 'approved') {
                hasApprovedLoanApplication = true;
                this.loan = loan;
              }
              if (this.loan != null) {
                var paymentCollection = await reference.doc(loan.id).collection('payments').get();
                for (var paymentData in paymentCollection.docs) {
                  Payment payment = Payment.fromJson(paymentData.data());
                  payment.id = paymentData.id;
                  loan.payments ??= [];
                  loan.payments!.add(payment);
                  if (payment.status != 'approved') {
                    this.loan!.payment = payment;
                  }
                  // if (payment.status == 'approved') {
                  //   this.profits += payment.interest!;
                  // }
                }
              }
            }
            break;
          case DocumentChangeType.removed:
            int index = fund.loans!.indexWhere((element) => element.id == loan.id);
            if (index >= 0) fund.loans!.removeAt(index);
            break;
          default:
            break;
        }
      }
      notifyListeners();
    });
  }
}
