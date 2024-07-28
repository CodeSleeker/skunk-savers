import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skunk_savers/models/notification.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/res/size_config.dart';
import 'package:skunk_savers/view_models/message_vm.dart';
import 'package:skunk_savers/view_models/user_vm.dart';

class Member extends StatelessWidget {
  final dynamic getTapPosition;
  final dynamic showContextMenu;
  final dynamic onTapUp;
  final SSCUser sscUser;
  Member({
    Key? key,
    required this.showContextMenu,
    required this.getTapPosition,
    required this.sscUser,
    required this.onTapUp,
  }) : super(key: key);
  late List<SSCNotification> notifications = [];
  late SSCUser currentUser = SSCUser();

  @override
  Widget build(BuildContext context) {
    currentUser = Provider.of<UserVM>(context, listen: false).currentUser;
    notifications = Provider.of<MessageVM>(context, listen: true).notifications;
    return GestureDetector(
      onTapUp: (position) {
        if (sscUser.uid == currentUser.uid) {
          if (isAuthorize()) {
            onTapUp(sscUser);
          }
        } else {
          onTapUp(sscUser);
        }
      },
      onTapDown: (position) {
        if (sscUser.uid != currentUser.uid) {
          getTapPosition(position);
        }
      },
      onLongPress: () {
        // if (sscUser.uid != currentUser.uid) {
        //   showContextMenu(context, sscUser);
        // }
      },
      child: Card(
        elevation: 0,
        margin: EdgeInsets.symmetric(
          horizontal: SizeConfig.safeBlockHorizontal! * 5,
          vertical: SizeConfig.safeBlockHorizontal!,
        ),
        child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal! * 3),
            decoration: BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sscUser.uid == currentUser.uid ? 'You' : '${sscUser.firstname} ${sscUser.lastname}',
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal! * 5,
                    fontFamily: 'Raleway',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      sscUser.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal! * 5,
                        fontFamily: 'Raleway',
                        color: sscUser.isActive ? Colors.green : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    hasBadge()
                        ? Row(
                            children: [
                              SizedBox(
                                width: SizeConfig.safeBlockHorizontal! * 3,
                              ),
                              Icon(
                                Icons.circle,
                                size: SizeConfig.safeBlockHorizontal! * 4,
                                color: Colors.red,
                              )
                            ],
                          )
                        : SizedBox(),
                  ],
                ),
              ],
            )),
      ),
    );
  }

  isAuthorize() {
    for (var notification in notifications) {
      if (notification.uid == currentUser.uid) {
        if (notification.type != 'approved_deposit' && notification.type != 'approved_loan' && isAllowed(notification)) {
          return true;
        }
      }
    }
    return false;
  }

  isAllowed(SSCNotification notification) {
    if (notification.saving != null && notification.saving!.status != 'approved') {
      if (currentUser.role == 'cash_manager' && notification.saving!.status == 'pre_approved') {
        return false;
      }
      return true;
    }
    if (notification.loan != null && notification.loan!.status != 'approved') {
      if (currentUser.role == 'cash_manager' && notification.loan!.status == 'pre_approved') {
        return false;
      }
      return true;
    }
    if (notification.loan?.payment != null && notification.loan!.payment!.status != 'approved') {
      if (currentUser.role == 'cash_manager' && notification.loan!.payment!.status == 'pre_approved') {
        return false;
      }
      return true;
    }
    return false;
  }

  hasBadge() {
    if (notifications.isEmpty) {
      return false;
    } else {
      for (var notification in notifications) {
        if (notification.uid == sscUser.uid && !notification.isOpened && notification.type != 'approved_deposit' && notification.type != 'approved_loan') {
          return true;
        }
      }
      return false;
    }
  }
}
