import 'package:flutter/material.dart';

class Waiting extends StatelessWidget {
  final Function func;

  Waiting({this.func});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text("Other Player dont't want to play again",
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w500,
          )),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            func();
          },
          child: Text("OK"),
        )
      ],
    );
  }
}
