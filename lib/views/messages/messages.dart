import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:skunk_savers/models/account.dart';
import 'package:skunk_savers/models/peer.dart';
import 'package:skunk_savers/models/settings.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/repositories/interfaces/message.dart';
import 'package:skunk_savers/repositories/message.dart';
import 'package:skunk_savers/view_models/account_vm.dart';
import 'package:skunk_savers/view_models/message_vm.dart';
import 'package:skunk_savers/view_models/user_vm.dart';
import 'package:skunk_savers/views/messages/chat.dart';
import 'package:skunk_savers/views/messages/new_message.dart';
import 'package:skunk_savers/views/messages/notification_list.dart';

import '../../res/size_config.dart';
import '../base.dart';

class Messages extends BasePage {
  const Messages({super.key});

  @override
  MessagesState createState() => MessagesState();
}

class MessagesState extends BasePageState<Messages> with Base, TickerProviderStateMixin {
  SSCUser user = SSCUser();
  MessageVM? messageVM;
  IMessageRepository messageRepository = MessageRepository();
  late TabController tabController;
  int currentIndex = -1;
  List<int> indicesToDelete = [];
  late Offset tapPosition;

  @override
  void initState() {
    user = Provider.of<UserVM>(context, listen: false).currentUser;
    chatAction(getAction());
    hasBackButton(true);
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        if (tabController.index == 0) {
          setState(() {
            chatAction(getAction());
          });
        } else {
          setState(() {
            chatAction(SizedBox());
          });
        }
      }
    });
    super.initState();
  }

  @override
  String appBarTitle() {
    return "Messages";
  }

  @override
  int bottomNavIndex() {
    return 2;
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
    return SizedBox(
      child: SafeArea(
        child: Consumer<MessageVM>(builder: (_, model, child) {
          messageVM ??= model;
          return Column(
            children: [
              TabBar(
                controller: tabController,
                unselectedLabelColor: Colors.blueAccent,
                labelStyle: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal! * 5,
                  fontFamily: 'Raleway',
                ),
                indicator: const BoxDecoration(
                  color: Colors.blueAccent,
                ),
                tabs: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Tab(
                        text: 'Chat',
                      ),
                      model.hasChatBadge
                          ? Icon(
                              Icons.circle,
                              size: SizeConfig.safeBlockHorizontal! * 4,
                              color: Colors.red,
                            )
                          : const SizedBox(),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Tab(
                        text: 'Notification',
                      ),
                      model.hasNotificationBadge
                          ? Icon(
                              Icons.circle,
                              size: SizeConfig.safeBlockHorizontal! * 4,
                              color: Colors.red,
                            )
                          : const SizedBox(),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    Container(
                      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal! * 2),
                      child: (model.peers.isNotEmpty)
                          ? Column(
                              children: List.generate(
                                model.peers.length,
                                (index) {
                                  Peer peer = model.peers[index];
                                  return InkWell(
                                    onTapDown: getTapPosition,
                                    onLongPress: () {
                                      setState(() {
                                        currentIndex = index;
                                      });
                                    },
                                    onTap: () async {
                                      await messageRepository.seenMessage(user.uid!, peer.uid!);
                                      setState(() {
                                        currentIndex = -1;
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Chat(
                                            user: peer.user!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      color: currentIndex == index ? Colors.white : Colors.transparent,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.account_circle,
                                                size: SizeConfig.safeBlockHorizontal! * 15,
                                                color: Colors.blueAccent,
                                              ),
                                              SizedBox(
                                                width: SizeConfig.safeBlockHorizontal! * 2,
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    peer.user != null ? '${peer.user!.firstname} ${peer.user!.lastname}' : '',
                                                    style: TextStyle(
                                                      fontSize: SizeConfig.safeBlockHorizontal! * 5,
                                                      fontFamily: 'Raleway',
                                                      color: Colors.blueAccent,
                                                      fontWeight: peer.hasNewMessage! ? FontWeight.bold : FontWeight.normal,
                                                    ),
                                                  ),
                                                  Text(
                                                    peer.peek ?? '',
                                                    style: TextStyle(
                                                      fontSize: SizeConfig.safeBlockHorizontal! * 4,
                                                      fontFamily: 'Raleway',
                                                      color: Colors.blueAccent,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          currentIndex == index
                                              ? IconButton(
                                                  onPressed: () async {
                                                    EasyLoading.show(status: 'Loading...');
                                                    await messageRepository.removeChats(user.uid!, peer.uid!);
                                                    EasyLoading.dismiss();
                                                  },
                                                  icon: Icon(
                                                    Icons.delete,
                                                    size: SizeConfig.safeBlockHorizontal! * 6,
                                                    color: Colors.blueAccent,
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              alignment: Alignment.center,
                              child: Text(
                                'No messages',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: SizeConfig.safeBlockHorizontal! * 5,
                                ),
                              ),
                            ),
                    ),
                    (model.notifications.isNotEmpty)
                        ? SingleChildScrollView(
                            child: NotificationList(
                              model: model,
                              user: user,
                            ),
                          )
                        : Container(
                            alignment: Alignment.center,
                            child: Text(
                              'No messages',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: SizeConfig.safeBlockHorizontal! * 5,
                              ),
                            ),
                          ),
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  getTapPosition(TapDownDetails position) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    setState(() {
      tapPosition = referenceBox.globalToLocal(position.globalPosition); // store the tap positon in offset variable
    });
  }

  Widget getAction() {
    return Container(
      padding: EdgeInsets.only(right: SizeConfig.safeBlockHorizontal! * 3),
      child: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewMessage(),
            ),
          );
        },
        icon: Icon(
          Icons.edit,
          size: SizeConfig.safeBlockHorizontal! * 6,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  // showNotificationDialog(index) {
  //   SSCNotification notification = messageVM!.notifications[index];
  //   return showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.all(
  //             Radius.circular(SizeConfig.safeBlockHorizontal! * 2),
  //           ),
  //         ),
  //         child: Container(
  //           width: SizeConfig.safeBlockHorizontal! * 80,
  //           padding: EdgeInsets.symmetric(
  //             horizontal: SizeConfig.safeBlockHorizontal! * 5,
  //             vertical: SizeConfig.safeBlockHorizontal! * 6,
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Row(
  //                 children: [
  //                   Text(
  //                     notification.title!,
  //                     style: TextStyle(
  //                       fontFamily: 'Raleway',
  //                       fontSize: SizeConfig.safeBlockHorizontal! * 5,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   Text(
  //                     notification.sub!,
  //                     style: TextStyle(
  //                       fontSize: SizeConfig.safeBlockHorizontal! * 4,
  //                       fontFamily: 'Raleway',
  //                       color: Colors.blueAccent,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               SizedBox(
  //                 height: SizeConfig.safeBlockVertical! * 2,
  //               ),
  //               Text(
  //                 notification.message!,
  //                 style: TextStyle(
  //                   fontFamily: 'Raleway',
  //                   fontSize: SizeConfig.safeBlockHorizontal! * 5,
  //                 ),
  //               ),
  //               SizedBox(
  //                 height: SizeConfig.safeBlockVertical! * 2,
  //               ),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: [
  //                   const SizedBox(),
  //                   CustomElevatedButton(
  //                     buttonText: 'Close',
  //                     borderRadius: SizeConfig.safeBlockHorizontal! * 2,
  //                     buttonColor: Colors.primaries[0],
  //                     buttonHeight: SizeConfig.safeBlockVertical! * 6,
  //                     // buttonWidth: SizeConfig.safeBlockHorizontal! * 30,
  //                     fontSize: SizeConfig.safeBlockHorizontal! * 5,
  //                     textColor: Colors.white,
  //                     onPressed: () async {
  //                       // if (!notification.isOpened && notification.type == 'approved_loan' || notification.type == 'approved_deposit') {
  //                       //   Map<String, dynamic> data = {
  //                       //     'is_opened': true,
  //                       //   };
  //                       //   await messageRepository.updateNotification(userVM!.currentUser.uid!, notification.id!, data);
  //                       // }
  //                       Navigator.of(context).pop();
  //                     },
  //                   ),
  //                   // notification.buttonHidden!
  //                   //     ? const SizedBox()
  //                   //     :
  //                   Row(
  //                     children: [
  //                       SizedBox(
  //                         width: SizeConfig.safeBlockHorizontal! * 2,
  //                       ),
  //                       CustomElevatedButton(
  //                         buttonText: user.role == 'admin' ? 'Approve' : 'Pre Approve',
  //                         borderRadius: SizeConfig.safeBlockHorizontal! * 2,
  //                         buttonColor: Colors.blueAccent,
  //                         buttonHeight: SizeConfig.safeBlockVertical! * 6,
  //                         // buttonWidth: SizeConfig.safeBlockHorizontal! * 30,
  //                         fontSize: SizeConfig.safeBlockHorizontal! * 5,
  //                         textColor: Colors.white,
  //                         onPressed: () => onApprove(notification),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // addNotification(String type, String uid) async {
  //   SSCNotification notification = SSCNotification(
  //     uid: user.uid!,
  //     type: type,
  //     isOpened: false,
  //     timeStamp: Timestamp.now(),
  //   );
  //   await messageRepository.addNotification(uid, notification);
  // }
}
