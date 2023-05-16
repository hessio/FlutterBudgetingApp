import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExpenseCategory {
  String title;
  List<Expense> expenses;

  ExpenseCategory({
    required this.title,
    required this.expenses,
  });
}

class Expense{
  // String category;
  String title;
  double amount;

  Expense({
    required this.title, required this.amount
  });
}


class BudgetScreen extends StatefulWidget {
  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<BudgetScreen> {
  List<ExpenseCategory> _expenseCategories = [ExpenseCategory(title: 'Bills', expenses: [Expense(title: 'Rent', amount: 1000), Expense(title: 'Utilities', amount: 200),],
  ),
    ExpenseCategory(
      title: 'Groceries',
      expenses: [
        Expense(title: 'Milk', amount: 3.50),
        Expense(title: 'Bread', amount: 2.00),
      ],
    ),
  ];
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  void _addNewExpense(int categoryIndex) {
    setState(() {
      // print('add new Expense ${}')
      _expenseCategories[categoryIndex].expenses.add(
        Expense(title: 'New Expense', amount: 0.0),
      );
    });
  }

  void _addNewCategory(ExpenseCategory newCategory) {
    setState(() {
      _expenseCategories.add(
        newCategory
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Budget'),
      ),
      body: ListView.builder(
        itemCount: _expenseCategories.length,
        itemBuilder: (context, categoryIndex) {
          final category = _expenseCategories[categoryIndex];
          return Column(
            children: [
              ListTile(
                title: Text(category.title),
                trailing: Text(
                  category.expenses.fold(
                    0.0,
                        (previousValue, expense) => previousValue + expense.amount,
                  ).toString(),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: category.expenses.length,
                itemBuilder: (context, expenseIndex) {
                  final expense = category.expenses[expenseIndex];
                  return ListTile(
                    title: Text(expense.title),
                    trailing: Text(expense.amount.toString()),
                    onTap: () {
                      // Edit expense
                    },
                  );
                },
              ),
              ElevatedButton(
                onPressed: () => _addNewExpense(categoryIndex),
                child: const Text('Add New Expense'),
              ),
              ElevatedButton(
                onPressed: () {
                  print('aletDialog');
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
                            onPressed: () =>
                                Navigator.of(context).pop(),
                          ),
                          ElevatedButton(
                            child: const Text('Save'),
                            onPressed: () {
                              setState(() {
                                final e = [
                                  Expense(title: titleController.text,
                                      amount: double.parse(
                                          amountController.text))
                                ];
                                final ec = ExpenseCategory(
                                    title: titleController.text, expenses: e);
                                _addNewCategory(ec);
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                    );
                  },
                child: const Text('Add New Expense'),
              ),
            ],
          );
        },
      ),
    );
  }
}

