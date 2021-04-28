import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/Dialogs/Connection.dart';
import 'package:tictactoe/Dialogs/WinnerDialog.dart';
import 'package:tictactoe/Models/GameModel.dart';
import 'package:tictactoe/blocstreams/bloc.dart';
import 'package:tictactoe/main.dart';

class OnlinePlay extends StatefulWidget {
  final String joiningCode;
  final Socket sockets;
  final Bloc bloc;
  final int playerNo;
  OnlinePlay({this.joiningCode, this.sockets, this.bloc, this.playerNo});

  @override
  _OnlinePlayState createState() => _OnlinePlayState();
}

class _OnlinePlayState extends State<OnlinePlay> with WidgetsBindingObserver {
  List<GameButton> buttonList;
  List<int> player1;
  List<int> player2;
  List<int> tapRecord;
  int activeplayer;
  int turn = 1;
  Timer timer, perodicTimer;
  int sec = 20;
  bool isMe = false;
  int lostPlayer = 0;

  void initTimer() {
    if (widget.playerNo == turn) {
      Random _random = Random();

      int id = tapRecord[_random.nextInt(tapRecord.length)];

      timer = Timer(
        Duration(seconds: 20),
        () {
          onTap(GameButton(id: id));
        },
      );
    }
    perodicTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        sec = sec - 1;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print(state);
    if (state == AppLifecycleState.resumed) {
    } else {
      onPop();
    }
  }

  @override
  void initState() {
    super.initState();
    tapRecord = [];
    for (int i = 1; i <= 9; i++) {
      tapRecord.add(i);
    }

    buttonList = initButtonList();
    activeplayer = 1;
    player1 = [];
    player2 = [];
    initTimer();
    widget.bloc.newCodeController.add(widget.joiningCode + "1");
    widget.bloc.playerInfoStream.listen((map) {
      getResponseFromOtherPlayer(map);
    });
    WidgetsBinding.instance.addObserver(this);
  }

