import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/Screens/HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs));
}

class MyApp extends StatelessWidget {
  final prefs;
  MyApp(this.prefs);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: HomePage(prefs: prefs),
    );
  }
}
