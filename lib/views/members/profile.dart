import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:skunk_savers/models/account.dart';
import 'package:skunk_savers/models/loan.dart';
import 'package:skunk_savers/models/notification.dart';
import 'package:skunk_savers/models/push_notification.dart';
import 'package:skunk_savers/models/response.dart';
import 'package:skunk_savers/models/settings.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/repositories/fund.dart';
import 'package:skunk_savers/repositories/interfaces/fund.dart';
import 'package:skunk_savers/repositories/interfaces/message.dart';
import 'package:skunk_savers/repositories/interfaces/user.dart';
import 'package:skunk_savers/repositories/message.dart';
import 'package:skunk_savers/repositories/user.dart';
import 'package:skunk_savers/res/size_config.dart';
import 'package:skunk_savers/view_models/account_vm.dart';
import 'package:skunk_savers/view_models/home_vm.dart';
import 'package:skunk_savers/view_models/members_vm.dart';
import 'package:skunk_savers/view_models/message_vm.dart';
import 'package:skunk_savers/view_models/user_vm.dart';

import 'package:skunk_savers/views/base.dart';
import 'package:skunk_savers/views/messages/chat.dart';
import 'package:skunk_savers/widgets/customs/custom_toast.dart';
import 'package:skunk_savers/widgets/customs/elevated_button.dart';

class MemberProfile extends BasePage {
  final SSCUser sscUser;
  const MemberProfile({super.key, required this.sscUser});

  @override
  MemberProfileState createState() => MemberProfileState();
}

class MemberProfileState extends BasePageState<MemberProfile> with Base {
  UserVM? userVM;
  late CustomToast toast;
  IFundRepository fundRepository = FundRepository();
  IMessageRepository messageRepository = MessageRepository();
  IUserRepository userRepository = UserRepository();
  late List<SSCNotification> notifications = [];
  late SSCSettings settings;
  late SSCAccount account;
  List<SSCUser> admins = [];
  double savings = 0;
  @override
  void initState() {
    settings = Provider.of<AccountVM>(context, listen: false).sscSettings!;
    account = Provider.of<AccountVM>(context, listen: false).sscAccount!;
    hasBackButton(true);
    super.initState();
  }

  @override
  String appBarTitle() {
    return '${widget.sscUser.firstname} ${widget.sscUser.lastname}';
  }

  @override
  int bottomNavIndex() {
    return 1;
  }

  @override
  void onBackButtonClick() {
    Navigator.of(context).pop();
  }

