import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/bottomNavBar.dart';
import '../util/buttons/addButton.dart';
import '../util/constants.dart';

class Expense {
  // String category;
  String title;
  double amount;

  Expense({required this.title, required this.amount});

  Expense.fromJson(Map<String, dynamic> json)
      : amount = json['amount'],
        title = json['title'];

  Map<String, dynamic> toJson() => {'amount': amount, 'title': title};
}

class Category {
  String title;
  List<Expense> expenses;
  // double total;

  Category({
    required this.title,
    required this.expenses,
  });

  Category.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        expenses = (json['expenses'] as List<dynamic>)
            .map((e) => Expense.fromJson(e))
            .toList();

  Map<String, dynamic> toJson() =>
      {'title': title, 'expenses': expenses.map((e) => e.toJson()).toList()};
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetScreen> {
  double _income = 0.0;
  double _expenses = 0.0;
  double _savings = 0.0;
  double _budget = 0.0;
  bool _incomeAdded = false;
  bool isPressed = false;
  final double fontSizeBottom = 13.0;
  NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '€', // Changed currency symbol to €
    decimalDigits: 2,
  );

  final incomeController = TextEditingController();

  List<Category> _expenseCategories = [];
  // [Category(title: 'Bills',
  // expenses: [Expense(title: 'Rent', amount: 1000), Expense(title: 'Utilities', amount: 200)])];

