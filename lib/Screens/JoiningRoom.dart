import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tictactoe/Screens/OnlinePlay.dart';
import 'package:tictactoe/blocstreams/bloc.dart';

class JoiningRoom extends StatefulWidget {
  final Socket socket;
  final Bloc bloc;
  JoiningRoom({this.socket, this.bloc});

  @override
  _JoiningRoomState createState() => _JoiningRoomState();
}

class _JoiningRoomState extends State<JoiningRoom> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.bloc.joinStream.listen((event) {
      if (event == true) {
        print("Join Sucessfull");
        if (mounted) {
          FocusScope.of(context).unfocus();
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) => OnlinePlay(
                    joiningCode: _controller.text.toString(),
                    bloc: widget.bloc,
                    sockets: widget.socket,
                    playerNo: 2,
                  )));
        }
      } else {
        print("No Room Found");
      }
    });
  }

  void onJoin(BuildContext context) {
    widget.socket.emit("waitingplayers", _controller.text);
    print(_controller.text);
    widget.bloc.codeController.add(_controller.text.toString());
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
        child: SingleChildScrollView(
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
              Container(
                height: size.height / 14,
                width: size.width / 1.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Container(
                  height: size.height / 14,
                  width: size.width / 1.5,
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Joining Code",
                      hintStyle: TextStyle(
                        fontSize: size.width / 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: size.height / 30,
              ),
              GestureDetector(
                onTap: () => onJoin(context),
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                  child: Container(
                    height: size.height / 18,
                    width: size.width / 3.4,
                    alignment: Alignment.center,
                    child: Text(
                      "Enter",
                      style: TextStyle(
                        fontSize: size.width / 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
