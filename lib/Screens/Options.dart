import 'dart:math';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/Screens/JoiningRoom.dart';
import 'package:tictactoe/Screens/WaitingRoom.dart';
import 'package:tictactoe/blocstreams/bloc.dart';

class Options extends StatelessWidget {
  final Socket sockets;
  final Bloc bloc;
  Options({this.sockets, this.bloc});

  void onCreate(BuildContext context) {
    Random _rand = Random();
    final min = 100000;
    final max = 999999;
    int teamCode = min + _rand.nextInt(max - min);

    print(teamCode);

    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => WaitingRoom(
              joiningCode: teamCode.toString(),
              bloc: bloc,
              fromplayagain: false,
              sockets: sockets,
            )));
  }

  void onJoin(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => JoiningRoom(
              socket: sockets,
              bloc: bloc,
            )));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
            customButton(size, "Create Team Code", () => onCreate(context)),
            SizedBox(
              height: size.height / 20,
            ),
            customButton(size, "Join Team Code", () => onJoin(context)),
            SizedBox(
              height: size.height / 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget customButton(Size size, String text, Function func) {
    return GestureDetector(
      onTap: func,
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        child: Container(
          height: size.height / 14,
          width: size.width / 1.3,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: size.width / 20,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