  Future<void> _saveData() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({'${userID}data': _expenseCategories.map((e) => e.toJson()).toList()});
    print('Saving data ${userData.toString()}');
    await prefs.setString(userID, userData);
    _updateBudget();
    _saveIncome();
    _saveExpenses();
  }

  Color _negBudget(){
    return (_income-_expenses)>=0 ? Colors.green : Colors.red;
  }

  Future<void> _saveIncome() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${userID}income', _income.toString());
  }

  Future<void> _saveExpenses() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${userID}expense', _expenses.toString());
  }

  Future<void> _readData() async {
    print('before read data');
    _expenseCategories.forEach((element) {
      print(element.title);
      element.expenses.forEach((exx) {
        print("${exx.title} ,,, ${exx.amount}");
      });
    });
    String userID = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userID);
    if (userData != null) {
      final decoded = json.decode(userData) as Map<String, dynamic>;
      final myList = (decoded['${userID}data'] as List<dynamic>)
          .map((e) => Category.fromJson(e))
          .toList();
      setState(() {
        print(myList);
        _expenseCategories = myList;
      });
    }
    print('\n\n\n\n\n\n');
    print('after read data function');
    _expenseCategories.forEach((element) {
      print(element.title);
      element.expenses.forEach((exx) {
        print("${exx.title} ,,, ${exx.amount}");
      });
    });

    _updateBudget();
    _saveIncome();
    _saveExpenses();
  }

  void _updateBudget() {
    setState(() {
      double __expenses = 0.0;
      print("before check whole list: $_expenses");
      _expenseCategories.forEach((cat) {
        cat.expenses.forEach((expense) {
          __expenses += expense.amount;
        });
      });
      _expenses = __expenses;
      print("expenses: $_expenses");
    });
  }

  String _formattedValue(double val){
    String formattedPrice = currencyFormat.format(val);
    return formattedPrice;
  }

  void _addExpenseCategory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Expense Category'),
          content: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Category name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  Expense todo = Expense(title: 'TO ADD', amount: 0.0);
                  final Category addNewCat = Category(title: controller.text, expenses: [todo]);
                  _expenseCategories.add(addNewCat);
                  _saveData();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addIncome(String income) {
    setState(() {
      _incomeAdded = true;
      print(income);
      _income = double.tryParse(income) ?? 0.0;
    });
  }

  void _editExpense(Expense expense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final titleController = TextEditingController(text: expense.title);
        final amountController = TextEditingController(
            text: expense.amount.toString());
        // print(_expenseCategories.forEach((element) { }));
        return AlertDialog(
          title: const Text('Edit Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Expense name',
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Amount',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  expense.title = titleController.text;
                  expense.amount = double.parse(amountController.text);
                  _saveData();
                  // _updateBudget();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateIncome() async {
    String userID = FirebaseAuth.instance.currentUser!.uid;
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString("${userID}income");
    print("reading user income${userData}");
    _income= double.tryParse(userData!) ?? 0.0;
  }

  void updateBudgetForNewMonth() {
    // Get the current date
    DateTime now = DateTime.now();

    // Check if it's the first day of the month
    if (now.day == 1) {
      // Reset spending limits, update income, etc.
      // ...
      // _income = _income; income continues over to next month

      // Save the updated budget data to persistent storage
      // ...
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _readData();
    _updateIncome();
    // _updateBudget();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.01,
            left: MediaQuery.of(context).size.height * 0.02,
            right: MediaQuery.of(context).size.height * 0.02,
            bottom: MediaQuery.of(context).size.height * 0.016,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Income',
                style:  TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height*0.004,
                ),
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.48,
                    height: MediaQuery.of(context).size.height*0.055,
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        double vert = constraints.maxHeight * 0.1; // 10% of the width
                        double horz = constraints.maxWidth * 0.082; // 10% of the width
                        return TextFormField(
                          keyboardType: TextInputType.number,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: vert,
                              horizontal: horz,
                            ),
                            hintText: 'Enter your income',
                            filled: true,
                            fillColor: kTextFormFieldColor,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                          ),
                          controller: incomeController,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.025,
                  ),
                  Column(
                    children: [
                      AddButton(
                        fontWeight: true,
                        onPressed: () {
                          setState(()  {
                            isPressed = true;
                            _addIncome(incomeController.text);
                            _readData();
                            incomeController.clear();
                          });
                        },
                        text: 'Enter Income',
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height:MediaQuery.of(context).size.height*0.02,
              ),
              const Text(
                'Expense Categories',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height:MediaQuery.of(context).size.height*0.01,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _expenseCategories.length,
                  itemBuilder: (BuildContext context, int index) {
                    final category = _expenseCategories[index].title;
                    final total = _expenseCategories[index].expenses.
                    fold(0.0, (previousValue, element) => previousValue+element.amount);

                    return Container(
                      margin: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height*0.004,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                        color: Colors.grey[850],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height*0.004,
                        ),
                        child:ListTile(
                          title: Text(
                            category,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          trailing: Text(
                            _formattedValue(total),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                final controller = TextEditingController(
                                    text: category);
                                return AlertDialog(
                                  title: const Text('Edit Expense Category'),
                                  content: TextFormField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                      hintText: 'Category name',
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                    ElevatedButton(
                                      child: const Text('Save'),
                                      onPressed: () {
                                        setState(() {
                                          final newCategory = controller.text;
                                          //////////////////////////////////////////////
                                          _expenseCategories[index].title = newCategory;
                                          _saveData();
                                          _saveExpenses();
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ..._expenseCategories[index].expenses.map((e) =>
                                Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: MediaQuery.of(context).size.height*0.004,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0)
                                    ),
                                  ),
                                    child: SizedBox(
                                      height: MediaQuery.of(context).size.height*0.075,
                                      width: MediaQuery.of(context).size.width*0.71,
                                      child: GestureDetector(
                                      onTap: () => _editExpense(e),
                                      child: ListTile(
                                        title: Text(
                                          e.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        trailing: Text(
                                          _formattedValue(e.amount),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                   ),
                                ),
                              ),
                              SizedBox(
                                height:MediaQuery.of(context).size.height*0.01,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width*0.06,
                                ), //The distance you want
                                child: AddButton(
                                  fontWeight: true,
                                  text: 'Add Expense',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        final titleController = TextEditingController();
                                        final amountController = TextEditingController();
                                        return AlertDialog(
                                          title: const Text('Add Expense'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextFormField(
                                                controller: titleController,
                                                decoration: const InputDecoration(
                                                  hintText: 'Expense name',
                                                ),
                                              ),
                                              SizedBox(
                                                height:MediaQuery.of(context).size.height*0.01,
                                              ),
                                              TextFormField(
                                                controller: amountController,
                                                keyboardType: TextInputType.number,
                                                decoration: const InputDecoration(
                                                  hintText: 'Amount',
                                                ),
                                              ),
                                              TextFormField(
                                                controller: amountController,
                                                keyboardType: TextInputType.number,
                                                decoration: const InputDecoration(
                                                  hintText: 'Due By',
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                            ),
                                            AddButton(
                                              fontWeight: false,
                                              text: 'Save',
                                              onPressed: () {
                                                setState(() {
                                                  final expense = Expense(
                                                    // category: category,
                                                    title: titleController.text,
                                                    amount: double.parse(
                                                        amountController.text),
                                                  );
                                                  _expenseCategories.forEach((element) {
                                                    if(element.title == category){
                                                      element.expenses.add(expense);
                                                    }
                                                  });
                                                  _saveData();
                                                });
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                height:MediaQuery.of(context).size.height*0.01,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height*0.004,
                ),
              ),
              AddButton(
                onPressed: _addExpenseCategory,
                text: 'Add Category',
                fontWeight: true,
              ),
              SizedBox(
                height:MediaQuery.of(context).size.height*0.01,
              ),
              Row(
                children: [
                  Expanded(
                    child:Column(
                      children: [
                        const Text(
                          'Income',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _formattedValue(_income),
                          style:  TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSizeBottom,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expanded(
                  //   child: Column(
                  //     children: [
                  //       const Text(
                  //         'Budget',
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //         ),
                  //       ),
                  //       Text(
                  //         _formattedValue(_income),
                  //         style: const TextStyle(
                  //           fontWeight: FontWeight.bold,
                  //           fontSize: 13.0,
                  //           color: Colors.white,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Expanded(
                    child:Column(
                      children: [
                        const Text(
                          'Expenses',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _formattedValue(_expenses),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:Column(
                      children: [
                        const Text(
                          'Balance',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _formattedValue(_income-_expenses),
                          style:  TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSizeBottom,
                            color: _negBudget(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height:MediaQuery.of(context).size.height*0.01,
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(

        ),
      ),
    );
  }
}
