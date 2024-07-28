import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:skunk_savers/controllers/interfaces/auth.dart';
import 'package:skunk_savers/models/response.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/repositories/auth.dart';
import 'package:skunk_savers/repositories/interfaces/auth.dart';
import 'package:skunk_savers/repositories/interfaces/user.dart';
import 'package:skunk_savers/repositories/user.dart';
import 'package:skunk_savers/res/size_config.dart';
import 'package:skunk_savers/view_models/user_vm.dart';

import 'package:skunk_savers/views/base.dart';
import 'package:skunk_savers/widgets/customs/custom_toast.dart';
import 'package:skunk_savers/widgets/customs/elevated_button.dart';

class ChangePassword extends BasePage {
  const ChangePassword({super.key});

  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends BasePageState<ChangePassword> with Base {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  SSCUser sscUser = SSCUser();
  IAuthRepository authRepository = AuthRepository();
  IUserRepository userRepository = UserRepository();
  late CustomToast toast;
  final formKey = GlobalKey<FormState>();
  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;
  @override
  void initState() {
    sscUser = Provider.of<UserVM>(context, listen: false).currentUser;
    hasBackButton(true);
    super.initState();
  }

  @override
  String appBarTitle() {
    return "Change Password";
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
    return SafeArea(
      child: Container(
        height: SizeConfig.safeBlockVertical! * 100,
        padding: EdgeInsets.only(
          left: SizeConfig.safeBlockHorizontal! * 5,
          right: SizeConfig.safeBlockHorizontal! * 5,
          bottom: SizeConfig.safeBlockHorizontal! * 5,
          top: SizeConfig.safeBlockHorizontal! * 5,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                buildTextForm('Current Password', obscureCurrent),
                buildTextForm('New Password', obscureNew),
                buildTextForm('Confirm Password', obscureConfirm),
                CustomElevatedButton(
                  buttonText: 'Update',
                  borderRadius: SizeConfig.safeBlockHorizontal! * 2,
                  buttonColor: Colors.blueAccent,
                  buttonHeight: SizeConfig.safeBlockVertical! * 7,
                  // buttonWidth: SizeConfig.safeBlockHorizontal! * 30,
                  fontSize: SizeConfig.safeBlockHorizontal! * 5,
                  textColor: Colors.white,
                  onPressed: onUpdate,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  onUpdate() async {
    toast = CustomToast(context);
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    if (formKey.currentState!.validate()) {
      if (newPasswordController.text == confirmPasswordController.text) {
        SSCResponse response = await authRepository.validatePassword(currentPasswordController.text);
        if (response.success) {
          response = await authRepository.updatePassword(confirmPasswordController.text);
          if (response.success) {
            sscUser.passwordUpdated = true;
            await userRepository.updateUser(sscUser);
            toast.success(msg: 'Password successfully updated');
            formKey.currentState!.reset();
          } else {
            toast.error(msg: response.errorMessage);
          }
        } else {
          toast.error(msg: response.errorMessage);
        }
      } else {
        toast.error(msg: 'Password mismatch');
      }
    }
    EasyLoading.dismiss();
  }

  getController(String label) {
    switch (label) {
      case 'Current Password':
        return currentPasswordController;
      case 'New Password':
        return newPasswordController;
      case 'Confirm Password':
        return confirmPasswordController;
      default:
        break;
    }
  }

  Widget buildTextForm(String label, bool isObscure) {
    return Column(
      children: [
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: getController(label),
          validator: (String? value) {
            if (value!.isEmpty) {
              return "";
            }
            return null;
          },
          // onChanged: (value) => getValue(label, value),
          obscureText: isObscure,
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
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  if (label == 'Current Password') {
                    obscureCurrent = !obscureCurrent;
                  } else if (label == 'New Password') {
                    obscureNew = !obscureNew;
                  } else {
                    obscureConfirm = !obscureConfirm;
                  }
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
}
