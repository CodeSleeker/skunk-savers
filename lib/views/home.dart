import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skunk_savers/models/account.dart';
import 'package:skunk_savers/models/loan.dart';
import 'package:skunk_savers/models/notification.dart';
import 'package:skunk_savers/models/payment.dart';
import 'package:skunk_savers/models/push_notification.dart';
import 'package:skunk_savers/models/response.dart';
import 'package:skunk_savers/models/saving.dart';
import 'package:skunk_savers/models/settings.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/repositories/fund.dart';
import 'package:skunk_savers/repositories/interfaces/fund.dart';
import 'package:skunk_savers/repositories/interfaces/message.dart';
import 'package:skunk_savers/repositories/message.dart';
import 'package:skunk_savers/view_models/account_vm.dart';
import 'package:skunk_savers/view_models/home_vm.dart';
import 'package:skunk_savers/view_models/members_vm.dart';
import 'package:skunk_savers/view_models/user_vm.dart';
import 'package:skunk_savers/widgets/customs/custom_toast.dart';
import 'package:skunk_savers/widgets/customs/elevated_button.dart';

import '../res/size_config.dart';
import 'base.dart';

class Home extends BasePage {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends BasePageState<Home> with Base {
  late Size size;
  NumberFormat numberFormat = NumberFormat.simpleCurrency(locale: Platform.localeName, name: 'PHP');
  IFundRepository fundRepository = FundRepository();
  IMessageRepository messageRepository = MessageRepository();
  // UserVM? userVM;
  HomeVM? homeVM;
  List<SSCUser> admins = [];
  List<SSCUser> cashManagers = [];
  SSCAccount? sscAccount;
  SSCSettings? sscSettings;
  late CustomToast toast;
  Loan loan = Loan();
  SSCUser currentUser = SSCUser();
  @override
  void initState() {
    currentUser = Provider.of<UserVM>(context, listen: false).currentUser;
    loan.amount = 1000;
    loan.term = 6;
    super.initState();
  }

  @override
  String appBarTitle() {
    return "";
  }

  @override
  int bottomNavIndex() {
    return 0;
  }

  @override
  void onBackButtonClick() {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget body() {
    SizeConfig().init(context);
    sscAccount = Provider.of<AccountVM>(context).sscAccount;
    sscSettings = Provider.of<AccountVM>(context).sscSettings;
    admins = Provider.of<UserVM>(context).admins;
    cashManagers = Provider.of<UserVM>(context).cashManagers;
    return SizedBox(
      // width: SizeConfig.safeBlockVertical! * 100,
      child: SafeArea(
        child: Consumer<HomeVM>(
          builder: (_, model, child) {
            homeVM ??= model;
            return sscSettings == null && sscAccount == null
                ? SizedBox()
                : Column(
                    children: [
                      SizedBox(
                        height: SizeConfig.safeBlockVertical!,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: SizeConfig.safeBlockHorizontal! * 2,
                          ),
                          Image.asset(
                            'assets/images/skunkworks-logo.png',
                            width: SizeConfig.safeBlockHorizontal! * 8,
                          ),
                          SizedBox(
                            width: SizeConfig.safeBlockHorizontal! * 2,
                          ),
                          Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal! * 6,
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical!,
                      ),
                      !model.hasPendingSavingsDeposit && sscSettings!.depositDate! <= DateTime.now().day && (model.fund.savings == null || (model.fund.savings != null && model.fund.savings!.length < sscSettings!.savingPeriod!))
                          ? buildCard('SAVINGS', model.savings, buttonCaption: 'Deposit', onPressed: onDeposit)
                          : buildCard('SAVINGS', model.savings, showActionButton: false),
                      // buildCard('SAVINGS', homeVM!.savings, buttonCaption: 'Deposit', onPressed: onDeposit),
                      !homeVM!.hasPendingLoanApplication &&
                              !model.hasPendingSavingsDeposit &&
                              sscSettings!.currentSequence! == currentUser.sequenceNumber &&
                              sscSettings!.depositDate! <= DateTime.now().day &&
                              sscAccount!.cashOnHand! > 0 &&
                              model.loan == null &&
                              model.fund.savings != null &&
                              model.fund.savings!.length == sscSettings!.savingPeriod
                          ? buildCard('LOANABLE AMOUNT', sscAccount!.cashOnHand, buttonCaption: 'Apply', onPressed: showApplicationDialog)
                          : const SizedBox(),
                      homeVM!.hasPendingLoanApplication ? buildCard('LOAN APPLICATION', homeVM!.loan?.amount! ?? 0, showActionButton: false, statusText: 'Pending') : const SizedBox(),
                      homeVM!.hasApprovedLoanApplication
                          ? model.loan?.payment == null
                              ? buildCard('LOAN BALANCE', model.loan?.balance ?? 0, buttonCaption: 'Pay', onPressed: onPayment)
                              : buildCard('LOAN BALANCE', model.loan?.balance ?? 0, showActionButton: false, statusText: 'Pending')
                          : const SizedBox(),
                      buildBottomCard('PROFITS', currentUser.percentShare! == 0 ? 0 : (currentUser.percentShare! / 100) * sscAccount!.profits!),
                      buildBottomCard('TOTAL CASH', model.savings + (currentUser.percentShare! == 0 ? 0 : ((currentUser.percentShare! / 100) * sscAccount!.profits!)))
                    ],
                  );
          },
        ),
      ),
    );
  }

