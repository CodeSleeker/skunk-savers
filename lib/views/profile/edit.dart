import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:skunk_savers/models/response.dart';
import 'package:skunk_savers/models/user.dart';
import 'package:skunk_savers/repositories/interfaces/user.dart';
import 'package:skunk_savers/repositories/user.dart';
import 'package:skunk_savers/res/size_config.dart';
import 'package:skunk_savers/views/base.dart';
import 'package:skunk_savers/widgets/customs/custom_toast.dart';
import 'package:skunk_savers/widgets/customs/elevated_button.dart';

class EditProfile extends BasePage {
  final SSCUser sscUser;
  const EditProfile({super.key, required this.sscUser});

  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends BasePageState<EditProfile> with Base {
  IUserRepository userRepository = UserRepository();
  String role = '';
  late CustomToast toast;
  @override
  void initState() {
    toast = CustomToast(context);
    hasBackButton(true);
    role = widget.sscUser.role!;
    super.initState();
  }

  @override
  String appBarTitle() {
    return "Update Profile";
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
              // buildTextForm('Email'),
              // buildTextForm('Sequence Number'),
              // widget.sscUser.role == 'admin' ? buildRole() : const SizedBox(),
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
    );
  }

  onUpdate() async {
    toast = CustomToast(context);
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    SSCResponse response = await userRepository.updateUser(widget.sscUser);
    if (response.success) {
      toast.success(msg: 'Successfully updated');
    } else {
      toast.error(msg: response.errorMessage);
    }
    EasyLoading.dismiss();
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

  getController(String label) {
    switch (label) {
      case 'Email':
        return TextEditingController(text: widget.sscUser.email);
      case 'First Name':
        return TextEditingController(text: widget.sscUser.firstname);
      case 'Last Name':
        return TextEditingController(text: widget.sscUser.lastname);
      case 'Mobile':
        return TextEditingController(text: widget.sscUser.mobile);
      case 'Sequence Number':
        return TextEditingController(text: widget.sscUser.sequenceNumber.toString());
      default:
        break;
    }
  }

  getValue(String label, dynamic value) {
    switch (label) {
      case 'Email':
        widget.sscUser.email = value;
        break;
      case 'First Name':
        widget.sscUser.firstname = value;
        break;
      case 'Last Name':
        widget.sscUser.lastname = value;
        break;
      case 'Mobile':
        widget.sscUser.mobile = value;
        break;
      case 'Sequence Number':
        widget.sscUser.sequenceNumber = int.tryParse(value) ?? 0;
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
              value: role,
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
                  role = newValue!;
                  widget.sscUser.role = newValue;
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
