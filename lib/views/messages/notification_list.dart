import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skunk_savers/models/account.dart';
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
import 'package:skunk_savers/view_models/message_vm.dart';
import 'package:skunk_savers/view_models/user_vm.dart';
import 'package:skunk_savers/widgets/customs/custom_toast.dart';
import 'package:skunk_savers/widgets/customs/elevated_button.dart';

class NotificationList extends StatefulWidget {
  final SSCUser user;
  final MessageVM model;
  const NotificationList({Key? key, required this.model, required this.user}) : super(key: key);

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  late MessageVM messageVM = widget.model;
  IMessageRepository messageRepository = MessageRepository();
  IFundRepository fundRepository = FundRepository();
  IUserRepository userRepository = UserRepository();
  late CustomToast toast;
  late SSCSettings settings;
  late SSCAccount account;
  late Offset tapPosition;
  int currentIndex = -1;
  int indexToDelete = -1;
  double savings = 0;
  List<SSCNotification> notifications = [];
  List<SSCUser> admins = [];
  @override
  void initState() {
    settings = Provider.of<AccountVM>(context, listen: false).sscSettings!;
    account = Provider.of<AccountVM>(context, listen: false).sscAccount!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    savings = Provider.of<HomeVM>(context).savings;
    notifications = Provider.of<MessageVM>(context).notifications;
    admins = Provider.of<UserVM>(context).admins;
    return Column(
      children: List.generate(
        notifications.length,
        (index) {
          SSCNotification notification = notifications[index];
          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(notification.timeStamp.millisecondsSinceEpoch);
          return InkWell(
            onTapDown: (position) {
              setState(() {
                currentIndex = index;
              });
              getTapPosition(position);
            },
            onLongPress: () {
              setState(() {
                indexToDelete = index;
              });
            },
            onTap: () => showNotificationDialog(notification, index),
            child: Container(
              color: currentIndex == index ? Colors.white : Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal! * 2),
              margin: EdgeInsets.symmetric(horizontal: SizeConfig.safeBlockHorizontal! * 2),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_rounded,
                            size: SizeConfig.safeBlockHorizontal! * 14,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(
                            width: SizeConfig.safeBlockHorizontal! * 2,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    notifications[index].title!,
                                    style: TextStyle(
                                      fontSize: SizeConfig.safeBlockHorizontal! * 5,
                                      fontFamily: 'Raleway',
                                      color: Colors.blueAccent,
                                      fontWeight: notifications[index].isOpened ? FontWeight.normal : FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    notifications[index].sub!,
                                    style: TextStyle(
                                      fontSize: SizeConfig.safeBlockHorizontal! * 4,
                                      fontFamily: 'Raleway',
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                notifications[index].name!,
                                style: TextStyle(
                                  fontSize: SizeConfig.safeBlockHorizontal! * 4,
                                  fontFamily: 'Raleway',
                                  color: Colors.blueAccent,
                                ),
                              ),
                              Text(
                                DateFormat('MMM d, yyyy h:mm a').format(dateTime),
                                style: TextStyle(
                                  fontSize: SizeConfig.safeBlockHorizontal! * 3,
                                  fontFamily: 'Raleway',
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          indexToDelete == index
                              ? IconButton(
                                  onPressed: () async {
                                    EasyLoading.show(status: 'Loading...');
                                    await messageRepository.removeNotification(widget.user.uid!, notification.id!);
                                    if (notifications.isNotEmpty) {
                                      setState(() {
                                        indexToDelete = -1;
                                      });
                                    }
                                    EasyLoading.dismiss();
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    size: SizeConfig.safeBlockHorizontal! * 6,
                                    color: Colors.blueAccent,
                                  ))
                              : const SizedBox(),
                          notifications[index].isOpened
                              ? const SizedBox()
                              : Container(
                                  margin: EdgeInsets.only(
                                    right: SizeConfig.safeBlockHorizontal! * 3,
                                  ),
                                  child: Icon(
                                    Icons.circle,
                                    size: SizeConfig.safeBlockHorizontal! * 4,
                                    color: Colors.red,
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  getTapPosition(TapDownDetails position) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    setState(() {
      tapPosition = referenceBox.globalToLocal(position.globalPosition); // store the tap positon in offset variable
    });
  }

  showContextMenu() async {
    final RenderObject? overlay = Overlay.of(context)?.context.findRenderObject();

    final result = await showMenu(context: context, position: RelativeRect.fromRect(Rect.fromLTWH(tapPosition.dx, tapPosition.dy, 100, 100), Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width, overlay.paintBounds.size.height)), items: [
      PopupMenuItem(
        value: "chat",
        child: Text(
          'Chat',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: SizeConfig.safeBlockHorizontal! * 5,
          ),
        ),
      ),
      PopupMenuItem(
        value: "swap",
        child: Text(
          'Request Swap',
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: SizeConfig.safeBlockHorizontal! * 5,
          ),
        ),
      ),
    ]);
    // perform action on selected menu item
    switch (result) {
      case 'chat':
        break;
      case 'swap':
        break;
    }
  }

  showNotificationDialog(SSCNotification notification, int index) {
    setState(() {
      currentIndex = index;
      indexToDelete = -1;
    });
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
          child: Container(
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
                      notification.title!,
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: SizeConfig.safeBlockHorizontal! * 5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      notification.sub!,
                      style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal! * 4,
                        fontFamily: 'Raleway',
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: SizeConfig.safeBlockVertical! * 2,
                ),
                Text(
                  notification.message!,
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: SizeConfig.safeBlockHorizontal! * 5,
                  ),
                ),
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
                      onPressed: () async {
                        Map<String, dynamic> data = {
                          'is_opened': true,
                        };
                        messageRepository.updateNotification(widget.user.uid!, notification.id!, data);
                        Navigator.of(context).pop();
                      },
                    ),
                    // notification.buttonHidden!
                    //     ? const SizedBox()
                    //     :
                    Row(
                      children: [
                        SizedBox(
                          width: SizeConfig.safeBlockHorizontal! * 2,
                        ),
                        notification.buttonHidden!
                            ? const SizedBox()
                            : CustomElevatedButton(
                                buttonText: widget.user.role == 'admin' ? 'Approve' : 'Pre Approve',
                                borderRadius: SizeConfig.safeBlockHorizontal! * 2,
                                buttonColor: Colors.blueAccent,
                                buttonHeight: SizeConfig.safeBlockVertical! * 6,
                                // buttonWidth: SizeConfig.safeBlockHorizontal! * 30,
                                fontSize: SizeConfig.safeBlockHorizontal! * 5,
                                textColor: Colors.white,
                                onPressed: () => onApprove(notification),
                              ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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

  onApprove(SSCNotification notification) async {
    toast = CustomToast(context);
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    Map<String, dynamic> data = {'status': widget.user.role == 'admin' ? 'approved' : 'pre_approved'};
    switch (notification.type) {
      case 'pay_loan':
        SSCResponse response = await fundRepository.updatePayment(notification.uid, notification.loanId!, notification.docId!, data);
        if (!response.success) {
          toast.error(msg: response.errorMessage);
          break;
        }
        if (widget.user.role == 'cash_manager') {
          PushNotification pushNotification = PushNotification(
            data: Data(
              title: 'Pay Loan(Pre-approved)',
              body: '${notification.sscUser!.firstname} ${notification.sscUser!.lastname}',
              uid: notification.sscUser!.uid,
            ),
          );
          notification.timeStamp = Timestamp.now();
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
              uid: widget.user.uid,
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
        if (widget.user.role == 'cash_manager') {
          PushNotification pushNotification = PushNotification(
            data: Data(
              title: 'Request Deposit(Pre-approved)',
              body: '${notification.sscUser!.firstname} ${notification.sscUser!.lastname}',
              uid: notification.sscUser!.uid,
            ),
          );
          notification.timeStamp = Timestamp.now();
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
              uid: widget.user.uid,
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
          // double percentShare = (this.savings / account.savings!) * 100;
          // await userRepository.partialUpdateUser(widget.user.uid!, {'percent_share': percentShare});
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
        if (widget.user.role == 'cash_manager') {
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
          PushNotification pushNotification = PushNotification(
            to: notification.sscUser!.token,
            data: Data(
              title: 'Loan Application',
              body: 'Your loan application has been approved',
              uid: widget.user.uid,
            ),
          );
          await messageRepository.sendNotification(pushNotification);
          SSCNotification newNotification = SSCNotification(
            uid: notification.uid,
            type: 'approved_loan',
            isOpened: false,
            timeStamp: Timestamp.now(),
          );
          await messageRepository.addNotification(notification.uid, newNotification);
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
    await messageRepository.updateNotification(widget.user.uid!, notification.id!, data);
    EasyLoading.dismiss();
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
