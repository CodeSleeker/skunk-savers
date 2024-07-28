import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skunk_savers/models/account.dart';
import 'package:skunk_savers/models/notification.dart';
import 'package:skunk_savers/models/settings.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/repositories/fund.dart';
import 'package:skunk_savers/repositories/interfaces/fund.dart';
import 'package:skunk_savers/repositories/interfaces/user.dart';
import 'package:skunk_savers/repositories/user.dart';

class AccountVM extends ChangeNotifier {
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  IUserRepository userRepository = UserRepository();
  IFundRepository fundRepository = FundRepository();
  List<SSCNotification> notifications = [];
  SSCAccount? sscAccount;
  SSCSettings? sscSettings;
  SSCUser? user;

  late StreamSubscription accountSubscription;
  late StreamSubscription settingsSubscription;

  stopListening() async {
    user = null;
    sscSettings = null;
    sscAccount = null;
    notifications = [];
    accountSubscription.cancel();
    settingsSubscription.cancel();
  }

  setUser(SSCUser user) {
    this.user = user;
  }

  listenAccount() {
    var reference = firestoreInstance.collection('funds').doc('total');
    accountSubscription = reference.snapshots().listen((event) async {
      if (event.data() != null) {
        sscAccount = SSCAccount.fromJson(event.data()!);
        double savings = await fundRepository.getUserSavings(user!.uid!);
        double percentShare = (savings / sscAccount!.savings!) * 100;
        print('PercentShare: $percentShare');
        notifyListeners();
        userRepository.partialUpdateUser(user!.uid!, {'percent_share': percentShare.isNaN ? 0.0 : percentShare});
      }
    });
  }

  listenSettings() {
    var reference = firestoreInstance.collection('funds').doc('settings');
    settingsSubscription = reference.snapshots().listen((event) {
      if (event.data() != null) {
        sscSettings = SSCSettings.fromJson(event.data()!);
        notifyListeners();
      }
    });
  }
}
