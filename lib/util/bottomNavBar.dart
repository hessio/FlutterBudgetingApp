import 'package:flutter/material.dart';
import 'package:tryagain/Screens/ChatScreen.dart';
import 'package:tryagain/widgets/bardBudget.dart';
import 'package:tryagain/widgets/budgetScreen.dart';

import 'constants.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int initialIndex;

  CustomBottomNavigationBar({this.initialIndex = 0});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: kColorPrimaryVariant,
      selectedItemColor: kSecondaryColor,
      unselectedItemColor: kSecondaryColor,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          print(index);
          _currentIndex = index;

        });
        switch (index) {
          case 0:
            Navigator.push(context, MaterialPageRoute(builder: (context) => BudgetScreen()));
            _currentIndex = 0;
            setState(() {
              print(index);
              _currentIndex = 0;
            });
            break;
          case 1:
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatPage()));
            _currentIndex = 1;
            setState(() {
              print(index);
              _currentIndex = 1;
            });
            break;
          case 2:
            Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage(userId: 'userId')));
            _currentIndex = 2;
            setState(() {
              print(index);
              _currentIndex = 2;
            });
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.money),
          label: 'Page 1',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Page 2',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Page 3',
        ),
      ],
    );
  }
}
