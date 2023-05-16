import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tryagain/util/buttons/loginRegiserButtons.dart';

import '../util/constants.dart';
import 'LoginScreen.dart';
import 'RegisterScreen.dart';

class StartScreen extends StatelessWidget {
  static const String id = 'start_screen';

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark, // Set the status bar color to transparent
    ));
    return SafeArea(
      top: true,
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.03,
          ) ,
          child: Column(
            children: [
              Image.asset('assets/images/BudgetingAppLogo.png'),
              Expanded(child: Container(),),
              CustomButton(
                text: 'CREATE ACCOUNT',
                onPressed: () => Navigator.pushNamed(context, RegisterScreen.id),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.023,
                ) ,
              ),
              CustomButton(
                onPressed: () => Navigator.pushNamed(context, LoginScreen.id),
                text: 'LOGIN',
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.023,
                ) ,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
