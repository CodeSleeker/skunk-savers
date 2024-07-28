import 'package:flutter/material.dart';
import 'package:skunk_savers/views/base.dart';

class Deposit extends BasePage {
  const Deposit({super.key});

  @override
  DepositState createState() => DepositState();
}

class DepositState extends BasePageState<Deposit> with Base {
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
  void onBackButtonClick() {}

  @override
  Widget body() {
    return Container();
  }
}
