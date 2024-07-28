import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skunk_savers/models/notification.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/view_models/message_vm.dart';
import 'package:skunk_savers/view_models/user_vm.dart';
import 'package:skunk_savers/views/home.dart';
import 'package:skunk_savers/views/members/members.dart';
import 'package:skunk_savers/views/messages/messages.dart';

import '../res/size_config.dart';

class BottomNavigation extends StatefulWidget {
  final int currentIndex;
  final VoidCallback openDrawer;
  const BottomNavigation({Key? key, required this.currentIndex, required this.openDrawer}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  List<Widget> pages = const [
    Home(),
    Members(),
    Messages(),
  ];
  MessageVM? messageVM;
  SSCUser user = SSCUser();
  @override
  void initState() {
    user = Provider.of<UserVM>(context, listen: false).currentUser;
    super.initState();
  }

  void onTapped(int index) {
    if (index == 3) {
      widget.openDrawer();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => pages[index]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageVM>(
      builder: (context, model, child) {
        messageVM ??= model;
        return BottomNavigationBar(
          onTap: onTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedLabelStyle: TextStyle(
            fontFamily: 'Raleway',
            fontSize: SizeConfig.safeBlockHorizontal! * 4,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Raleway',
            fontSize: SizeConfig.safeBlockHorizontal! * 4,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: SizeConfig.safeBlockHorizontal! * 8,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(
                    Icons.groups,
                    size: SizeConfig.safeBlockHorizontal! * 8,
                  ),
                  model.hasMemberBadge
                      ? Positioned(
                          right: 0,
                          child: Icon(
                            Icons.circle,
                            size: SizeConfig.safeBlockHorizontal! * 3,
                            color: Colors.red,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
              label: "Members",
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(
                    Icons.message,
                    size: SizeConfig.safeBlockHorizontal! * 8,
                  ),
                  model.hasNotificationBadge || model.hasChatBadge
                      ? Positioned(
                          right: 0,
                          child: Icon(
                            Icons.circle,
                            size: SizeConfig.safeBlockHorizontal! * 3,
                            color: Colors.red,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
              label: "Messages",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: SizeConfig.safeBlockHorizontal! * 8,
              ),
              label: "Profile",
            ),
          ],
          currentIndex: widget.currentIndex,
        );
      },
    );
  }
}