  void getResponseFromOtherPlayer(map) {
    if (mounted) {
      print(map);
      if (map['isOnline']) {
        if (tapRecord.isNotEmpty) {
          int index = map['buttonId'] - 1;
          setState(() {
            buttonList[index].isEnabled = map['isEnabled'];
            buttonList[index].imageUrl = map['image'];
            turn = map['turn'];
            activeplayer = map['turn'];
            sec = 20;

            if (map['playerNo'] == 1) {
              player1.add(map['buttonId']);
            } else {
              player2.add(map['buttonId']);
            }
            tapRecord.remove(map['buttonId']);
            print("$player1 \n $player2");
            checkResult();
            perodicTimer.cancel();
            if (timer != null) {
              timer.cancel();
            }
            initTimer();
          });
        } else {
          print("Draw");
        }
      } else {
        if (isMe == false) {
          if (timer != null) {
            timer.cancel();
          }
          perodicTimer.cancel();
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => ConnectionLost(
                    playerNo: lostPlayer,
                    func: () {
                      if (mounted) {
                        Navigator.pop(context);
                        widget.sockets.emit(
                          "cancel",
                          widget.joiningCode.toString(),
                        );
                      }
                    },
                  ));
        }
        print("Another Player is offline");
      }
    }
  }

  List<GameButton> initButtonList() {
    List<GameButton> button = [
      GameButton(id: 1),
      GameButton(id: 2),
      GameButton(id: 3),
      GameButton(id: 4),
      GameButton(id: 5),
      GameButton(id: 6),
      GameButton(id: 7),
      GameButton(id: 8),
      GameButton(id: 9),
    ];

    return button;
  }

  void onTap(GameButton gb) {
    if (tapRecord.isNotEmpty) {
      if (activeplayer == 1) {
        setState(() {
          activeplayer = 2;
        });

        Map<String, dynamic> playermap = {
          "code": widget.joiningCode,
          "name": "unknown",
          "buttonId": gb.id,
          "playerNo": widget.playerNo,
          "image": widget.playerNo == 1 ? "assets/o.png" : "assets/x.png",
          "isEnabled": false,
          "turn": activeplayer,
          "isOnline": true,
        };

        widget.sockets.emit("playerinput", playermap);
      } else {
        setState(() {
          activeplayer = 1;
        });

        Map<String, dynamic> playermap = {
          "code": widget.joiningCode,
          "name": "unknown",
          "buttonId": gb.id,
          "playerNo": widget.playerNo,
          "image": widget.playerNo == 1 ? "assets/o.png" : "assets/x.png",
          "isEnabled": false,
          "turn": activeplayer,
          "isOnline": true,
        };

        widget.sockets.emit("playerinput", playermap);
      }
      print(activeplayer);
      print(widget.playerNo);
      checkResult();
    } else {
      print("Draw");
    }
  }

  void checkResult() {
    int winner = 0;

    // For Row 1

    // Player 1
    if (player1.contains(1) && player1.contains(2) && player1.contains(3)) {
      print("Player 1 Wins");
      winner = 1;
    }
    // Player 2
    if (player2.contains(1) && player2.contains(2) && player2.contains(3)) {
      print("Player 2 Wins");
      winner = 2;
    }

    // For Row 2

    //Player 1
    if (player1.contains(4) && player1.contains(5) && player1.contains(6)) {
      print("Player 1 Wins");
      winner = 1;
    }
    // Player 2
    if (player2.contains(4) && player2.contains(5) && player2.contains(6)) {
      print("Player 2 Wins");
      winner = 2;
    }

    // For Row 3

    //Player 1
    if (player1.contains(7) && player1.contains(8) && player1.contains(9)) {
      print("Player 1 Wins");
      winner = 1;
    }
    // Player 2
    if (player2.contains(7) && player2.contains(8) && player2.contains(9)) {
      print("Player 2 Wins");
      winner = 2;
    }

    // For Column 1

    //Player 1
    if (player1.contains(1) && player1.contains(4) && player1.contains(7)) {
      print("Player 1 Wins");
      winner = 1;
    }
    // Player 2
    if (player2.contains(1) && player2.contains(4) && player2.contains(7)) {
      print("Player 2 Wins");
      winner = 2;
    }

    // For Column 2

    //Player 1
    if (player1.contains(2) && player1.contains(5) && player1.contains(8)) {
      print("Player 1 Wins");
      winner = 1;
    }
    // Player 2
    if (player2.contains(2) && player2.contains(5) && player2.contains(8)) {
      print("Player 2 Wins");
      winner = 2;
    }

    // For Column 3

    //Player 1
    if (player1.contains(3) && player1.contains(6) && player1.contains(9)) {
      print("Player 1 Wins");
      winner = 1;
    }
    // Player 2
    if (player2.contains(3) && player2.contains(6) && player2.contains(9)) {
      print("Player 2 Wins");
      winner = 2;
    }

    // For Diagonal 1

    //Player 1
    if (player1.contains(1) && player1.contains(5) && player1.contains(9)) {
      print("Player 1 Wins");
      winner = 1;
    }
    // Player 2
    if (player2.contains(1) && player2.contains(5) && player2.contains(9)) {
      print("Player 2 Wins");
      winner = 2;
    }

    // For Diagonal 2

    //Player 1
    if (player1.contains(3) && player1.contains(5) && player1.contains(7)) {
      print("Player 1 Wins");
      winner = 1;
    }
    // Player 2
    if (player2.contains(3) && player2.contains(5) && player2.contains(7)) {
      print("Player 2 Wins");
      winner = 2;
    }

    if (winner == 1) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WinnerDialog(
          winner: 1,
          socket: widget.sockets,
          bloc: widget.bloc,
          playerNo: widget.playerNo,
          joiningCode: widget.joiningCode,
        ),
      );
    } else if (winner == 2) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WinnerDialog(
          winner: 2,
          socket: widget.sockets,
          bloc: widget.bloc,
          playerNo: widget.playerNo,
          joiningCode: widget.joiningCode,
        ),
      );
    }
  }

  void onPop() {
    setState(() {
      isMe = true;
      lostPlayer = widget.playerNo;
    });
    if (timer != null) {
      timer.cancel();
    }
    perodicTimer.cancel();
    Navigator.pop(context);
    widget.sockets.emit("playerinput", {
      "isOnline": false,
      "code": widget.joiningCode,
      "turn": activeplayer,
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () {
        onPop();
      },
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
              Container(
                height: size.height / 5,
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: size.height / 12,
                          width: size.height / 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Aditya",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      width: size.width / 10,
                    ),
                  ],
                ),
              ),
              Container(
                height: size.height / 2,
                width: size.width / 1.2,
                child: GridView.builder(
                  itemCount: buttonList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: GestureDetector(
                        onTap: () {
                          if (buttonList[index].isEnabled) {
                            if (widget.playerNo == turn) {
                              onTap(buttonList[index]);
                            }
                          }
                        },
                        child: Material(
                          elevation: 2,
                          child: Container(
                            height: size.height / 8,
                            width: size.height / 8,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.white),
                            child: buttonList[index].imageUrl == ""
                                ? null
                                : Image.asset(
                                    buttonList[index].imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                height: size.height / 7,
                width: size.width,
                child: Row(
                  children: [
                    SizedBox(
                      width: size.width / 10,
                    ),
                    Column(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: size.height / 12,
                          width: size.height / 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Aditya",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.height / 15,
              ),
              Text(
                turn == 1
                    ? "Player 1's Turn: $sec sec"
                    : "Player 2's Turn: $sec sec",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (timer != null) {
      timer.cancel();
    }
    perodicTimer.cancel();
    super.dispose();
  }
}
