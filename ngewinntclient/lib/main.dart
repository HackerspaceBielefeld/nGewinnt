import 'package:flutter/material.dart';
import 'package:ngewinntclient/providers/game_state_provider.dart';
import 'package:provider/provider.dart';

import 'models/game_model.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<GameStateProvider>(
        create: (_) => GameStateProvider(endpoint: 'http://<SERVER>:<PORT>/game/0/')),
  ], child: const NGewinntClientApp()));
}

class NGewinntClientApp extends StatelessWidget {
  const NGewinntClientApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGewinnt',
      theme: ThemeData(primarySwatch: Colors.orange, scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255)),
      home: const GameMainScreen(),
    );
  }
}

class GameMainScreen extends StatefulWidget {
  const GameMainScreen({Key? key}) : super(key: key);

  @override
  State<GameMainScreen> createState() => _GameMainScreenState();
}

String _printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

class _GameMainScreenState extends State<GameMainScreen> {
  TextStyle scoreBoardNum = const TextStyle(fontSize: 50, fontWeight: FontWeight.bold);
  TextStyle scoreBoardTeam = const TextStyle(fontSize: 35, fontWeight: FontWeight.bold);

  TextStyle scoreBoardTimeLeft = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  TextStyle scoreBoardGameTime = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    context.read<GameStateProvider>().start();
  }

  Widget buildHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: Consumer<GameStateProvider>(builder: (context, gamestate, child) {
            if (gamestate.ng == null) {
              return Container();
            }
            if (gamestate.ng!.round == null) {
              return Container();
            }
            if (gamestate.ng!.round!.currentSection == null) {
              return Container();
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Verbleibend:',
                    style: scoreBoardTimeLeft,
                  ),
                  Text(
                    gamestate.ng!.round!.currentSection!.timeLeft.toString() + ' Sek.',
                    style: scoreBoardTimeLeft,
                  ),
                ],
              ),
            );
          })),
          Expanded(
              flex: 2,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.red,
                          border: Border.all(
                            color: Colors.red,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Rot',
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                          )),
                    ),
                  ))),
          Expanded(
            flex: 4,
            child: Column(
              //mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer<GameStateProvider>(builder: (context, gamestate, child) {
                  Color boxColor = Colors.white;
                  String boxText = "";

                  if (gamestate.ng == null) {
                    boxText = "---";
                  } else {
                    if (gamestate.ng!.round == null) {
                      boxColor = Colors.yellow;
                      boxText = "Runde nicht gestartet";
                    } else {
                      if (gamestate.ng!.round!.currentSection == null) {
                        boxColor = Colors.yellow;
                        boxText = "warten ...";
                      } else if (!gamestate.ng!.round!.currentSection!.started) {
                        boxColor = Colors.yellow;
                        boxText = "warten ...";
                      } else if (gamestate.ng!.round!.currentSection!.finished) {
                        switch (gamestate.ng!.round!.winner) {
                          case GameTeam.teamA:
                            {
                              boxColor = Colors.redAccent;
                              boxText = "Rot hat gewonnen!";
                              break;
                            }
                          case GameTeam.teamB:
                            {
                              boxColor = Colors.blueAccent;
                              boxText = "Blau hat gewonnen!";
                              break;
                            }
                          default:
                            {}
                        }
                      } else {
                        switch (gamestate.ng!.round!.currentSection!.team) {
                          case GameTeam.teamA:
                            {
                              boxColor = Colors.redAccent;
                              boxText = "Rot ist dran!";
                              break;
                            }
                          case GameTeam.teamB:
                            {
                              boxColor = Colors.blueAccent;
                              boxText = "Blau ist dran!";
                              break;
                            }
                          default:
                            {}
                        }
                      }
                    }
                  }

                  return Container(
                      decoration: BoxDecoration(
                          color: boxColor,
                          border: Border.all(
                            color: boxColor,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Center(
                          child: Text(
                        boxText,
                        style: scoreBoardTeam,
                      )));
                }),
                Center(
                  child: Consumer<GameStateProvider>(builder: (context, gamestate, child) {
                    if (gamestate.ng == null) {
                      return Text(
                        '-:-',
                        style: scoreBoardNum,
                      );
                    }
                    return Text(
                      gamestate.ng!.score[GameTeam.teamA].toString() +
                          ':' +
                          gamestate.ng!.score[GameTeam.teamB].toString(),
                      style: scoreBoardNum,
                    );
                  }),
                ),
              ],
            ),
          ),
          Expanded(
              flex: 2,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          border: Border.all(
                            color: Colors.blue,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Blau',
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                          )),
                    ),
                  ))),
          Expanded(child: Consumer<GameStateProvider>(builder: (context, gamestate, child) {
            if (gamestate.ng == null) {
              return Container();
            }
            if (gamestate.ng!.round == null) {
              return Container();
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    'Spielzeit:',
                    style: scoreBoardGameTime,
                  ),
                  Text(
                    _printDuration(Duration(seconds: gamestate.ng!.round!.timeConsumed)),
                    style: scoreBoardGameTime,
                  ),
                ],
              ),
            );
          })),
        ],
      ),
    );
  }

  Widget buildSideNav(BuildContext context) {
    return Consumer<GameStateProvider>(builder: (context, gamestate, child) {
      return Column(children: [
        Image.asset(
          'assets/img/logo.png',
          width: 300,
        ),
        Divider(),
        DefaultTextStyle(
            style: TextStyle(fontSize: 40, color: Colors.black),
            child: Table(
              columnWidths: {0: FixedColumnWidth(250), 1: FixedColumnWidth(350)},
              children: [
                TableRow(children: [
                  Text(
                    'Team Rot:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  gamestate.ng != null ? Text(gamestate.ng!.phoneRed) : const CircularProgressIndicator()
                ], decoration: BoxDecoration(color: Colors.red[200])),
                TableRow(children: [Divider(), Divider()]),
                TableRow(children: [
                  Text(
                    'Team Blau:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  gamestate.ng != null ? Text(gamestate.ng!.phoneBlue) : const CircularProgressIndicator()
                ], decoration: BoxDecoration(color: Colors.blue[200])),
              ],
            ))
      ]);
    });
  }

  Widget tableHeaderPercentage(BuildContext context, GameStateProvider gamestate, int colidx) {
    double textopacity = 1;
    if (gamestate.ng!.round!.currentSection != null) {
      textopacity = (1 / 4) + (gamestate.ng!.round!.currentSection!.getPercentage(colidx) / 100 / 4 * 3);
    }

    TextStyle textdefaultstyle = TextStyle(color: Colors.deepOrange.withOpacity(textopacity));
    return Column(
      children: [
        Text(
          gamestate.ng!.round!.currentSection == null
              ? '0'
              : gamestate.ng!.round!.currentSection!.vote[colidx].toString(),
          style: textdefaultstyle,
        ),
        Text(
          ' Stimmen',
          style: textdefaultstyle,
        ),
        Text(
          '(' +
              (gamestate.ng!.round!.currentSection == null
                  ? '0.0'
                  : gamestate.ng!.round!.currentSection!.getPercentage(colidx).toStringAsFixed(1)) +
              '%)',
          style: textdefaultstyle,
        ),
      ],
    );
  }

  Widget buildTable() {
    final double boxWidth = 80;
    final double boxHeight = boxWidth;

    return Consumer<GameStateProvider>(
      builder: (context, gamestate, child) {
        if (gamestate.ng == null) {
          return Center(
            child: Image.asset('assets/img/howto.png'),
          );
        }

        if (gamestate.ng!.round == null) {
          return Center(
            child: Image.asset('assets/img/howto.png'),
          );
        }

        List<TableRow> rows = [];

        List<List<Widget>> headCols = [[], []];
        for (int colidx = 0; colidx < gamestate.ng!.columns; colidx++) {
          headCols[0].add(SizedBox(
            width: boxWidth,
            height: boxHeight / 2,
            child: Container(
                decoration: BoxDecoration(border: Border.all()),
                child: FittedBox(
                  child: Text(
                    (colidx + 1).toString(),
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                  fit: BoxFit.contain,
                )),
          ));

          headCols[1].add(SizedBox(
            width: boxWidth,
            height: boxHeight,
            child: Container(
                decoration: BoxDecoration(border: Border.all()),
                child: FittedBox(
                  child: tableHeaderPercentage(context, gamestate, colidx),
                  fit: BoxFit.contain,
                )),
          ));
        }
        rows.add(TableRow(children: headCols[0]));
        rows.add(TableRow(children: headCols[1]));

        List<List<GameTeam>> gamefield = gamestate.ng!.round!.gamefield;

        for (int rowidx = gamestate.ng!.rows - 1; rowidx >= 0; rowidx--) {
          List<Widget> rowCols = [];
          for (int colidx = 0; colidx < gamestate.ng!.columns; colidx++) {
            Widget rowCol;
            switch (gamefield[colidx][rowidx]) {
              case GameTeam.teamA:
                {
                  /*
                  rowCol = Text(
                    'X',
                    style: TextStyle(color: Colors.red),
                  );
                  */
                  rowCol = Image.asset('assets/img/rot.png');
                  break;
                }
              case GameTeam.teamB:
                {
                  /*
                  rowCol = Text(
                    'O',
                    style: TextStyle(color: Colors.blue),
                  );
                  */
                  rowCol = Image.asset('assets/img/blau.png');
                  break;
                }
              case GameTeam.draw:
              case GameTeam.noTeam:
                {
                  rowCol = Text('');
                  break;
                }
            }
            //rowCols.add(rowCol);

            rowCols.add(
              SizedBox(
                width: boxWidth,
                height: boxHeight,
                child: Container(
                    decoration: BoxDecoration(border: Border.all()),
                    child: FittedBox(
                      child: rowCol,
                      fit: BoxFit.fitHeight,
                    )),
              ),
            );
            /**/
          }
          rows.add(TableRow(children: rowCols));
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Table(
            defaultColumnWidth: FixedColumnWidth(100.0),
            //defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: TableBorder(borderRadius: BorderRadius.all(Radius.circular(1))),
            children: rows,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(context),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(child: buildTable()),
            buildSideNav(context),
          ],
        )
      ],
    ));
  }
}
