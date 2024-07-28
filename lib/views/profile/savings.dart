import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skunk_savers/models/saving.dart';
import 'package:skunk_savers/res/size_config.dart';
import 'package:skunk_savers/view_models/home_vm.dart';
import 'package:skunk_savers/views/base.dart';

class Savings extends BasePage {
  const Savings({super.key});

  @override
  SavingsState createState() => SavingsState();
}

class SavingsState extends BasePageState<Savings> with Base {
  List<Saving> savings = [];
  NumberFormat numberFormat = NumberFormat.simpleCurrency(locale: Platform.localeName, name: 'PHP');
  @override
  void initState() {
    hasBackButton(true);
    super.initState();
  }

  @override
  String appBarTitle() {
    return "Savings";
  }

  @override
  int bottomNavIndex() {
    return 3;
  }

  @override
  void onBackButtonClick() {
    Navigator.of(context).pop();
  }

  @override
  Widget body() {
    savings = Provider.of<HomeVM>(context).fund.savings!;

    return SizedBox(
      child: SafeArea(
        child: ListView.separated(
          separatorBuilder: (BuildContext context, int index) => SizedBox(
            height: SizeConfig.safeBlockHorizontal,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.safeBlockHorizontal! * 3,
          ),
          itemCount: savings.length,
          itemBuilder: (context, index) {
            DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(savings[index].date!.millisecondsSinceEpoch);
            return Card(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat.yMMMd().format(dateTime),
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            // fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                            fontSize: SizeConfig.safeBlockHorizontal! * 5,
                          ),
                        ),
                        Text(
                          numberFormat.format(savings[index].amount),
                          style: TextStyle(
                            fontSize: SizeConfig.safeBlockHorizontal! * 10,
                            fontFamily: 'Raleway',
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.check_circle,
                      color: savings[index].status == 'approved' ? Colors.green : Colors.redAccent,
                      size: SizeConfig.safeBlockHorizontal! * 10,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
