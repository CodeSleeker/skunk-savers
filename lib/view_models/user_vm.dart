import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:skunk_savers/models/push_notification.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/repositories/fund.dart';
import 'package:skunk_savers/repositories/interfaces/fund.dart';
import 'package:skunk_savers/repositories/interfaces/user.dart';
import 'package:skunk_savers/repositories/user.dart';

class UserVM extends ChangeNotifier {
  // NumberFormat numberFormat = NumberFormat.simpleCurrency(locale: Platform.localeName, name: 'PHP');
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  late NotificationSettings settings;
  RemoteMessage? remoteMessage;

  SSCUser currentUser = SSCUser();
  List<SSCUser> users = [];
  List<SSCUser> admins = [];
  List<SSCUser> cashManagers = [];
  IUserRepository userRepository = UserRepository();
  IFundRepository fundRepository = FundRepository();
  // IFundRepository fundRepository = FundRepository();
  // IMessageRepository messageRepository = MessageRepository();
  //
  bool listening = false;
  // double savings = 0;
  // double availableCash = 0;
  // SSCSettings sscSettings = SSCSettings();
  // List<SSCNotification> notifications = [];
  // bool hasMemberBadge = false;
  // bool hasMessageBadge = false;
  // bool hasChatBadge = false;
  // bool hasNotificationBadge = false;

  // late StreamSubscription notificationSubscription;
  // late StreamSubscription fundSubscription;
  // late StreamSubscription settingsSubscription;
  // late StreamSubscription userSavingsSubscription;
  // late StreamSubscription userLoansSubscription;
  // StreamSubscription? loanPaymentSubscription;
  late StreamSubscription usersSubscription;

  Future setUser(String uid) async {
    currentUser = await userRepository.getUserDetails(uid);
    String? token = await messaging.getToken();
    print(token);
    await userRepository.saveFCMToken(uid, token!);
    // currentUser.savings = await fundRepository.getSavings(uid);
    listenUsers();
    // currentUser.totalSavings = 0;
    // currentUser.totalLoans = 0;
    // currentUser.profits = 0;
    // currentUser.savings = [];
    // currentUser.loans = [];
    // await listenSettings();
    // listenFunds();
    // listenUserSavings();
    // listenUserLoans();
    // listenNotifications();
    // notifyListeners();
    // registerNotification();
  }

  stopListening() async {
    users = [];
    admins = [];
    cashManagers = [];
    usersSubscription.cancel();
  }

