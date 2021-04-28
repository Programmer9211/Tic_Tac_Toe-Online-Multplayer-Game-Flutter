import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/Screens/Options.dart';
import 'package:tictactoe/Screens/Play.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tictactoe/blocstreams/bloc.dart';

class HomePage extends StatefulWidget {
  final SharedPreferences prefs;
  HomePage({this.prefs});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  IO.Socket sockets;
  Bloc bloc = Bloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.prefs.setString("name", "");
    connectToScoket();
  }

  void connectToScoket() {
    sockets = IO.io('http://192.168.43.225:8080', <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false
    });

    sockets.connect();
    print(sockets.connected);

    sockets.onConnect((data) {
      print("connected");

      bloc.newCodeStream.listen((newCode) {
        sockets.on(newCode, (playerInfo) {
          bloc.playerInfoController.add(playerInfo);
        });
      });

      bloc.codeStream.listen((code) {
        sockets.on(code, (data) {
          if (data) {
            sockets.emit("cancel", code);
          } else {}
          print(data);

          bloc.joinController.add(data);
        });
      });
    });

    if (widget.prefs.getString('name').isNotEmpty) {
      sockets.emit("name", widget.prefs.getString('name'));
    }
  }

  void onSinglePlayer() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlayScreen()));
  }

  void onMultiplayer() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => Options(
              sockets: sockets,
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
            customButton(size, "Single Player", onSinglePlayer),
            SizedBox(
              height: size.height / 20,
            ),
            customButton(size, "MultiPlayer", onMultiplayer),
            SizedBox(
              height: size.height / 10,
            ),
            Material(
              elevation: 5,
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                height: size.height / 14,
                width: size.height / 14,
                child: Icon(
                  Icons.settings,
                  size: size.width / 12,
                ),
              ),
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
              fontSize: size.width / 16,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
