import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skunk_savers/models/response.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/repositories/auth.dart';
import 'package:skunk_savers/repositories/interfaces/auth.dart';
import 'package:skunk_savers/repositories/interfaces/user.dart';
import 'package:skunk_savers/repositories/user.dart';
import 'package:skunk_savers/res/constant.dart';
import 'package:skunk_savers/res/size_config.dart';
import 'package:skunk_savers/views/members/members.dart';
import 'package:skunk_savers/widgets/customs/elevated_button.dart';
import 'package:skunk_savers/widgets/customs/custom_toast.dart';

import '../base.dart';

class AddMember extends BasePage {
  const AddMember({super.key});

  @override
  AddMemberState createState() => AddMemberState();
}

class AddMemberState extends BasePageState<AddMember> with Base {
  SSCUser sscUser = SSCUser();
  IUserRepository userRepository = UserRepository();
  IAuthRepository authRepository = AuthRepository();
  late CustomToast toast;
  @override
  void initState() {
    toast = CustomToast(context);
    sscUser.role = 'admin';
    hasBackButton(true);
    super.initState();
  }

  @override
  String appBarTitle() {
    return "Add Member";
  }

  @override
  int bottomNavIndex() {
    return 1;
  }

  @override
  void onBackButtonClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Members(),
      ),
    );
  }

  @override
  Widget body() {
    return SafeArea(
      child: Container(
        height: SizeConfig.safeBlockVertical! * 100,
        padding: EdgeInsets.only(
          left: SizeConfig.safeBlockHorizontal! * 5,
          right: SizeConfig.safeBlockHorizontal! * 5,
          bottom: SizeConfig.safeBlockHorizontal! * 5,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: SizeConfig.safeBlockVertical! * 3,
              ),
              buildTextForm('First Name'),
              buildTextForm('Last Name'),
              buildTextForm('Mobile'),
              buildTextForm('Email'),
              buildTextForm('Sequence Number'),
              buildRole(),
              CustomElevatedButton(
                buttonText: 'Add',
                borderRadius: SizeConfig.safeBlockHorizontal! * 2,
                buttonColor: Colors.blueAccent,
                buttonHeight: SizeConfig.safeBlockVertical! * 7,
                // buttonWidth: SizeConfig.safeBlockHorizontal! * 30,
                fontSize: SizeConfig.safeBlockHorizontal! * 5,
                textColor: Colors.white,
                onPressed: onAdd,
              )
            ],
          ),
        ),
      ),
    );
  }

  onAdd() async {
    toast = CustomToast(context);
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    String password = Global.getRandomString(10);
    if (SSCUser.isEmpty(sscUser)) {
      toast.error(msg: 'Please provide complete data');
      EasyLoading.dismiss();
      return;
    } else {
      SSCResponse response = await authRepository.createUserWithEmail(sscUser.email!, password);
      if (!response.success) {
        toast.error(msg: response.errorMessage);
        EasyLoading.dismiss();
        return;
      }
      sscUser.uid = response.uid;
      response = await userRepository.sendMail('${sscUser.firstname!} ${sscUser.lastname!}', sscUser.email!, password);
      if (!response.success) {
        toast.error(msg: response.errorMessage);
        EasyLoading.dismiss();
        return;
      }
      sscUser.isActive = true;
      response = await userRepository.saveUser(sscUser);
      if (response.success) {
        toast.success(msg: 'User created successfully');
      } else {
        toast.error(msg: response.errorMessage);
        EasyLoading.dismiss();
        return;
      }
    }
    EasyLoading.dismiss();
    setState(() {
      sscUser = SSCUser();
    });
  }

  getController(String label) {
    switch (label) {
      case 'Email':
        return TextEditingController(text: sscUser.email);
      case 'First Name':
        return TextEditingController(text: sscUser.firstname);
      case 'Last Name':
        return TextEditingController(text: sscUser.lastname);
      case 'Mobile':
        return TextEditingController(text: sscUser.mobile);
      case 'Sequence Number':
        return TextEditingController(text: sscUser.sequenceNumber?.toString() ?? '');
      default:
        break;
    }
  }

  getValue(String label, dynamic value) {
    switch (label) {
      case 'Email':
        sscUser.email = value;
        break;
      case 'First Name':
        sscUser.firstname = value;
        break;
      case 'Last Name':
        sscUser.lastname = value;
        break;
      case 'Mobile':
        sscUser.mobile = value;
        break;
      case 'Sequence Number':
        sscUser.sequenceNumber = int.tryParse(value);
        break;
      default:
        break;
    }
  }

  Widget buildRole() {
    return Column(
      children: [
        InputDecorator(
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0),
            labelText: "Role",
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal! * 3),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(SizeConfig.safeBlockHorizontal! * 3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isDense: true,
              isExpanded: true,
              value: sscUser.role,
              items: [
                DropdownMenuItem(
                  value: 'admin',
                  child: Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal! * 5,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'member',
                  child: Text(
                    'Member',
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal! * 5,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'cash_manager',
                  child: Text(
                    'Cash Manager',
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal! * 5,
                      fontFamily: 'Raleway',
                    ),
                  ),
                ),
              ],
              onChanged: (newValue) {
                setState(() {
                  // role = newValue!;
                  sscUser.role = newValue;
                });
              },
            ),
          ),
        ),
        SizedBox(
          height: SizeConfig.safeBlockVertical! * 3,
        )
      ],
    );
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
