import 'package:flutter/services.dart';
import 'package:tryagain/Screens/LoginScreen.dart';
import 'package:tryagain/Screens/StartScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tryagain/util/buttons/loginRegiserButtons.dart';
import 'package:tryagain/widgets/budgetScreen.dart';

import '../UploadReceiptsScreen.dart';
import '../ReceiptsViewScreen.dart';
import '../util/constants.dart';

class TopNavigationScreen extends StatefulWidget {
  const TopNavigationScreen({super.key});

  @override
  _TopNavigtionScreenState createState() => _TopNavigtionScreenState();
  static const String id = 'top_navigation_screen';
}

class _TopNavigtionScreenState extends State<TopNavigationScreen> {

  void logoutUser(BuildContext context){
    final logout = FirebaseAuth.instance.signOut();

    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => StartScreen()),
          (Route<dynamic> route) => false,
    );

  }

  User? userId(){
    final userId = FirebaseAuth.instance.currentUser;
    return userId;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
    ));
    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyListView()),
                  );
                },
                text: 'View Receipts',
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.06,
                ) ,
              ),
              CustomButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AddDataPage()),
                  );
                },
                text: 'Upload Receipt',
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.06,
                ) ,
              ),
              CustomButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BudgetScreen()),
                  );
                },
                text: 'Budget',
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.06,
                ) ,
              ),
              CustomButton(
                onPressed: () {
                  logoutUser(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                text: 'LOGOUT',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InputPage extends StatefulWidget {
  InputPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Data',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some data';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save the data here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data saved')),
                      );
                      _textController.clear();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
