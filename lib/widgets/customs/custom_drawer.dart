import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:skunk_savers/repositories/auth.dart';
import 'package:skunk_savers/repositories/interfaces/auth.dart';
import 'package:skunk_savers/res/size_config.dart';
import 'package:skunk_savers/view_models/account_vm.dart';
import 'package:skunk_savers/view_models/home_vm.dart';
import 'package:skunk_savers/view_models/members_vm.dart';
import 'package:skunk_savers/view_models/message_vm.dart';
import 'package:skunk_savers/view_models/user_vm.dart';
import 'package:skunk_savers/views/auth/change_password.dart';
import 'package:skunk_savers/views/auth/login.dart';
import 'package:skunk_savers/views/members/add.dart';
import 'package:skunk_savers/views/profile/edit.dart';
import 'package:skunk_savers/views/profile/loans.dart';
import 'package:skunk_savers/views/profile/savings.dart';
import 'package:skunk_savers/views/profile/settings.dart';
import 'package:skunk_savers/widgets/customs/elevated_button.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  UserVM? userVM;
  MembersVM? membersVM;
  IAuthRepository authRepository = AuthRepository();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    membersVM = Provider.of<MembersVM>(context, listen: false);
    return Drawer(
      child: SafeArea(
        child: Consumer<UserVM>(
          builder: (_, model, child) {
            userVM ??= model;
            return Column(
              children: [
                Container(
                  height: SizeConfig.safeBlockVertical! * 25,
                  width: double.infinity,
                  padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal! * 5),
                  color: Colors.blueAccent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.account_circle,
                        size: SizeConfig.safeBlockHorizontal! * 15,
                        color: Colors.white,
                      ),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${userVM!.currentUser.firstname} ${userVM!.currentUser.lastname}',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: SizeConfig.safeBlockHorizontal! * 6,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${userVM!.currentUser.mobile}',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              fontSize: SizeConfig.safeBlockHorizontal! * 4,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: userVM!.currentUser.role == 'admin' ? buildAdminView() : buildNotAdminView(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  buildAdminView() {
    return ListView(
      padding: EdgeInsets.zero,
      itemExtent: SizeConfig.safeBlockVertical! * 5.5,
      children: [
        buildTile(
          iconData: Icons.edit,
          title: 'Edit Profile',
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfile(sscUser: userVM!.currentUser),
              ),
            );
          },
        ),
        buildTile(
          iconData: Icons.lock_reset,
          title: 'Change Password',
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChangePassword(),
              ),
            );
          },
        ),
        buildTile(
          iconData: Icons.savings,
          title: 'Savings',
          onTap: () {},
        ),
        buildTile(
          iconData: Icons.paid,
          title: 'Loans',
          onTap: () {},
        ),
        buildTile(
          iconData: Icons.person_add,
          title: 'Add Member',
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddMember(),
              ),
            );
          },
        ),
        buildTile(
          iconData: Icons.settings,
          title: 'Settings',
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Settings(),
              ),
            );
          },
        ),
        buildTile(
          iconData: Icons.logout,
          title: 'Logout',
          onTap: showNotificationDialog,
          isBold: true,
        ),
      ],
    );
  }

  buildNotAdminView() {
    return ListView(
      padding: EdgeInsets.zero,
      itemExtent: SizeConfig.safeBlockVertical! * 5.5,
      children: [
        buildTile(
          iconData: Icons.edit,
          title: 'Edit Profile',
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfile(sscUser: userVM!.currentUser),
              ),
            );
          },
        ),
        buildTile(
          iconData: Icons.lock_reset,
          title: 'Change Password',
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChangePassword(),
              ),
            );
          },
        ),
        buildTile(
          iconData: Icons.savings,
          title: 'Savings',
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Savings(),
              ),
            );
          },
        ),
        buildTile(
          iconData: Icons.paid,
          title: 'Loans',
          onTap: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Loans(),
              ),
            );
          },
        ),
        buildTile(
          iconData: Icons.logout,
          title: 'Logout',
          onTap: showNotificationDialog,
          isBold: true,
        ),
      ],
    );
  }

  Widget buildTile({
    required IconData iconData,
    required String title,
    required VoidCallback onTap,
    bool isBold = false,
  }) {
    return ListTile(
      leading: Icon(
        iconData,
        size: SizeConfig.safeBlockHorizontal! * 7,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.blueAccent,
          fontFamily: 'Raleway',
          fontSize: SizeConfig.safeBlockHorizontal! * 5,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }

  showNotificationDialog() {
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
                Text(
                  'Are you sure you want to logout?',
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
                      buttonText: 'Cancel',
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
                    SizedBox(
                      width: SizeConfig.safeBlockHorizontal! * 2,
                    ),
                    CustomElevatedButton(
                      buttonText: 'Logout',
                      borderRadius: SizeConfig.safeBlockHorizontal! * 2,
                      buttonColor: Colors.blueAccent,
                      buttonHeight: SizeConfig.safeBlockVertical! * 6,
                      // buttonWidth: SizeConfig.safeBlockHorizontal! * 30,
                      fontSize: SizeConfig.safeBlockHorizontal! * 5,
                      textColor: Colors.white,
                      onPressed: onLogout,
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

  onLogout() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await Provider.of<AccountVM>(context, listen: false).stopListening();
    await Provider.of<HomeVM>(context, listen: false).stopListening();
    await Provider.of<MessageVM>(context, listen: false).stopListening();
    await userVM!.stopListening();
    userVM!.listening = false;
    await authRepository.signOut();
    EasyLoading.dismiss();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const Login(),
        ),
        (Route<dynamic> route) => route is Login);
  }
}
