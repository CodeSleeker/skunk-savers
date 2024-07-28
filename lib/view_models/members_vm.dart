import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skunk_savers/models/account.dart';
import 'package:skunk_savers/models/loan.dart';
import 'package:skunk_savers/models/saving.dart';
import 'package:skunk_savers/models/settings.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/repositories/interfaces/user.dart';
import 'package:skunk_savers/repositories/user.dart';

class MembersVM extends ChangeNotifier {
  List<SSCUser> sscUsers = [];
  IUserRepository userRepository = UserRepository();
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  bool listening = false;
  SSCUser currentUser = SSCUser();
  SSCAccount sscAccount = SSCAccount();
  List<SSCUser> cashManagers = [];
  List<SSCUser> admins = [];

  late StreamSubscription totalFundSubscription;
  late StreamSubscription usersSubscription;
  late StreamSubscription savingsSubscription;
  late StreamSubscription loansSubscription;

  Future stopListening() async {
    totalFundSubscription.cancel();
    usersSubscription.cancel();
    savingsSubscription.cancel();
    loansSubscription.cancel();
  }

  listLatestData(SSCUser currentUser) {
    if (!listening) {
      listening = true;
      listenUsers(currentUser);
      listenFunds();
    }
  }

  listenFunds() {
    var reference = firestoreInstance.collection('funds').doc('total');
    totalFundSubscription = reference.snapshots().listen((querySnapshot) {
      if (querySnapshot.data()!.isNotEmpty) {
        sscAccount = SSCAccount.fromJson(querySnapshot.data()!);
        notifyListeners();
      }
    });
  }

  listenUsers(SSCUser currentUser) {
    var reference = firestoreInstance.collection('users');
    usersSubscription = reference.snapshots().listen((querySnapshot) async {
      for (var snapshot in querySnapshot.docChanges) {
        SSCUser sscUser = SSCUser.fromJson(snapshot.doc.data()!);
        switch (snapshot.type) {
          case DocumentChangeType.added:
            if (sscUser.role == 'admin') {
              admins.add(sscUser);
            } else if (sscUser.role == 'cash_manager') {
              cashManagers.add(sscUser);
            }
            sscUsers.add(sscUser);
            break;
          case DocumentChangeType.modified:
            int index = sscUsers.indexWhere((element) => sscUser.uid == element.uid);
            sscUsers[index] = sscUser;
            int adminIndex = admins.indexWhere((element) => element.uid == sscUser.uid);
            if (adminIndex >= 0) {
              admins[adminIndex] = sscUser;
            }
            int caIndex = cashManagers.indexWhere((element) => element.uid == sscUser.uid);
            if (caIndex >= 0) {
              cashManagers[caIndex] = sscUser;
            }
            break;
          case DocumentChangeType.removed:
            int index = sscUsers.indexWhere((element) => sscUser.uid == element.uid);
            sscUsers.removeAt(index);
            int adminIndex = admins.indexWhere((element) => element.uid == sscUser.uid);
            if (adminIndex >= 0) {
              sscUsers.removeAt(adminIndex);
            }
            int caIndex = cashManagers.indexWhere((element) => element.uid == sscUser.uid);
            if (caIndex >= 0) {
              sscUsers.removeAt(caIndex);
            }
            break;
          default:
            break;
        }
        if (sscUser.uid == currentUser.uid) {
          currentUser = sscUser;
        }
      }
      notifyListeners();
      for (var sscUser in sscUsers) {
        sscUser.savings = [];
        sscUser.loans = [];
        listenSavings(sscUser);
        listenLoans(sscUser);
      }
    });
  }

  listenLoans(SSCUser sscUser) {
    var reference = firestoreInstance.collection('funds').doc(sscUser.uid).collection('loans');
    loansSubscription = reference.snapshots().listen((querySnapshot) async {
      for (var snapshot in querySnapshot.docChanges) {
        Loan loan = Loan.fromJson(snapshot.doc.data()!);
        loan.id = snapshot.doc.id;
        switch (snapshot.type) {
          case DocumentChangeType.added:
            sscUser.loans!.add(loan);
            break;
          case DocumentChangeType.modified:
            int index = sscUser.loans!.indexWhere((element) => element.id == snapshot.doc.id);
            sscUser.loans![index] = loan;
            break;
          case DocumentChangeType.removed:
            int index = sscUser.loans!.indexWhere((element) => element.id == snapshot.doc.id);
            sscUser.loans!.removeAt(index);
            break;
          default:
            break;
        }
      }
    });
  }

  listenSavings(SSCUser sscUser) {
    var reference = firestoreInstance.collection('funds').doc(sscUser.uid).collection('savings');
    savingsSubscription = reference.snapshots().listen((querySnapshot) async {
      for (var snapshot in querySnapshot.docChanges) {
        Saving saving = Saving.fromJson(snapshot.doc.data()!);
        saving.id = snapshot.doc.id;
        switch (snapshot.type) {
          case DocumentChangeType.added:
            sscUser.savings!.add(saving);
            break;
          case DocumentChangeType.modified:
            int index = sscUser.savings!.indexWhere((element) => element.id == snapshot.doc.id);
            sscUser.savings![index] = saving;
            break;
          case DocumentChangeType.removed:
            int index = sscUser.savings!.indexWhere((element) => element.id == snapshot.doc.id);
            sscUser.savings!.removeAt(index);
            break;
          default:
            break;
        }
      }
      notifyListeners();
    });
  }
}
