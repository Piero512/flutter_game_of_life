import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_of_life/game_board.dart';

import 'array_2d.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Conway's Game of Life simulation",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Conway's Game of Life in Flutter!"),
        ),
        body: GameOfLifeBoard(width: 20, height: 20),
      ),
    );
  }
}

class GameOfLifeBoard extends StatefulWidget {
  final int width;
  final int height;

  const GameOfLifeBoard({required this.width, required this.height});

  @override
  _GameOfLifeBoardState createState() => _GameOfLifeBoardState();
}

class _GameOfLifeBoardState extends State<GameOfLifeBoard> {
  late Array2D lifeArray = Array2D(widget.width, widget.height);
  Timer? simulationTimer;
  double value = 0.5;

  Duration get simulationTick =>
      Duration(milliseconds: (1000 - (1000 * value)).round());

  bool get running => simulationTimer != null;
  @override
  void dispose() {
    super.dispose();
    simulationTimer?.cancel();
  }

  @override
  void didUpdateWidget(GameOfLifeBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.height != oldWidget.height || widget.width != oldWidget.width) {
      lifeArray = Array2D(widget.height, widget.width);
      simulationTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSimulationSpeedControl(),
                  if (constraints.maxWidth > constraints.maxHeight)
                    ..._buildSimulationControls(),
                  if (constraints.maxWidth > constraints.maxHeight)
                    statusWidget,
                ].map((widget) => Flexible(child: widget)).toList(),
              ),
            ),
            Expanded(
              child: AspectRatio(
                aspectRatio: widget.width / widget.height,
                child: GameBoard(
                  lifeArray: lifeArray,
                  positionCallback: (pos) => setState(() {
                    lifeArray[pos] = lifeArray[pos] == 0 ? 1 : 0;
                  }),
                ),
              ),
            ),
            if (constraints.maxWidth < constraints.maxHeight)
              Flexible(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: ([statusWidget] + _buildSimulationControls())
                      .map((e) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: e,
                          ))
                      .toList(),
                ),
              )
          ],
        );
      },
    );
  }

  Widget get statusWidget {
    return Text("Status: ${simulationTimer != null ? 'Running' : 'Stopped'}");
  }

  Widget _buildSimulationSpeedControl() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Simulation speed:"),
        Expanded(
          child: Slider.adaptive(
            value: value,
            onChangeStart: (_) => _stopSimulation(),
            onChangeEnd: (_) => _startSimulation(),
            onChanged: (newVal) {
              setState(() {
                value = newVal;
              });
            },
          ),
        )
      ],
    );
  }

  void _randomize() {
    setState(() {
      var rnd = Random();
      for (var x in List.generate(lifeArray.width, (index) => index)) {
        for (var y in List.generate(lifeArray.height, (index) => index)) {
          lifeArray[Pair(x, y)] = rnd.nextBool() ? 1 : 0;
        }
      }
    });
  }

  void _tick() {
    var newBoard = Array2D(lifeArray.width, lifeArray.height);
    bool isEmpty = true;
    for (var x in List.generate(lifeArray.width, (i) => i)) {
      for (var y in List.generate(lifeArray.height, (i) => i)) {
        var currentCell = Pair(x, y);
        var slice = lifeArray.slice(
          from: Pair(max(0, x - 1), max(0, y - 1)),
          to: Pair(
            min(lifeArray.width - 1, x + 2),
            min(lifeArray.height - 1, y + 2),
          ),
        );
        var neighbourCount = slice.sum();

        if (lifeArray[currentCell] == 0) {
          // Dead cell
          if (neighbourCount == 3) {
            newBoard[currentCell] = 1;
            isEmpty = false;
          } else {
            newBoard[currentCell] = 0;
          }
        } else {
          neighbourCount -= 1; // Remove self cell from aliveCount.
          if (neighbourCount >= 2 && neighbourCount <= 3) {
            newBoard[currentCell] = 1;
            isEmpty = false;
          } else {
            newBoard[currentCell] = 0;
          }
        }
      }
    }
    if (isEmpty) {
      _stopSimulation();
    }
    setState(() {
      lifeArray = newBoard;
    });
  }

  void _startSimulation() {
    if (simulationTimer == null) {
      simulationTimer = Timer.periodic(simulationTick, (_) => _tick());
    }
  }

  void _stopSimulation() {
    simulationTimer?.cancel();
    setState(() {
      simulationTimer = null;
    });
  }

  void _clear() {
    setState(() {
      lifeArray = Array2D.fromIterable(
          List.generate(widget.width * widget.height, (_) => 0),
          widget.width,
          widget.height);
    });
  }

  List<Widget> _buildSimulationControls() {
    return [
      ElevatedButton(
          onPressed: running ? _stopSimulation : _startSimulation,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(running ? Icons.pause : Icons.play_arrow),
              SizedBox(
                width: 5,
              ),
              Text(
                running ? "Pause Simulation" : "Start simulation",
                softWrap: true,
              ),
            ],
          )),
      ElevatedButton(onPressed: _randomize, child: Text("Randomize")),
      ElevatedButton(onPressed: _tick, child: Text("Step")),
      ElevatedButton(
        onPressed: _clear,
        child: Text("Clear area"),
      )
    ];
  }
}
