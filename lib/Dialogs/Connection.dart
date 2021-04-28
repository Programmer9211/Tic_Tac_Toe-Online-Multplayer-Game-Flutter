import 'package:flutter/material.dart';

class ConnectionLost extends StatelessWidget {
  final Function func;
  final int playerNo;
  ConnectionLost({this.func, this.playerNo});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Connection Lost",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),
      content: Text(
        playerNo == 1
            ? "Player 1's Connection lost"
            : "Player 2's Connection lost",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              func();
            },
            child: Text("OK"))
      ],
    );
  }
}
