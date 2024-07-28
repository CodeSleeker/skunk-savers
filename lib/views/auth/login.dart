import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:skunk_savers/repositories/auth.dart';
import 'package:skunk_savers/repositories/interfaces/auth.dart';
import 'package:skunk_savers/res/app_colors.dart';
import 'package:skunk_savers/res/size_config.dart';
import 'package:skunk_savers/view_models/account_vm.dart';
import 'package:skunk_savers/view_models/home_vm.dart';
import 'package:skunk_savers/view_models/message_vm.dart';
import 'package:skunk_savers/view_models/user_vm.dart';
import 'package:skunk_savers/views/auth/change_password.dart';
import 'package:skunk_savers/views/home.dart';

import '../../widgets/customs/elevated_button.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isObscure = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  IAuthRepository authRepository = AuthRepository();
  bool isError = false;
  String errorMessage = '';
  late StreamSubscription<User?> authSubscription;
  late UserVM userVM;
  bool isLoading = true;

  @override
  void initState() {
    userVM = Provider.of<UserVM>(context, listen: false);
    listenUser();
    super.initState();
  }

  @override
  void dispose() {
    authSubscription.cancel();
    super.dispose();
  }

  listenUser() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    await Future.delayed(const Duration(seconds: 1));
    authSubscription = authRepository.authStateChanges.listen((event) async {
      if (event != null) {
        await userVM.setUser(event.uid);
        Provider.of<AccountVM>(context, listen: false)
            .setUser(userVM.currentUser);
        Provider.of<AccountVM>(context, listen: false).listenSettings();
        Provider.of<AccountVM>(context, listen: false).listenAccount();
        Provider.of<MessageVM>(context, listen: false)
            .listenNotifications(userVM.currentUser);
        Provider.of<HomeVM>(context, listen: false).listenLoans(event.uid);
        Provider.of<HomeVM>(context, listen: false).listenSavings(event.uid);
        Provider.of<MessageVM>(context, listen: false).listenPeers(event.uid);

        if (userVM.currentUser.passwordUpdated) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Home(),
            ),
          );
        } else {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ChangePassword(),
            ),
          );
        }
      }

      isLoading = false;
      EasyLoading.dismiss();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[AppColors.navBarBgColor, AppColors.secondaryBgColor],
        ),
      ),
      child: SizedBox(
        child: SafeArea(
          child: isLoading
              ? const SizedBox()
              : Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.safeBlockHorizontal! * 4,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/skunkworks.png',
                        width: SizeConfig.safeBlockHorizontal! * 80,
                      ),
                      buildErrorMessage(),
                      buildEmail(),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical! * 2,
                      ),
                      buildPassword(),
                      SizedBox(
                        height: SizeConfig.safeBlockVertical! * 4,
                      ),
                      CustomElevatedButton(
                        buttonText: 'LOGIN',
                        buttonHeight: SizeConfig.safeBlockHorizontal! * 12,
                        borderRadius: SizeConfig.safeBlockHorizontal! * 15,
                        buttonColor: Colors.blueAccent,
                        fontSize: SizeConfig.safeBlockHorizontal! * 5,
                        textColor: Colors.white,
                        onPressed: onLogin,
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget buildPassword() {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: passwordController,
      validator: (String? value) {
        if (value!.isEmpty) {
          return "";
        }
        return null;
      },
      style: TextStyle(
        fontFamily: 'Raleway',
        fontSize: SizeConfig.safeBlockHorizontal! * 5,
      ),
      obscureText: isObscure,
      decoration: InputDecoration(
        errorStyle: const TextStyle(height: 0),
        labelStyle: TextStyle(
          fontFamily: 'Raleway',
          fontSize: SizeConfig.safeBlockHorizontal! * 5,
        ),
        labelText: 'Password',
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(SizeConfig.safeBlockHorizontal! * 3),
            borderSide: const BorderSide(
              color: Colors.grey,
            )),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(SizeConfig.safeBlockHorizontal! * 3),
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
              isObscure = isObscure ? false : true;
            });
          },
        ),
      ),
    );
  }

  Widget buildEmail() {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: emailController,
      validator: (String? value) {
        if (value!.isEmpty) return "";
        return null;
      },
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
        labelText: 'Email',
        contentPadding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(SizeConfig.safeBlockHorizontal! * 3),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(SizeConfig.safeBlockHorizontal! * 3),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: const Color.fromRGBO(222, 222, 222, 100),
          borderRadius: BorderRadius.circular(10)),
      child: Visibility(
          visible: isError,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                errorMessage,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: SizeConfig.safeBlockHorizontal! * 4,
                  fontFamily: 'Raleway',
                ),
              ),
            ),
          )),
    );
  }

  onLogin() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.black);
    var res = await authRepository.signInWithEmail(
        emailController.text, passwordController.text);
    if (res != null) {
      errorMessage = res;
      isError = true;
      EasyLoading.dismiss();
      setState(() {});
    }
  }
}