  @override
  Widget body() {
    userVM = Provider.of<UserVM>(context, listen: true);
    notifications = Provider.of<MessageVM>(context, listen: true).notifications;
    savings = Provider.of<HomeVM>(context).savings;
    admins = Provider.of<UserVM>(context).admins;
    return SafeArea(
      child: Container(
        height: SizeConfig.safeBlockVertical! * 100,
        padding: EdgeInsets.only(
          top: SizeConfig.safeBlockVertical! * 5,
          left: SizeConfig.safeBlockHorizontal! * 5,
          right: SizeConfig.safeBlockHorizontal! * 5,
          bottom: SizeConfig.safeBlockHorizontal! * 5,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // buildTextForm('Email', widget.sscUser.email!),
              // buildTextForm('Mobile', widget.sscUser.mobile!),
              userVM!.currentUser.uid == widget.sscUser.uid
                  ? const SizedBox()
                  : Column(
                      children: [
                        CustomElevatedButton(
                          buttonText: 'Chat',
                          borderRadius: SizeConfig.safeBlockHorizontal! * 2,
                          buttonColor: Colors.blueAccent,
                          buttonHeight: SizeConfig.safeBlockVertical! * 7,
                          // buttonWidth: SizeConfig.safeBlockHorizontal! * 30,
                          fontSize: SizeConfig.safeBlockHorizontal! * 5,
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Chat(user: widget.sscUser),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: SizeConfig.safeBlockVertical! * 2,
                        ),
                        CustomElevatedButton(
                          buttonText: 'Request Swap',
                          borderRadius: SizeConfig.safeBlockHorizontal! * 2,
                          buttonColor: Colors.blueAccent,
                          buttonHeight: SizeConfig.safeBlockVertical! * 7,
                          // buttonWidth: SizeConfig.safeBlockHorizontal! * 30,
                          fontSize: SizeConfig.safeBlockHorizontal! * 5,
                          textColor: Colors.white,
                          onPressed: onSwap,
                        ),
                        SizedBox(
                          height: SizeConfig.safeBlockVertical! * 2,
                        ),
                      ],
                    ),

              checkRequest('request_deposit')
                  ? CustomElevatedButton(
                      buttonText: userVM!.currentUser.role == 'admin' ? 'Approve Deposit' : 'Pre Approve Deposit',
                      borderRadius: SizeConfig.safeBlockHorizontal! * 2,
                      buttonColor: Colors.blueAccent,
                      buttonHeight: SizeConfig.safeBlockVertical! * 7,
                      // buttonWidth: SizeConfig.safeBlockHorizontal! * 30,
                      fontSize: SizeConfig.safeBlockHorizontal! * 5,
                      textColor: Colors.white,
                      onPressed: () => onApprove('request_deposit'),
                    )
                  : const SizedBox(),
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 2,
              ),
              checkRequest('apply_loan')
                  ? CustomElevatedButton(
                      buttonText: userVM!.currentUser.role == 'admin' ? 'Approve Loan' : 'Pre Approve Loan',
                      borderRadius: SizeConfig.safeBlockHorizontal! * 2,
                      buttonColor: Colors.blueAccent,
                      buttonHeight: SizeConfig.safeBlockVertical! * 7,
                      // buttonWidth: SizeConfig.safeBlockHorizontal! * 30,
                      fontSize: SizeConfig.safeBlockHorizontal! * 5,
                      textColor: Colors.white,
                      onPressed: () => onApprove('apply_loan'),
                    )
                  : const SizedBox(),
              checkRequest('pay_loan')
                  ? CustomElevatedButton(
                      buttonText: userVM!.currentUser.role == 'admin' ? 'Approve Payment' : 'Pre Approve Payment',
                      borderRadius: SizeConfig.safeBlockHorizontal! * 2,
                      buttonColor: Colors.blueAccent,
                      buttonHeight: SizeConfig.safeBlockVertical! * 7,
                      // buttonWidth: SizeConfig.safeBlockHorizontal! * 30,
                      fontSize: SizeConfig.safeBlockHorizontal! * 5,
                      textColor: Colors.white,
                      onPressed: () => onApprove('pay_loan'),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  onSwap() async {
    // toast = CustomToast(context);
    // EasyLoading.show();
    // SSCNotification notification = SSCNotification(
    //   type: 'request_swap',
    //   uid: userVM!.currentUser.uid!,
    //   isOpened: false,
    //   timeStamp: Timestamp.now(),
    // );
    // SSCResponse response = await messageRepository.addNotification(widget.sscUser.uid!, notification);
    // if (response.success)
    //   toast.success(msg: 'Request successfully sent\nWait for the confirmation');
    // else
    //   toast.error(msg: response.errorMessage);
    // EasyLoading.dismiss();
  }

  addNotification(SSCNotification notification, PushNotification pushNotification) async {
    for (var admin in admins) {
      if (admin.token != null) {
        pushNotification.to = admin.token;
        await messageRepository.sendNotification(pushNotification);
      }
      await messageRepository.addNotification(admin.uid!, notification);
    }
  }

  onApprove(String type) async {
    toast = CustomToast(context);
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    Map<String, dynamic> data = {'status': userVM!.currentUser.role == 'admin' ? 'approved' : 'pre_approved'};
    SSCNotification notification = notifications.where((element) => element.uid == widget.sscUser.uid && element.type == type).first;
    switch (notification.type) {
      case 'pay_loan':
        SSCResponse response = await fundRepository.updatePayment(notification.uid, notification.loanId!, notification.docId!, data);
        if (!response.success) {
          toast.error(msg: response.errorMessage);
          break;
        }
        if (userVM!.currentUser.role == 'cash_manager') {
          notification.timeStamp = Timestamp.now();
          PushNotification pushNotification = PushNotification(
            data: Data(
              title: 'Pay Loan(Pre-approved)',
              body: '${notification.sscUser!.firstname} ${notification.sscUser!.lastname}',
              uid: notification.sscUser!.uid,
            ),
          );
          await addNotification(notification, pushNotification);
          toast.success(msg: 'Payment Pre Approved');
        } else {
          double balance = notification.loan!.balance!;
          double interest = notification.loan!.payment!.interest!;
          double payment = notification.loan!.payment!.amount! + interest;
          balance -= payment;
          SSCResponse response = await fundRepository.updateFund(
            notification.uid,
            notification.loanId!,
            {'balance': balance.toString()},
            'loans',
          );
          print(notification.loanId);
          if (!response.success) {
            toast.error(msg: response.errorMessage);
            break;
          }
          double cashOnHand = account.cashOnHand! + payment;
          double profits = account.profits! + interest;
          response = await fundRepository.updateAccounts({
            'cash_on_hand': cashOnHand.toString(),
            'profits': profits.toString(),
          });
          if (!response.success) {
            toast.error(msg: response.errorMessage);
            break;
          }
          PushNotification pushNotification = PushNotification(
            to: notification.sscUser!.token,
            data: Data(
              title: 'Loan Payment',
              body: 'Your loan payment has been approved',
              uid: userVM!.currentUser.uid,
            ),
          );
          await messageRepository.sendNotification(pushNotification);
          SSCNotification newNotification = SSCNotification(
            uid: notification.uid,
            type: 'approved_payment',
            isOpened: false,
            timeStamp: Timestamp.now(),
          );
          await messageRepository.addNotification(notification.uid, newNotification);
          toast.success(msg: 'Payment Approved');
        }
        break;
      case 'request_deposit':
        SSCResponse response = await fundRepository.updateFund(
          notification.uid,
          notification.docId!,
          data,
          'savings',
        );
        if (!response.success) {
          toast.error(msg: response.errorMessage);
          break;
        }
        if (userVM!.currentUser.role == 'cash_manager') {
          notification.timeStamp = Timestamp.now();
          PushNotification pushNotification = PushNotification(
            data: Data(
              title: 'Request Deposit(Pre-approved)',
              body: '${notification.sscUser!.firstname} ${notification.sscUser!.lastname}',
              uid: notification.sscUser!.uid,
            ),
          );
          await addNotification(notification, pushNotification);
          toast.success(msg: 'Deposit Pre Approved');
        } else {
          var cashOnHand = account.cashOnHand! + notification.saving!.amount!;
          var savings = account.savings! + notification.saving!.amount!;
          await fundRepository.updateAccounts({
            'cash_on_hand': cashOnHand.toString(),
            'savings': savings.toString(),
          });
          PushNotification pushNotification = PushNotification(
            to: notification.sscUser!.token,
            data: Data(
              title: 'Request Deposit',
              body: 'Your deposit has been approved',
              uid: userVM!.currentUser.uid,
            ),
          );
          await messageRepository.sendNotification(pushNotification);
          SSCNotification newNotification = SSCNotification(
            uid: notification.uid,
            type: 'approved_deposit',
            isOpened: false,
            timeStamp: Timestamp.now(),
          );
          await messageRepository.addNotification(notification.uid, newNotification);
          // double percentShare = (this.savings / savings) * 100;
          // await userRepository.partialUpdateUser(userVM!.currentUser.uid!, {'percent_share': percentShare});
          toast.success(msg: 'Deposit Approved');
        }
        break;
      case 'apply_loan':
        SSCResponse response = await fundRepository.updateFund(
          notification.uid,
          notification.docId!,
          data,
          'loans',
        );
        if (!response.success) {
          toast.error(msg: response.errorMessage);
          break;
        }
        if (userVM!.currentUser.role == 'cash_manager') {
          PushNotification pushNotification = PushNotification(
            data: Data(
              title: 'Apply Loan(Pre-approved)',
              body: '${notification.sscUser!.firstname} ${notification.sscUser!.lastname}',
              uid: notification.sscUser!.uid,
            ),
          );
          notification.timeStamp = Timestamp.now();
          await addNotification(notification, pushNotification);
          toast.success(msg: 'Loan Pre Approved');
        } else {
          var loans = account.loans! + notification.loan!.amount!;
          var cashOnHand = account.cashOnHand! - notification.loan!.amount!;
          await fundRepository.updateAccounts({
            'loans': loans.toString(),
            'cash_on_hand': cashOnHand.toString(),
          });
          SSCNotification newNotification = SSCNotification(
            uid: notification.uid,
            type: 'approved_loan',
            isOpened: false,
            timeStamp: Timestamp.now(),
          );
          await messageRepository.addNotification(notification.uid, newNotification);
          PushNotification pushNotification = PushNotification(
            to: notification.sscUser!.token,
            data: Data(
              title: 'Loan Application',
              body: 'Your loan application has been approved',
              uid: userVM!.currentUser.uid,
            ),
          );
          await messageRepository.sendNotification(pushNotification);
          toast.success(msg: 'Loan Approved');
        }
        break;
      default:
        break;
    }
    data = {
      'is_opened': true,
      'modified': Timestamp.now(),
    };
    await messageRepository.updateNotification(userVM!.currentUser.uid!, notification.id!, data);
    EasyLoading.dismiss();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Widget buildTextForm(String label, String value) {
    return Column(
      children: [
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          readOnly: true,
          controller: TextEditingController(text: value),
          // validator: (String? value) {
          //   if (value!.isEmpty) return "";
          //   return null;
          // },
          // onChanged: (value) => getValue(label, value),
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: SizeConfig.safeBlockHorizontal! * 5,
          ),
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0),
            labelStyle: TextStyle(
              fontFamily: 'Raleway',
              fontSize: SizeConfig.safeBlockHorizontal! * 5,
            ),
            labelText: label,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal! * 3),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal! * 3),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.safeBlockVertical! * 3,
        )
      ],
    );
  }

  checkRequest(String label) {
    if (notifications.isEmpty) {
      return false;
    } else {
      for (var notification in notifications) {
        if (notification.type == label && notification.uid == widget.sscUser.uid) {
          if (notification.saving != null && notification.saving!.status != 'approved') return true;
          if (notification.loan != null && notification.loan!.status != 'approved') return true;
          if (notification.loan?.payment != null && notification.loan!.payment!.status != 'approved') return true;
        }
      }
      return false;
    }
  }
}
