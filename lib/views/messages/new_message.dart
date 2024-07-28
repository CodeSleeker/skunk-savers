import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/res/size_config.dart';
import 'package:skunk_savers/view_models/user_vm.dart';

import 'package:skunk_savers/views/base.dart';
import 'package:skunk_savers/views/messages/chat.dart';

class NewMessage extends BasePage {
  @override
  NewMessageState createState() => NewMessageState();
}

class NewMessageState extends BasePageState<NewMessage> with Base {
  List<SSCUser> users = [];
  TextEditingController searchController = TextEditingController();
  SSCUser user = SSCUser();
  @override
  void initState() {
    user = Provider.of<UserVM>(context, listen: false).currentUser;
    hasBackButton(true);
    super.initState();
  }

  @override
  String appBarTitle() {
    return "New Message";
  }

  @override
  int bottomNavIndex() {
    return 2;
  }

  @override
  void onBackButtonClick() {
    Navigator.of(context).pop();
  }

  @override
  Widget body() {
    users = Provider.of<UserVM>(context).users;
    return SizedBox(
      child: SafeArea(
        child: Column(
          children: [
            // Container(
            //   margin: EdgeInsets.only(
            //     left: SizeConfig.safeBlockHorizontal! * 2,
            //     right: SizeConfig.safeBlockHorizontal! * 2,
            //     bottom: SizeConfig.safeBlockHorizontal! * 2,
            //   ),
            //   child: TextFormField(
            //     controller: searchController,
            //     style: TextStyle(
            //       color: Colors.blueAccent,
            //       fontSize: SizeConfig.safeBlockHorizontal! * 5,
            //       fontFamily: 'RaleWay',
            //     ),
            //     decoration: InputDecoration(
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal! * 2),
            //       ),
            //       contentPadding: EdgeInsets.fromLTRB(14, 6, 6, 6),
            //       hintText: 'Search here',
            //       hintStyle: TextStyle(
            //         color: Colors.black38,
            //         fontSize: SizeConfig.safeBlockHorizontal! * 5,
            //       ),
            //       suffixIcon: Icon(Icons.search),
            //     ),
            //   ),
            // ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.safeBlockHorizontal! * 3,
                ),
                children: List.generate(users.length, (index) {
                  SSCUser user = users[index];
                  if (user.uid == this.user.uid) {
                    return SizedBox();
                  }
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chat(
                            user: user,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.account_circle,
                              size: SizeConfig.safeBlockHorizontal! * 15,
                              color: Colors.blueAccent,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user.firstname} ${user.lastname}',
                                  style: TextStyle(
                                    fontFamily: 'Raleway',
                                    // fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                    fontSize: SizeConfig.safeBlockHorizontal! * 6,
                                  ),
                                ),
                                Text(
                                  '${user.role}',
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
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