  onPayment() async {
    toast = CustomToast(context);
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    Payment payment = Payment(
      timeStamp: Timestamp.now(),
      amount: homeVM!.loan!.amount! / homeVM!.loan!.term!,
      status: 'pending',
    );
    payment.interest = homeVM!.loan!.payable! - payment.amount!;
    SSCResponse response = await fundRepository.addPayment(currentUser.uid!, homeVM!.loan!.id!, payment);
    if (!response.success) {
      toast.error(msg: response.errorMessage);
      EasyLoading.dismiss();
      return;
    }
    await fundRepository.updateFund(currentUser.uid!, homeVM!.loan!.id!, {'modified_at': Timestamp.now()}, 'loans');
    SSCNotification notification = SSCNotification(
      docId: response.docId,
      uid: currentUser.uid!,
      loanId: homeVM!.loan!.id,
      type: 'pay_loan',
      isOpened: false,
      timeStamp: Timestamp.now(),
    );
    PushNotification pushNotification = PushNotification(
      data: Data(
        title: 'Pay Loan',
        body: '${currentUser.firstname} ${currentUser.lastname}',
        uid: currentUser.uid,
      ),
    );
    await addNotification(notification, pushNotification);
    toast.success(msg: 'Your payment was successfully sent.\nWait for the confirmation.');
    EasyLoading.dismiss();
  }

  // hasPendingLoanApplication() {
  //   if (userVM!.currentUser.loans!.isNotEmpty) {
  //     return userVM!.currentUser.loans!.any((element) => element.status == 'pending' || element.status == 'pre_approved');
  //   }
  //   return false;
  // }
  //
  // hasApprovedLoanApplication() {
  //   if (userVM!.currentUser.loans!.isNotEmpty) {
  //     return userVM!.currentUser.loans!.any((element) => element.status == 'approved');
  //   }
  //   return false;
  // }

  // getCurrentLoan() {
  //   if (userVM!.currentUser.loans!.isNotEmpty) {
  //     return userVM!.currentUser.loans!.where((element) => element.paid == false).first.balance;
  //   }
  //   return 0;
  // }

