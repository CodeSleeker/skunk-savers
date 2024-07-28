import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skunk_savers/models/notification.dart';
import 'package:skunk_savers/models/peer.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/repositories/fund.dart';
import 'package:skunk_savers/repositories/interfaces/fund.dart';
import 'package:skunk_savers/repositories/interfaces/user.dart';
import 'package:skunk_savers/repositories/user.dart';

class MessageVM extends ChangeNotifier {
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  NumberFormat numberFormat = NumberFormat.simpleCurrency(locale: Platform.localeName, name: 'PHP');
  IUserRepository userRepository = UserRepository();
  IFundRepository fundRepository = FundRepository();
  List<SSCNotification> notifications = [];
  bool hasMemberBadge = false;
  bool hasMessageBadge = false;
  bool hasNotificationBadge = false;
  bool hasChatBadge = false;
  SSCUser user = SSCUser();
  List<Peer> peers = [];

  late StreamSubscription notificationsSubscription;
  late StreamSubscription peersSubscription;

  Stream<QuerySnapshot> getChats(String peerId) {
    return firestoreInstance.collection('messages').doc(user.uid).collection('chats').doc(peerId).collection('messages').orderBy('created_at', descending: true).snapshots();
  }

  listenPeers(String uid) {
    var reference = firestoreInstance.collection('messages').doc(uid).collection('chats');
    peersSubscription = reference.snapshots().listen((event) async {
      peers = Peer.fromList(event.docs);
      for (var peer in peers) {
        peer.user = await userRepository.getUserDetails(peer.uid!);
        var res = await firestoreInstance.collection('messages').doc(uid).collection('chats').doc(peer.uid).collection('messages').orderBy('created_at', descending: true).get();
        String peek = res.docs[0].data()['content'];
        if (peek.length > 20) {
          peer.peek = '${peek.substring(0, 20)}...';
        } else {
          peer.peek = peek;
        }
      }
      hasChatBadge = peers.any((element) => element.hasNewMessage!);
      notifyListeners();
    });
  }

  stopListening() async {
    notifications = [];
    notificationsSubscription.cancel();
    peersSubscription.cancel();
  }

  listenNotifications(SSCUser user) {
    this.user = user;
    var reference = firestoreInstance.collection('messages').doc(user.uid).collection('notifications').orderBy('time_stamp');
    notificationsSubscription = reference.snapshots().listen((event) async {
      for (var snapshot in event.docChanges) {
        SSCNotification notification = SSCNotification.fromJson(snapshot.doc.data()!);
        notification.id = snapshot.doc.id;
        switch (snapshot.type) {
          case DocumentChangeType.added:
            notification.sscUser = await userRepository.getUserDetails(notification.uid);
            notification.sub = '';
            notification = await updateNotification(notification);
            notifications.insert(0, notification);
            checkBadge();
            break;
          case DocumentChangeType.modified:
            int index = notifications.indexWhere((element) => element.id == notification.id);
            notification.sub = '';
            if (index >= 0) {
              notification.sscUser = notifications[index].sscUser;
              notifications[index] = notification;
              notification = await updateNotification(notification);
              checkBadge();
            }
            break;
          case DocumentChangeType.removed:
            int index = notifications.indexWhere((element) => element.id == notification.id);
            if (index >= 0) notifications.removeAt(index);
            checkBadge();
            break;
          default:
            break;
        }
        notifyListeners();
      }
    });
  }