  listenUsers() {
    if (listening) return;
    listening = true;
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
            users.add(sscUser);
            break;
          case DocumentChangeType.modified:
            int index = users.indexWhere((element) => sscUser.uid == element.uid);
            users[index] = sscUser;
            int adminIndex = admins.indexWhere((element) => element.uid == sscUser.uid);
            if (adminIndex >= 0) {
              admins[adminIndex] = sscUser;
            }
            int caIndex = cashManagers.indexWhere((element) => element.uid == sscUser.uid);
            if (caIndex >= 0) {
              cashManagers[caIndex] = sscUser;
            }
            if (currentUser.uid == sscUser.uid) {
              currentUser = await userRepository.getUserDetails(currentUser.uid!);
            }
            break;
          case DocumentChangeType.removed:
            int index = users.indexWhere((element) => sscUser.uid == element.uid);
            users.removeAt(index);
            int adminIndex = admins.indexWhere((element) => element.uid == sscUser.uid);
            if (adminIndex >= 0) {
              users.removeAt(adminIndex);
            }
            int caIndex = cashManagers.indexWhere((element) => element.uid == sscUser.uid);
            if (caIndex >= 0) {
              users.removeAt(caIndex);
            }
            break;
          default:
            break;
        }
      }
      notifyListeners();
    });
  }

  // Future stopListening() async {
  //   notifications = [];
  //   savings = 0;
  //   notificationSubscription.cancel();
  //   fundSubscription.cancel();
  //   settingsSubscription.cancel();
  //   userSavingsSubscription.cancel();
  //   userLoansSubscription.cancel();
  //   if (loanPaymentSubscription != null) loanPaymentSubscription!.cancel();
  // }
  //
  // checkType(SSCNotification notification, String name) async {
  //   if (notification.type == 'approved_loan') {
  //     notification.message = 'Your loan is now credited to your account';
  //     notification.title = 'Loan Approved';
  //     notification.sub = '';
  //     notification.buttonHidden = true;
  //   }
  //   if (notification.type == 'approved_deposit') {
  //     notification.message = 'Your account is now updated';
  //     notification.title = 'Approved Deposit';
  //     notification.sub = '';
  //     notification.buttonHidden = true;
  //   }
  //   if (notification.type == 'request_deposit') {
  //     Saving saving = await fundRepository.getSaving(notification.docId!, notification.uid);
  //     saving.id = notification.docId;
  //     notification.title = 'Request Deposit';
  //     notification.sub = saving.status == 'pre_approved' ? '(Pre Approved)' : '';
  //     notification.saving = saving;
  //     if (notification.isOpened) {
  //       notification.buttonHidden = true;
  //       if (saving.status == 'approved') {
  //         notification.message = 'This request is already approved';
  //       } else {
  //         notification.message = 'This request is already pre approved';
  //       }
  //     } else {
  //       notification.buttonHidden = false;
  //       notification.message = '$name want to deposit the amount of ${numberFormat.format(saving.amount)}';
  //     }
  //   }
  //   if (notification.type == 'pay_loan') {
  //     Loan loan = await fundRepository.getLoan(notification.uid, notification.loanId!);
  //     loan.payment = await fundRepository.getPayment(notification.uid, notification.loanId!, notification.docId!);
  //     notification.title = 'Loan Payment';
  //     notification.sub = loan.payment!.status == 'pre_approved' ? '(Pre Approved)' : '';
  //     notification.loan = loan;
  //     if (notification.isOpened) {
  //       notification.buttonHidden = true;
  //       if (loan.payment!.status == 'approved') {
  //         notification.message = 'This request is already approved';
  //       } else {
  //         notification.message = 'This request is already pre approved';
  //       }
  //     } else {
  //       notification.buttonHidden = false;
  //       notification.message = '$name want to pay the loan amount of ${numberFormat.format(loan.payment!.amount! + loan.payment!.interest!)}';
  //     }
  //   }
  //   if (notification.type == 'apply_loan') {
  //     Loan loan = await fundRepository.getLoan(notification.uid, notification.docId!);
  //     loan.id = notification.docId;
  //     notification.title = 'Loan Application';
  //     notification.sub = loan.status == 'pre_approved' ? '(Pre Approved)' : '';
  //     notification.loan = loan;
  //     if (notification.isOpened) {
  //       notification.buttonHidden = true;
  //       if (loan.status == 'approved') {
  //         notification.message = 'This request is already approved';
  //       } else {
  //         notification.message = 'This request is already pre approved';
  //       }
  //     } else {
  //       notification.buttonHidden = false;
  //       notification.message = '$name want to apply for a loan amounting to ${numberFormat.format(loan.amount)}';
  //     }
  //   }
  //   return notification;
  // }
  //
  // listenNotifications() {
  //   var reference = firestoreInstance.collection('messages').doc(currentUser.uid).collection('notification').orderBy('time_stamp');
  //   notificationSubscription = reference.snapshots().listen((querySnapshot) async {
  //     for (var snapshot in querySnapshot.docChanges) {
  //       SSCNotification notification = SSCNotification.fromJson(snapshot.doc.data()!);
  //       notification.id = snapshot.doc.id;
  //       switch (snapshot.type) {
  //         case DocumentChangeType.added:
  //           SSCUser sscUser = await userRepository.getUserDetails(notification.uid);
  //           sscUser.totalSavings = await fundRepository.getTotalSavings(sscUser.uid!);
  //           sscUser.totalLoans = await fundRepository.getTotalLoans(sscUser.uid!);
  //           notification = await checkType(notification, '${sscUser.firstname} ${sscUser.lastname}');
  //           notification.sscUser = sscUser;
  //           notifications.insert(0, notification);
  //           checkNotificationBadge();
  //           break;
  //         case DocumentChangeType.modified:
  //           int index = notifications.indexWhere((element) => element.id == notification.id);
  //           var sscUser = notifications[index].sscUser;
  //           notification = await checkType(notification, '${notifications[index].sscUser!.firstname} ${notifications[index].sscUser!.lastname}');
  //           notifications[index] = notification;
  //           notifications[index].sscUser = sscUser;
  //           notifyListeners();
  //           checkNotificationBadge();
  //           break;
  //         case DocumentChangeType.removed:
  //           int index = notifications.indexWhere((element) => element.id == notification.id);
  //           notifications.removeAt(index);
  //           checkNotificationBadge();
  //           break;
  //         default:
  //           break;
  //       }
  //     }
  //     notifyListeners();
  //   });
  // }
  //
  // checkNotificationBadge() async {
  //   hasChatBadge = false;
  //   hasMemberBadge = false;
  //   hasMessageBadge = false;
  //   hasNotificationBadge = false;
  //   if (notifications.isNotEmpty) {
  //     for (var notification in notifications) {
  //       if (notification.type == 'pay_loan' && !notification.isOpened) {
  //         hasMemberBadge = true;
  //         hasNotificationBadge = true;
  //         hasMessageBadge = true;
  //       }
  //       if ((notification.type == 'approved_deposit' || notification.type == 'approved_loan') && !notification.isOpened) {
  //         hasMessageBadge = true;
  //         hasNotificationBadge = true;
  //       }
  //       if (notification.type == 'apply_loan' && !notification.isOpened) {
  //         if (notification.loan!.status == 'approved' && currentUser.role == 'cash_manager') {
  //           await messageRepository.updateNotification(currentUser.uid!, notification.id!, {'is_opened': true});
  //         }
  //         if (notification.loan!.status == 'pending') {
  //           hasMemberBadge = true;
  //           hasNotificationBadge = true;
  //           hasMessageBadge = true;
  //         } else {
  //           if (notification.loan!.status == 'pre_approved' && currentUser.role == 'admin') {
  //             hasMemberBadge = true;
  //             hasNotificationBadge = true;
  //             hasMessageBadge = true;
  //           }
  //         }
  //         notifyListeners();
  //       }
  //       if (notification.type == 'request_deposit' && !notification.isOpened) {
  //         if (notification.saving!.status == 'approved' && currentUser.role == 'cash_manager') {
  //           await messageRepository.updateNotification(currentUser.uid!, notification.id!, {'is_opened': true});
  //         }
  //         if (notification.saving!.status == 'pending') {
  //           hasMemberBadge = true;
  //           hasNotificationBadge = true;
  //           hasMessageBadge = true;
  //         } else {
  //           if (notification.saving!.status == 'pre_approved' && currentUser.role == 'admin') {
  //             hasMemberBadge = true;
  //             hasNotificationBadge = true;
  //             hasMessageBadge = true;
  //           }
  //         }
  //         notifyListeners();
  //       }
  //     }
  //   }
  // }
  //
  // listenSettings() async {
  //   var reference = firestoreInstance.collection('funds').doc('settings');
  //   settingsSubscription = reference.snapshots().listen((querySnapshot) {
  //     sscSettings = SSCSettings.fromJson(querySnapshot.data()!);
  //     notifyListeners();
  //   });
  // }
  //
  // listenFunds() {
  //   var reference = firestoreInstance.collection('funds').doc(currentUser.uid);
  //   fundSubscription = reference.snapshots().listen((querySnapshot) {
  //     if (querySnapshot.data() != null) {
  //       if (querySnapshot.data()!.containsKey('savings')) {
  //         currentUser.totalSavings = double.tryParse(querySnapshot.data()!['savings'])!;
  //       }
  //       if (querySnapshot.data()!.containsKey('loans')) {
  //         currentUser.totalLoans = double.tryParse(querySnapshot.data()!['loans'])!;
  //       }
  //       if (querySnapshot.data()!.containsKey('profits')) {
  //         currentUser.profits = double.tryParse(querySnapshot.data()!['profits'])!;
  //       }
  //       if (querySnapshot.data()!.containsKey('payments')) {
  //         currentUser.payments = double.tryParse(querySnapshot.data()!['payments'])!;
  //       }
  //       notifyListeners();
  //     }
  //   });
  // }
  //
  // listenLoanPayment(String id) {
  //   var reference = firestoreInstance.collection('funds').doc(currentUser.uid).collection('loans').doc(id).collection('payments');
  //   loanPaymentSubscription = reference.snapshots().listen((querySnapshot) {
  //     for (var snapshot in querySnapshot.docChanges) {
  //       Payment payment = Payment.fromJson(snapshot.doc.data()!);
  //       switch (snapshot.type) {
  //         case DocumentChangeType.added:
  //           if (payment.status == 'pending' || payment.status == 'pre_approved') {
  //             currentUser.loan!.payment = payment;
  //           }
  //           break;
  //         case DocumentChangeType.modified:
  //           if (payment.status == 'pending' || payment.status == 'pre_approved') {
  //             currentUser.loan!.payment = payment;
  //           } else {
  //             currentUser.loan!.payment = null;
  //           }
  //           break;
  //         case DocumentChangeType.removed:
  //           if (snapshot.doc.id == currentUser.loan!.payment!.id) {
  //             currentUser.loan!.payment = null;
  //           }
  //           break;
  //         default:
  //           break;
  //       }
  //     }
  //     notifyListeners();
  //   });
  // }
  //
  // listenUserLoans() {
  //   var reference = firestoreInstance.collection('funds').doc(currentUser.uid).collection('loans');
  //   userLoansSubscription = reference.snapshots().listen((querySnapshot) {
  //     for (var snapshot in querySnapshot.docChanges) {
  //       Loan loan = Loan.fromJson(snapshot.doc.data()!);
  //       loan.id = snapshot.doc.id;
  //       switch (snapshot.type) {
  //         case DocumentChangeType.added:
  //           if (!loan.paid!) {
  //             currentUser.loan = loan;
  //             listenLoanPayment(snapshot.doc.id);
  //           }
  //           currentUser.loans!.add(loan);
  //           break;
  //         case DocumentChangeType.modified:
  //           int index = currentUser.loans!.indexWhere((element) => element.id == snapshot.doc.id);
  //           if (currentUser.loan!.id == snapshot.doc.id) {
  //             currentUser.loan = loan;
  //           }
  //           currentUser.loans![index] = loan;
  //           updateNotificationLoans(loan);
  //           break;
  //         case DocumentChangeType.removed:
  //           int index = currentUser.loans!.indexWhere((element) => element.id == snapshot.doc.id);
  //           currentUser.loans!.removeAt(index);
  //           break;
  //         default:
  //           break;
  //       }
  //     }
  //     notifyListeners();
  //   });
  // }
  //
  // updateNotificationLoans(Loan loan) {
  //   for (var notification in notifications) {
  //     if (notification.loan != null && notification.loan!.id == loan.id) {
  //       notification.loan = loan;
  //     }
  //   }
  // }
  //
  // listenUserSavings() {
  //   var reference = firestoreInstance.collection('funds').doc(currentUser.uid).collection('savings');
  //   userSavingsSubscription = reference.snapshots().listen((querySnapshot) {
  //     for (var snapshot in querySnapshot.docChanges) {
  //       Saving saving = Saving.fromJson(snapshot.doc.data()!);
  //       saving.id = snapshot.doc.id;
  //       switch (snapshot.type) {
  //         case DocumentChangeType.added:
  //           currentUser.savings!.add(saving);
  //           notifyListeners();
  //           break;
  //         case DocumentChangeType.modified:
  //           int index = currentUser.savings!.indexWhere((element) => element.id == snapshot.doc.id);
  //           currentUser.savings![index] = saving;
  //           updateNotificationSavings(saving);
  //           break;
  //         case DocumentChangeType.removed:
  //           int index = currentUser.savings!.indexWhere((element) => element.id == snapshot.doc.id);
  //           currentUser.savings!.removeAt(index);
  //           notifyListeners();
  //           break;
  //         default:
  //           break;
  //       }
  //     }
  //     // getSavings();
  //   });
  // }
  //
  // updateNotificationSavings(Saving saving) {
  //   for (var notification in notifications) {
  //     if (notification.saving!.id == saving.id) {
  //       notification.saving = saving;
  //     }
  //   }
  //   notifyListeners();
  // }

  // getSavings() {
  //   savings = 0;
  //   for (var saving in currentUser.savings!) {
  //     if (saving.status == 'approved') {
  //       savings += saving.amount!;
  //     }
  //   }
  //   notifyListeners();
  // }
}
