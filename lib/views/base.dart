import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skunk_savers/view_models/user_vm.dart';
import 'package:skunk_savers/widgets/bottom_navigation.dart';
import 'package:skunk_savers/widgets/customs/custom_drawer.dart';

import '../res/app_colors.dart';
import '../res/size_config.dart';

abstract class BasePage extends StatefulWidget {
  const BasePage({Key? key}) : super(key: key);
}

abstract class BasePageState<Page extends BasePage> extends State<Page> {
  bool _hasBackButton = false;
  Widget? _customAppBarTitle;
  Widget? _action;
  Widget? _chatAction;
  String role = '';
  void customAppBarTitle(Widget value) {
    _customAppBarTitle = value;
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  int bottomNavIndex();
  String appBarTitle();
  void onBackButtonClick();
  void hasBackButton(bool value) {
    _hasBackButton = value;
  }

  void customAction(Widget value) {
    _action = value;
  }

  void chatAction(Widget value) {
    _chatAction = value;
  }
}

mixin Base<Page extends BasePage> on BasePageState<Page> {
  @override
  Widget build(BuildContext context) {
    role = Provider.of<UserVM>(context, listen: true).currentUser.role!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: appBarTitle() == ""
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: AppColors.navBarBgColor,
              foregroundColor: AppColors.headerFgColor,
              title: _customAppBarTitle ??
                  Text(
                    appBarTitle(),
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: SizeConfig.safeBlockHorizontal! * 6,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              leading: _hasBackButton
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.blueAccent,
                        size: SizeConfig.safeBlockHorizontal! * 6,
                      ),
                      onPressed: () {
                        onBackButtonClick();
                      },
                    )
                  : null,
              actions: [
                role == 'admin' ? _action ?? const SizedBox() : const SizedBox(),
                _chatAction ?? const SizedBox(),
              ],
            ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppColors.navBarBgColor, AppColors.secondaryBgColor],
          ),
        ),
        child: body(),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: bottomNavIndex(),
        openDrawer: () {
          _scaffoldKey.currentState!.openDrawer();
        },
      ),
    );
  }

  Widget body();
}

/* Start Template

import 'package:flutter/material.dart';

import 'package:skunk_savers/views/base.dart';

class <ClassName> extends BasePage {
  @override
  <ClassName>State createState() => <ClassName>State();
}

class <ClassName>State extends BasePageState<<ClassName>> with Base {
  @override
  void initState() {
    hasBackButton(true);
    super.initState();
  }

  @override
  String appBarTitle() {
    return "<Title>";
  }

  @override
  int bottomNavIndex() {
    return 0;
  }

  @override
  void onBackButtonClick() {
  }

  @override
  Widget body() {
    return Container();
  }
}

End Template */
