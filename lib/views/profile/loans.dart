import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skunk_savers/models/loan.dart';
import 'package:skunk_savers/models/saving.dart';
import 'package:skunk_savers/res/size_config.dart';
import 'package:skunk_savers/view_models/home_vm.dart';
import 'package:skunk_savers/views/base.dart';

class Loans extends BasePage {
  const Loans({super.key});

  @override
  LoansState createState() => LoansState();
}

class LoansState extends BasePageState<Loans> with Base {
  List<Loan> loans = [];
  NumberFormat numberFormat = NumberFormat.simpleCurrency(locale: Platform.localeName, name: 'PHP');
  @override
  void initState() {
    hasBackButton(true);
    super.initState();
  }

  @override
  String appBarTitle() {
    return "Loans";
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
    loans = Provider.of<HomeVM>(context).fund.loans ?? [];
    return SizedBox(
      child: SafeArea(
        child: loans.isNotEmpty
            ? ListView.separated(
                separatorBuilder: (BuildContext context, int index) => SizedBox(
                  height: SizeConfig.safeBlockHorizontal,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.safeBlockHorizontal! * 3,
                ),
                itemCount: loans.length,
                itemBuilder: (context, index) {
                  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(loans[index].timeStamp!.millisecondsSinceEpoch);
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
                                numberFormat.format(loans[index].amount),
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
                            color: loans[index].paid! ? Colors.green : Colors.amber,
                            size: SizeConfig.safeBlockHorizontal! * 10,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Text(
                  'No Approved Loans',
                  style: TextStyle(
                    fontSize: SizeConfig.safeBlockHorizontal! * 5,
                    fontFamily: 'Raleway',
                    color: Colors.blueAccent,
                  ),
                ),
              ),
      ),
    );
  }
}
