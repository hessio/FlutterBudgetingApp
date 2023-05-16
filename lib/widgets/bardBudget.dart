import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyClass {
  final String title;
  final List<MyClass> myList;

  MyClass({required this.title, required this.myList});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'myList': myList.map((item) => item.toMap()).toList(),
    };
  }

  factory MyClass.fromMap(Map<String, dynamic> map) {
    return MyClass(
      title: map['title'],
      myList: List<MyClass>.from(map['myList'].map((item) => MyClass.fromMap(item))),
    );
  }
}

class MyPage extends StatefulWidget {
  final String userId;

  MyPage({required this.userId});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  List<MyClass> _myList = [];

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  String _getKey() {
    return 'myListKey_${widget.userId}';
  }

  Future<void> _loadList() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey();
    final value = prefs.getString(key);
    if (value == null) {
      setState(() {
        _myList = [];
      });
    } else {
      final List<dynamic> mapList = json.decode(value);
      setState(() {
        _myList = List<MyClass>.from(mapList.map((item) => MyClass.fromMap(item)));
      });
    }
  }

  Future<void> _saveList() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKey();
    final value = _myList.map((item) => item.toMap()).toList();
    prefs.setString(key, json.encode(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _myList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_myList[index].title),
                  subtitle: Text('${_myList[index].myList.length} items'),
                  onTap: () {
                    // Navigate to detail page
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _myList.add(MyClass(
                  title: 'New List',
                  myList: [],
                ));
              });
              _saveList();
            },
            child: Text('Add New List'),
          ),
        ],
      ),
    );
  }
}
