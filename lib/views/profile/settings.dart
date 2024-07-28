import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:skunk_savers/models/response.dart';
import 'package:skunk_savers/models/settings.dart';
import 'package:skunk_savers/repositories/fund.dart';
import 'package:skunk_savers/repositories/interfaces/fund.dart';
import 'package:skunk_savers/res/size_config.dart';

import 'package:skunk_savers/views/base.dart';
import 'package:skunk_savers/widgets/customs/custom_toast.dart';
import 'package:skunk_savers/widgets/customs/elevated_button.dart';

class Settings extends BasePage {
  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends BasePageState<Settings> with Base {
  IFundRepository fundRepository = FundRepository();
  SSCSettings sscSettings = SSCSettings();
  String terms = '';
  late CustomToast toast;
  @override
  void initState() {
    toast = CustomToast(context);
    getSettings();
    hasBackButton(true);
    super.initState();
  }

  getSettings() async {
    sscSettings = await fundRepository.getSettings();
    setState(() {
      terms = sscSettings.terms!.join(',');
    });
  }

  @override
  String appBarTitle() {
    return "Settings";
  }

  @override
  int bottomNavIndex() {
    return 0;
  }

  @override
  void onBackButtonClick() {
    Navigator.of(context).pop();
  }

  @override
  Widget body() {
    return SafeArea(
        child: Container(
      height: SizeConfig.safeBlockVertical! * 100,
      padding: EdgeInsets.only(
        top: SizeConfig.safeBlockVertical! * 5,
        left: SizeConfig.safeBlockHorizontal! * 5,
        right: SizeConfig.safeBlockHorizontal! * 5,
        bottom: SizeConfig.safeBlockHorizontal! * 5,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            buildTextForm('Terms'),
            buildTextForm('Deposit Date'),
            buildTextForm('Interest Rate'),
            buildTextForm('Minimum Savings Amount'),
            buildTextForm('Sequence Number'),
            buildTextForm('Saving Period'),
            CustomElevatedButton(
              buttonText: 'Update',
              borderRadius: SizeConfig.safeBlockHorizontal! * 2,
              buttonColor: Colors.blueAccent,
              buttonHeight: SizeConfig.safeBlockVertical! * 7,
              fontSize: SizeConfig.safeBlockHorizontal! * 5,
              textColor: Colors.white,
              onPressed: onUpdate,
            )
          ],
        ),
      ),
    ));
  }

  onUpdate() async {
    toast = CustomToast(context);
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    sscSettings.terms!.clear();
    for (var str in terms.toString().trim().split(',')) {
      if (int.tryParse(str) != null) {
        sscSettings.terms!.add(int.parse(str));
      }
    }
    SSCResponse response = await fundRepository.updateSettings(sscSettings);
    EasyLoading.dismiss();
    if (response.success) {
      toast.success(msg: 'Settings successfully updated');
    } else {
      toast.error(msg: response.errorMessage);
    }
  }

  getController(label) {
    switch (label) {
      case 'Terms':
        return TextEditingController(text: terms);
      case 'Deposit Date':
        return TextEditingController(text: sscSettings.depositDate.toString());
      case 'Interest Rate':
        return TextEditingController(text: sscSettings.rate.toString());
      case 'Minimum Savings Amount':
        if (sscSettings.minSavings == null) {
          return TextEditingController(text: '');
        }
        return TextEditingController(text: sscSettings.minSavings!.toStringAsFixed(2));
      case 'Sequence Number':
        return TextEditingController(text: sscSettings.currentSequence.toString());
      case 'Saving Period':
        return TextEditingController(text: sscSettings.savingPeriod.toString());
      default:
        break;
    }
  }

  getValue(label, value) {
    switch (label) {
      case 'Terms':
        terms = value;
        break;
      case 'Deposit Date':
        sscSettings.depositDate = int.tryParse(value) ?? 0;
        break;
      case 'Interest Rate':
        sscSettings.rate = int.tryParse(value) ?? 0;
        break;
      case 'Minimum Savings Amount':
        sscSettings.minSavings = double.tryParse(value) ?? 0;
        break;
      case 'Sequence Number':
        sscSettings.currentSequence = int.tryParse(value) ?? 0;
        break;
      case 'Saving Period':
        sscSettings.savingPeriod = int.tryParse(value) ?? 0;
        break;
      default:
        break;
    }
  }

  Widget buildTextForm(String label) {
    return Column(
      children: [
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: getController(label),
          // validator: (String? value) {
          //   if (value!.isEmpty) return "";
          //   return null;
          // },
          onChanged: (value) => getValue(label, value),
          style: TextStyle(
            fontFamily: 'Raleway',
            fontSize: SizeConfig.safeBlockHorizontal! * 5,
          ),
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0),
            labelStyle: TextStyle(
              fontFamily: 'Raleway',
              fontSize: SizeConfig.safeBlockHorizontal! * 5,
            ),
            labelText: label,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal! * 3),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal! * 3),
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.safeBlockVertical! * 3,
        )
      ],
    );
  }
}
