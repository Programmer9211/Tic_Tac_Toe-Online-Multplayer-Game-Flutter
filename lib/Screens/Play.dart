import 'package:flutter/material.dart';
import 'package:tictactoe/Models/GameModel.dart';

class PlayScreen extends StatefulWidget {
  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  List<GameButton> buttonList;
  List<int> player1;
  List<int> player2;
  int activeplayer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    buttonList = initButtonList();
    activeplayer = 1;
    player1 = [];
    player2 = [];
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
    setState(() {
      if (activeplayer == 1) {
        gb.imageUrl = "assets/o.png";
        gb.isEnabled = false;
        player1.add(gb.id);
        activeplayer = 2;
      } else {
        gb.imageUrl = "assets/x.png";
        gb.isEnabled = false;
        player1.add(gb.id);
        activeplayer = 1;
      }
    });
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
              height: size.height / 5,
            ),
            Container(
              height: size.height / 1.8,
              width: size.width / 1.2,
              child: GridView.builder(
                itemCount: buttonList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        if (buttonList[index].isEnabled) {
                          onTap(buttonList[index]);
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
          ],
        ),
      ),
    );
  }
}
