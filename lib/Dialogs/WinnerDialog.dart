import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/Screens/JoiningRoom.dart';
import 'package:tictactoe/Screens/OnlinePlay.dart';
import 'package:tictactoe/Screens/Options.dart';
import 'package:tictactoe/Screens/WaitingRoom.dart';
import 'package:tictactoe/blocstreams/bloc.dart';

class WinnerDialog extends StatefulWidget {
  final int playerNo, winner;
  final Socket socket;
  final String joiningCode;
  final Bloc bloc;
  WinnerDialog(
      {this.winner, this.playerNo, this.socket, this.joiningCode, this.bloc});

  @override
  _WinnerDialogState createState() => _WinnerDialogState();
}

class _WinnerDialogState extends State<WinnerDialog> {
  @override
  void initState() {
    super.initState();
    widget.bloc.joinStream.listen((event) {
      if (mounted) {
        if (event) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => OnlinePlay(
                    joiningCode: widget.joiningCode.toString(),
                    bloc: widget.bloc,
                    sockets: widget.socket,
                    playerNo: 2,
                  )));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => WaitingRoom(
                    joiningCode: widget.joiningCode,
                    bloc: widget.bloc,
                    sockets: widget.socket,
                    fromplayagain: true,
                  )));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.winner == widget.playerNo ? "You Win" : "You Loose",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),
      content: Text(
        "Want to play again ??",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => Options(
                      sockets: widget.socket,
                      bloc: widget.bloc,
                    ),
                  ),
                ),
            child: Text("No")),
        TextButton(
            onPressed: () {
              widget.socket
                  .emit("waitingplayers", widget.joiningCode.toString());
              widget.bloc.codeController.add(widget.joiningCode.toString());
            },
            child: Text("Yes"))
      ],
    );
  }
}
