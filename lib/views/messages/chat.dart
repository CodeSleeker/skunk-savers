import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:skunk_savers/models/chat.dart';
import 'package:skunk_savers/models/push_notification.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/repositories/interfaces/message.dart';
import 'package:skunk_savers/repositories/message.dart';
import 'package:skunk_savers/res/size_config.dart';
import 'package:skunk_savers/view_models/message_vm.dart';
import 'package:skunk_savers/view_models/user_vm.dart';
import 'package:skunk_savers/views/base.dart';

import '../../widgets/customs/elevated_button.dart';

class Chat extends BasePage {
  final SSCUser user;
  const Chat({Key? key, required this.user}) : super(key: key);
  @override
  ChatState createState() => ChatState();
}

class ChatState extends BasePageState<Chat> with Base {
  MessageVM? messageVM;
  TextEditingController messageController = TextEditingController();
  SSCUser currentUser = SSCUser();
  IMessageRepository messageRepository = MessageRepository();
  List<int> selectedIndices = [];
  List<String> selectedDocIds = [];
  @override
  void initState() {
    currentUser = Provider.of<UserVM>(context, listen: false).currentUser;
    hasBackButton(true);
    super.initState();
  }

  @override
  String appBarTitle() {
    return '${widget.user.firstname} ${widget.user.lastname}';
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
    return InkWell(
      onTap: () {
        setState(() {
          selectedIndices.clear();
          chatAction(SizedBox());
        });
      },
      child: SizedBox(
        child: SafeArea(
          child: Consumer<MessageVM>(
            builder: (_, model, child) {
              messageVM ??= model;
              return Container(
                padding: EdgeInsets.all(SizeConfig.safeBlockVertical!),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(),
                    Expanded(
                      child: Column(
                        children: [
                          StreamBuilder(
                            stream: model.getChats(widget.user.uid!),
                            builder: (
                              BuildContext context,
                              AsyncSnapshot snapshot,
                            ) {
                              if (snapshot.hasData) {
                                EasyLoading.dismiss();
                                List<ChatData> chats = ChatData.fromList(snapshot.data!.docs);
                                if (chats.isNotEmpty) {
                                  return Expanded(
                                    child: Container(
                                      alignment: Alignment.bottomCenter,
                                      child: ListView(
                                        reverse: true,
                                        children: List.generate(
                                          chats.length,
                                          (index) => Container(
                                            alignment: chats[index].from == currentUser.uid ? Alignment.centerRight : Alignment.centerLeft,
                                            child: InkWell(
                                              onLongPress: () {
                                                setState(() {
                                                  selectedIndices.add(index);
                                                  selectedDocIds.add(chats[index].id!);
                                                  chatAction(getAction(chats));
                                                });
                                              },
                                              child: Card(
                                                elevation: 0,
                                                color: selectedIndices.contains(index)
                                                    ? Colors.amber
                                                    : chats[index].from == currentUser.uid
                                                        ? Colors.black26
                                                        : Colors.blueAccent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(
                                                    SizeConfig.safeBlockHorizontal! * 5,
                                                  ),
                                                ),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: SizeConfig.safeBlockHorizontal! * 2,
                                                    horizontal: SizeConfig.safeBlockHorizontal! * 4,
                                                  ),
                                                  child: Text(
                                                    chats[index].content ?? '',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: SizeConfig.safeBlockHorizontal! * 5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Expanded(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'No messages',
                                        style: TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: SizeConfig.safeBlockHorizontal! * 5,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                EasyLoading.show(status: 'Loading...');
                                return SizedBox();
                              }
                            },
                          ),
                          SizedBox(
                            height: SizeConfig.safeBlockVertical! * 2,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  // height: SizeConfig.safeBlockVertical! * 7,
                                  child: TextFormField(
                                    controller: messageController,
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: SizeConfig.safeBlockHorizontal! * 5,
                                      fontFamily: 'RaleWay',
                                    ),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal! * 2),
                                      ),
                                      contentPadding: EdgeInsets.fromLTRB(14, 6, 6, 6),
                                      hintText: 'Enter text',
                                      hintStyle: TextStyle(
                                        color: Colors.black38,
                                        fontSize: SizeConfig.safeBlockHorizontal! * 5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: SizeConfig.safeBlockHorizontal! * 3,
                              ),
                              CustomElevatedButton(
                                buttonText: 'Send',
                                borderRadius: SizeConfig.safeBlockHorizontal! * 2,
                                buttonColor: Colors.blueAccent,
                                buttonHeight: SizeConfig.safeBlockVertical! * 6,
                                buttonWidth: SizeConfig.safeBlockHorizontal! * 30,
                                fontSize: SizeConfig.safeBlockHorizontal! * 5,
                                textColor: Colors.white,
                                onPressed: sendMessage,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget getAction(List<ChatData> chats) {
    return Container(
      padding: EdgeInsets.only(right: SizeConfig.safeBlockHorizontal! * 3),
      child: IconButton(
        onPressed: () async {
          EasyLoading.show(status: 'Loading...');
          await messageRepository.batchRemoveChat(currentUser.uid!, widget.user.uid!, selectedDocIds);
          if (chats.length == selectedDocIds.length) {
            await messageRepository.removeChats(currentUser.uid!, widget.user.uid!);
          }
          setState(() {
            selectedDocIds.clear();
            selectedIndices.clear();
            customAction(SizedBox());
          });
          EasyLoading.dismiss();
        },
        icon: Icon(
          Icons.delete,
          size: SizeConfig.safeBlockHorizontal! * 6,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  sendMessage() async {
    EasyLoading.show(status: 'Loading...');
    ChatData chat = ChatData(
      from: currentUser.uid,
      to: widget.user.uid,
      content: messageController.text,
      createdAt: Timestamp.now(),
    );
    messageController.clear();
    PushNotification notification = PushNotification(
      to: widget.user.token,
      data: Data(
        title: 'New Message',
        body: '${currentUser.firstname} ${currentUser.lastname}',
        uid: currentUser.uid,
        type: 'chat',
      ),
    );
    await messageRepository.sendNotification(notification);
    await messageRepository.sendMessage(chat);
    EasyLoading.dismiss();
  }
}
