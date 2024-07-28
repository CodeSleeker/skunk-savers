import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skunk_savers/models/account.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/repositories/interfaces/user.dart';
import 'package:skunk_savers/repositories/user.dart';
import 'package:skunk_savers/view_models/account_vm.dart';
import 'package:skunk_savers/view_models/members_vm.dart';
import 'package:skunk_savers/view_models/user_vm.dart';
import 'package:skunk_savers/views/members/add.dart';
import 'package:skunk_savers/views/members/profile.dart';
import 'package:skunk_savers/widgets/customs/member.dart';

import '../../res/size_config.dart';
import '../base.dart';

class Members extends BasePage {
  const Members({super.key});

  @override
  MembersState createState() => MembersState();
}

class MembersState extends BasePageState<Members> with Base {
  NumberFormat numberFormat = NumberFormat.simpleCurrency(locale: Platform.localeName, name: 'PHP');
  bool showMembers = false;
  late Offset _tapPosition;
  MembersVM? membersVM;
  IUserRepository userRepository = UserRepository();
  UserVM? userVM;
  List<SSCUser> users = [];
  SSCAccount account = SSCAccount();
  @override
  void initState() {
    hasBackButton(true);
    customAction(getAction());
    super.initState();
  }

  @override
  String appBarTitle() {
    return "Members";
  }

  @override
  int bottomNavIndex() {
    return 1;
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
    userVM = Provider.of<UserVM>(context);
    users = Provider.of<UserVM>(context).users;
    account = Provider.of<AccountVM>(context).sscAccount!;
    return SizedBox(
      child: SafeArea(
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  showMembers = !showMembers;
                });
              },
              child: Card(
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
                      Row(
                        children: [
                          Text(
                            'MEMBERS',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: SizeConfig.safeBlockHorizontal! * 5,
                            ),
                          ),
                          SizedBox(
                            width: SizeConfig.safeBlockHorizontal! * 2,
                          ),
                          Text(
                            '(${users.length.toString()})',
                            style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal! * 6,
                              fontFamily: 'Raleway',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // userVM!.hasMemberBadge
                          //     ? Icon(
                          //         Icons.circle,
                          //         size: SizeConfig.safeBlockHorizontal! * 4,
                          //         color: Colors.red,
                          //       )
                          //     : const SizedBox(),
                          showMembers
                              ? Icon(
                                  Icons.arrow_drop_down,
                                  size: SizeConfig.safeBlockHorizontal! * 8,
                                  color: Colors.white,
                                )
                              : Icon(
                                  Icons.arrow_right,
                                  size: SizeConfig.safeBlockHorizontal! * 8,
                                  color: Colors.white,
                                ),
                        ],
                      ),

                      // Row(
                      //   children: [
                      //     Text(
                      //       membersVM!.sscUsers.length.toString(),
                      //       style: TextStyle(
                      //         fontSize: SizeConfig.safeBlockHorizontal! * 10,
                      //         fontFamily: 'Raleway',
                      //         color: Colors.white,
                      //       ),
                      //     ),
                      //     showMembers
                      //         ? Icon(
                      //             Icons.arrow_drop_down,
                      //             size: SizeConfig.safeBlockHorizontal! * 8,
                      //             color: Colors.white,
                      //           )
                      //         : Icon(
                      //             Icons.arrow_right,
                      //             size: SizeConfig.safeBlockHorizontal! * 8,
                      //             color: Colors.white,
                      //           ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            showMembers
                ? Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(
                          users.length,
                          (index) => Member(
                            getTapPosition: getTapPosition,
                            showContextMenu: showContextMenu,
                            sscUser: users[index],
                            onTapUp: onTapUp,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            buildCard('SAVINGS', account.savings!),
            buildCard('PROFITS', account.profits!),
            buildCard('LOANS', account.loans!),
            buildCard('CASH ON HAND', account.cashOnHand!),
          ],
        ),
      ),
    );
  }

  Widget getAction() {
    return Container(
      padding: EdgeInsets.only(right: SizeConfig.safeBlockHorizontal! * 3),
      child: IconButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddMember()),
        ),
        icon: Icon(
          Icons.person_add,
          size: SizeConfig.safeBlockHorizontal! * 7,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget buildCard(String title, double amount) {
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
                fontSize: SizeConfig.safeBlockHorizontal! * 8,
                fontFamily: 'Raleway',
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  void getTapPosition(TapDownDetails tapPosition) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    setState(() {
      _tapPosition = referenceBox.globalToLocal(tapPosition.globalPosition); // store the tap positon in offset variable
    });
  }

  void onTapUp(SSCUser sscUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberProfile(sscUser: sscUser),
      ),
    );
  }

  void showContextMenu(BuildContext context, SSCUser sscUser) async {
    final RenderObject? overlay = Overlay.of(context)?.context.findRenderObject();

    final result = await showMenu(context: context, position: RelativeRect.fromRect(Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 100, 100), Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width, overlay!.paintBounds.size.height)), items: [
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
      sscUser.isActive
          ? PopupMenuItem(
              onTap: () async {
                sscUser.isActive = false;
                await userRepository.updateUser(sscUser);
              },
              value: "remove",
              child: Text(
                'Remove Member',
                style: TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: SizeConfig.safeBlockHorizontal! * 5,
                ),
              ),
            )
          : PopupMenuItem(
              onTap: () async {
                sscUser.isActive = true;
                await userRepository.updateUser(sscUser);
              },
              value: "add",
              child: Text(
                'Add Member',
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
}
