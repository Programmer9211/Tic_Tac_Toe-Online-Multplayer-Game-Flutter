import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/Dialogs/WaitingDialog.dart';
import 'package:tictactoe/Screens/OnlinePlay.dart';
import 'package:tictactoe/blocstreams/bloc.dart';

class WaitingRoom extends StatefulWidget {
  final String joiningCode;
  final Socket sockets;
  final Bloc bloc;
  final bool fromplayagain;

  WaitingRoom({this.joiningCode, this.sockets, this.bloc, this.fromplayagain});

  @override
  _WaitingRoomState createState() => _WaitingRoomState();
}

class _WaitingRoomState extends State<WaitingRoom> with WidgetsBindingObserver {
  Timer timer;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      widget.sockets.emit("cancel", widget.joiningCode.toString());
    } else {}
  }

  void initTimer() {
    if (widget.fromplayagain) {
      timer = Timer(Duration(seconds: 10), () {
        showDialog(context: context, builder: (_) => Waiting(func: onCancel));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initTimer();
    widget.sockets.emit(
        "code", {"name": "Aditya", "code": widget.joiningCode.toString()});
    widget.bloc.codeController.add(widget.joiningCode.toString());
    widget.bloc.joinStream.listen((event) {
      if (event) {
        onJoiningSucessfull();
      } else {
        print("No Room Found");
      }
    });
  }

  void onJoiningSucessfull() {
    print("join Sucessfull");

    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => OnlinePlay(
                joiningCode: widget.joiningCode.toString(),
                bloc: widget.bloc,
                sockets: widget.sockets,
                playerNo: 1,
              )));
    }
  }

  void onCancel() {
    Navigator.pop(context);
    widget.sockets.emit("cancel", widget.joiningCode.toString());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      child: Scaffold(
        body: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(251, 136, 22, 1),
                Color.fromRGBO(246, 80, 100, 1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: size.height / 8,
              ),
              Container(
                height: size.height / 2.5,
                width: size.width,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage("assets/img.png"),
                  //fit: BoxFit.cover,
                )),
              ),
              Text(
                "Code : ${widget.joiningCode}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width / 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: size.height / 5,
              ),
              CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Waiting for other player to join...",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width / 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onCancel,
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  child: Container(
                    height: size.height / 17,
                    width: size.width / 2.4,
                    alignment: Alignment.center,
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: size.width / 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      onWillPop: () {
        widget.sockets.emit("cancel", widget.joiningCode.toString());
        Navigator.pop(context);
      },
    );
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