  onDeposit() async {
    toast = CustomToast(context);
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    Saving saving = Saving(amount: sscSettings!.minSavings, date: Timestamp.now(), status: 'pending');
    SSCResponse response = await fundRepository.addSavings(currentUser.uid!, saving);
    if (response.success) {
      SSCNotification notification = SSCNotification(
        docId: response.docId,
        uid: currentUser.uid!,
        type: 'request_deposit',
        isOpened: false,
        timeStamp: Timestamp.now(),
      );
      PushNotification pushNotification = PushNotification(
        data: Data(
          title: 'Request Deposit',
          body: '${currentUser.firstname} ${currentUser.lastname}',
          uid: currentUser.uid,
        ),
      );
      await addNotification(notification, pushNotification);
      toast.success(gravity: ToastGravity.BOTTOM, msg: 'Successful deposit.\nWait for the confirmation');
    } else {
      toast.error(msg: response.errorMessage);
    }
    EasyLoading.dismiss();
  }

  Widget buildBottomCard(title, amount) {
    return Card(
      elevation: 0,
      color: Colors.blueAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: Container(
        width: double.infinity,
        // height: SizeConfig.safeBlockVertical! * 15,
        padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal! * 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Raleway',
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: SizeConfig.safeBlockHorizontal! * 5,
              ),
            ),
            Text(
              numberFormat.format(amount),
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal! * 10,
                fontFamily: 'Raleway',
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildCard(title, amount, {buttonCaption = '', onPressed, showActionButton = true, statusText = ''}) {
    return Card(
      elevation: 0,
      color: Colors.blueAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: Container(
        width: double.infinity,
        // height: SizeConfig.safeBlockVertical! * 15,
        padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal! * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Raleway',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  numberFormat.format(amount),
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal! * 10,
                    fontFamily: 'Raleway',
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    showActionButton
                        ? CustomElevatedButton(
                            buttonText: buttonCaption,
                            borderRadius: SizeConfig.safeBlockHorizontal! * 15,
                            buttonColor: Colors.white,
                            buttonWidth: SizeConfig.safeBlockHorizontal! * 30,
                            fontSize: SizeConfig.safeBlockHorizontal! * 5,
                            textColor: Colors.blueAccent,
                            onPressed: onPressed,
                          )
                        : const SizedBox(),
                    title == 'LOAN APPLICATION'
                        ? Text(
                            buttonCaption,
                            style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal! * 8,
                              fontFamily: 'Raleway',
                              color: Colors.white,
                            ),
                          )
                        : const SizedBox(),
                    statusText != ''
                        ? Text(
                            statusText,
                            style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal! * 8,
                              fontFamily: 'Raleway',
                              color: Colors.white,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // showButton(title) {
  //   if (title == 'LOAN APPLICATION') {
  //     return false;
  //   }
  //   if (title == 'SAVINGS') {
  //     if (userVM!.sscSettings.depositDate != null && userVM!.sscSettings.depositDate! <= DateTime.now().day) {
  //       if (userVM!.currentUser.savings!.isEmpty) {
  //         return true;
  //       } else {
  //         return userVM!.currentUser.savings![0].status == 'Approved' ? true : false;
  //       }
  //     } else {
  //       return false;
  //     }
  //   } else {
  //     return true;
  //   }
  // }

  showApplicationDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(SizeConfig.safeBlockHorizontal! * 2),
            ),
          ),
          child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: SizeConfig.safeBlockHorizontal! * 80,
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.safeBlockHorizontal! * 5,
                vertical: SizeConfig.safeBlockHorizontal! * 6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Loan Application',
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontSize: SizeConfig.safeBlockHorizontal! * 5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical! * 2,
                  ),
                  getLoanAmount(setState),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical! * 2,
                  ),
                  getTerms(setState),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical! * 2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(),
                      CustomElevatedButton(
                        buttonText: 'Close',
                        borderRadius: SizeConfig.safeBlockHorizontal! * 2,
                        buttonColor: Colors.primaries[0],
                        buttonHeight: SizeConfig.safeBlockVertical! * 6,
                        // buttonWidth: SizeConfig.safeBlockHorizontal! * 30,
                        fontSize: SizeConfig.safeBlockHorizontal! * 5,
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: SizeConfig.safeBlockHorizontal! * 2,
                          ),
                          CustomElevatedButton(
                            buttonText: 'Apply',
                            borderRadius: SizeConfig.safeBlockHorizontal! * 2,
                            buttonColor: Colors.blueAccent,
                            buttonHeight: SizeConfig.safeBlockVertical! * 6,
                            // buttonWidth: SizeConfig.safeBlockHorizontal! * 30,
                            fontSize: SizeConfig.safeBlockHorizontal! * 5,
                            textColor: Colors.white,
                            onPressed: () => onApply(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  addNotification(SSCNotification notification, PushNotification pushNotification) async {
    for (var ca in cashManagers) {
      pushNotification.to = ca.token;
      await messageRepository.sendNotification(pushNotification);
      await messageRepository.addNotification(ca.uid!, notification);
    }
    // for (var admin in admins) {
    //   await messageRepository.addNotification(admin.uid!, notification);
    // }
  }

  onApply() async {
    toast = CustomToast(context);
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    double interest = loan.amount! * (sscSettings!.rate! / 100);
    loan.payable = (loan.amount! / loan.term!) + interest;
    loan.paid = false;
    loan.balance = loan.amount! + (interest * loan.term!);
    loan.status = 'pending';
    loan.timeStamp = Timestamp.now();
    SSCResponse response = await fundRepository.addLoan(currentUser.uid!, loan);
    if (!response.success) {
      toast.error(msg: response.errorMessage);
      EasyLoading.dismiss();
      return;
    }
    SSCNotification notification = SSCNotification(
      docId: response.docId,
      uid: currentUser.uid!,
      type: 'apply_loan',
      isOpened: false,
      timeStamp: Timestamp.now(),
    );
    PushNotification pushNotification = PushNotification(
      data: Data(
        title: 'Apply Loan',
        body: '${currentUser.firstname} ${currentUser.lastname}',
        uid: currentUser.uid,
      ),
    );
    await addNotification(notification, pushNotification);
    toast.success(gravity: ToastGravity.BOTTOM, msg: 'Sent loan application.\nWait for the confirmation');
    if (!mounted) return;
    Navigator.of(context).pop();
    EasyLoading.dismiss();
  }

  Widget getTerms(StateSetter setState) {
    return Column(
      children: [
        InputDecorator(
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0),
            labelText: "Terms",
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal! * 3),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal! * 3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isDense: true,
              isExpanded: true,
              value: loan.term,
              items: getDropdownItemsTerm(),
              onChanged: (newValue) {
                setState(() {
                  loan.term = newValue!;
                });
              },
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.safeBlockVertical! * 3,
        )
      ],
    );
  }

  getDropdownItemsTerm() {
    return List.generate(
      sscSettings!.terms!.length,
      (index) => DropdownMenuItem(
        value: sscSettings!.terms![index],
        child: Text(
          sscSettings!.terms![index].toString(),
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal! * 5,
            fontFamily: 'Raleway',
          ),
        ),
      ),
    );
  }

  Widget getLoanAmount(StateSetter setState) {
    return Column(
      children: [
        InputDecorator(
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0),
            labelText: "Amount",
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal! * 3),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal! * 3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<double>(
              isDense: true,
              isExpanded: true,
              value: loan.amount,
              items: getDropdownItemsAmount(setState),
              onChanged: (newValue) {
                setState(() {
                  loan.amount = newValue!;
                });
              },
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.safeBlockVertical! * 3,
        )
      ],
    );
  }

  getDropdownItemsAmount(StateSetter setState) {
    var length = sscAccount!.cashOnHand! <= 1000 ? 1 : ((sscAccount!.cashOnHand! - 1000) ~/ 1000) + 1;
    var items = List.generate(
      length,
      (index) => DropdownMenuItem(
        value: (1000 + (index * 1000)).toDouble(),
        child: Text(
          (1000 + (index * 1000)).toString(),
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal! * 5,
            fontFamily: 'Raleway',
          ),
        ),
      ),
    );
    return items;
  }
}
