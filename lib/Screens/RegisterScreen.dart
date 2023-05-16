import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tryagain/Screens/EmailVerificationScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tryagain/util/buttons/loginRegiserButtons.dart';
import 'package:tryagain/util/constants.dart';

import '../widgets/budgetScreen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
  static const String id = 'register_screen';
}

class _RegisterPageState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  final List<Category> _expenseCategories = [Category(title: 'Bills',
      expenses: [Expense(title: 'Rent', amount: 1000), Expense(title: 'Utilities', amount: 200)])];

  late String _error = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({'${userID}data': _expenseCategories.map((e) => e.toJson()).toList()});
    await prefs.setString(userID, userData);

  }

  void _registerUser(BuildContext context) async {
    print('tessss');
    try {
      print('trying');
      print(_passwordController.text);
      print(_emailController.text);
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      print(userCredential.user);
      // Send email verification
      await userCredential.user?.sendEmailVerification();
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
        await userCollection.doc(user.uid).set({
          // 'name': user.displayName,
          'receipts': null,
          'email': user.email,
          // Add any other necessary fields here
        });
        _saveData();
      }

      // Navigate to home page
      Navigator.pushNamed(context, EmailVerificationScreen.id);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        setState(() {
          _error = 'The password provided is too weak.';
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _error = 'The account already exists for that email.';
        });
      } else {
        setState(() {
          _error = 'Error: ${e.code}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: Padding(
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.height * 0.02,
            right: MediaQuery.of(context).size.height * 0.02,
          ),
          child: SingleChildScrollView(
            child: Form(
            key: _formKey,
            child: Column(
                children: [
                  Align(
                      heightFactor: 0.87,
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                  ),
                  Image.asset('assets/images/BudgetingAppLogo.png'),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.06,
                    ) ,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      // labelText: 'Email',
                      hintText: 'Enter your email',
                      filled: true,
                      fillColor: kTextFormFieldColor,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        // borderRadius: BorderRadius.circular(10.0),
                        gapPadding: 8.0,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.02,
                    ) ,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      // labelText: 'Password',
                      hintText: 'Enter your password',
                      filled: true,
                      fillColor: kTextFormFieldColor,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                        // borderRadius: BorderRadius.circular(10.0),
                        gapPadding: 8.0,
                      ),
                    ),
                    obscureText: true,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.02,
                    ) ,
                  ),
                  CustomButton(
                    onPressed: () {
                      print(_formKey.currentState);
                      if (_formKey.currentState!.validate()) {
                        _registerUser(context);
                      }
                    },
                    text: 'REGISTER',
                  ),
                  if (_error != null)
                    Text(
                      _error,
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
          ),
      ),
    );
  }
}