  updateNotification(SSCNotification notification) async {
    String name = 'You';
    if (user.firstname != notification.sscUser!.firstname && user.lastname != notification.sscUser!.lastname) {
      name = '${notification.sscUser!.firstname} ${notification.sscUser!.lastname}';
    }
    if (notification.type == 'approved_payment') {
      notification.title = 'Payment Approved';
      notification.message = 'Your loan payment has been approved';
      notification.buttonHidden = true;
      notification.name = name;
    }
    if (notification.type == 'approved_deposit') {
      notification.title = 'Deposit Approved';
      notification.message = 'Your account is now updated';
      notification.buttonHidden = true;
      notification.name = name;
    }
    if (notification.type == 'approved_loan') {
      notification.title = 'Loan Approved';
      notification.message = 'Your loan is now credited to your account';
      notification.buttonHidden = true;
      notification.name = name;
    }
    if (notification.type == 'apply_loan') {
      notification.loan = await fundRepository.getLoan(notification.uid, notification.docId!);
      notification.title = 'Loan Application';
      notification.name = name;
      if (notification.loan!.status == 'approved') {
        notification.message = 'Request has been approved';
        notification.buttonHidden = true;
      } else if (notification.loan!.status == 'pre_approved') {
        if (user.role == 'admin') {
          notification.buttonHidden = false;
          notification.message = '$name want to loan the amount of ${numberFormat.format(notification.loan!.amount)}';
        } else {
          notification.message = 'Request has been pre approved';
          notification.buttonHidden = true;
        }
        notification.sub = '(Pre Approved)';
      } else {
        notification.buttonHidden = false;
        notification.message = '$name want to loan the amount of ${numberFormat.format(notification.loan!.amount)}';
      }
    }
    if (notification.type == 'request_deposit') {
      notification.saving = await fundRepository.getSaving(notification.docId!, notification.uid);
      notification.title = 'Request Deposit';
      notification.name = name;
      if (notification.saving!.status == 'approved') {
        notification.message = 'Request has been approved';
        notification.buttonHidden = true;
      } else if (notification.saving!.status == 'pre_approved') {
        if (user.role == 'admin') {
          notification.buttonHidden = false;
          notification.message = '${notification.name} want to deposit the amount of ${numberFormat.format(notification.saving!.amount)}';
        } else {
          notification.message = 'Request has been pre approved';
          notification.buttonHidden = true;
        }
        notification.sub = '(Pre Approved)';
      } else {
        notification.buttonHidden = false;
        notification.message = '${notification.name} want to deposit the amount of ${numberFormat.format(notification.saving!.amount)}';
      }
    }
    if (notification.type == 'pay_loan') {
      notification.name = name;
      notification.title = 'Pay Loan';
      notification.loan = await fundRepository.getLoan(notification.uid, notification.loanId!);
      notification.loan!.payment = await fundRepository.getPayment(notification.uid, notification.loanId!, notification.docId!);
      if (notification.loan!.payment!.status == 'approved') {
        notification.message = 'Request has been approved';
        notification.buttonHidden = true;
      } else if (notification.loan!.payment!.status == 'pre_approved') {
        notification.sub = '(Pre Approved)';
        if (user.role == 'cash_manager') {
          notification.message = 'Request has been pre approved';
          notification.buttonHidden = true;
        }
        if (user.role == 'admin') {
          notification.message = '$name want to pay ${numberFormat.format(notification.loan!.payment!.amount! + notification.loan!.payment!.interest!)} for the loan';
          notification.buttonHidden = false;
        }
      } else {
        notification.message = '$name want to pay ${numberFormat.format(notification.loan!.payment!.amount! + notification.loan!.payment!.interest!)} for the loan';
        notification.buttonHidden = false;
      }
    }

    return notification;
  }

  checkBadge() {
    hasMemberBadge = false;
    hasMessageBadge = false;
    hasNotificationBadge = false;
    for (var notification in notifications) {
      if (!notification.isOpened) {
        switch (notification.type) {
          case 'apply_loan':
            hasMessageBadge = true;
            hasMemberBadge = true;
            hasNotificationBadge = true;
            break;
          case 'approved_payment':
            hasNotificationBadge = true;
            hasMessageBadge = true;
            break;
          case 'approved_loan':
            hasNotificationBadge = true;
            hasMessageBadge = true;
            break;
          case 'pay_loan':
            hasMessageBadge = true;
            hasMemberBadge = true;
            hasNotificationBadge = true;
            break;
          case 'request_deposit':
            if (notification.saving!.status != 'approved') hasMemberBadge = true;
            hasMessageBadge = true;
            hasNotificationBadge = true;
            break;
          case 'approved_deposit':
            hasMessageBadge = true;
            hasNotificationBadge = true;
            break;
          default:
            break;
        }
      }
    }
  }
}
