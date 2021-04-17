import 'package:flutter/material.dart';

import 'array_2d.dart';

typedef void PositionCallback(Pair<int, int> position);

class GameBoard extends StatelessWidget {
  final Array2D lifeArray;
  final PositionCallback? positionCallback;
  const GameBoard({Key? key, required this.lifeArray, this.positionCallback})
      : super(key: key);

  Widget get aliveCell => AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: Colors.grey[300],
          padding: EdgeInsets.all(0.3),
          child: Container(
            color: Colors.yellow,
          ),
        ),
      );

  Widget get deadCell => AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: Colors.grey[300],
          padding: EdgeInsets.all(0.3),
          child: Container(
            color: Colors.grey,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        lifeArray.width,
        (x) => Flexible(
          child: Row(
            children: List.generate(
              lifeArray.height,
              (y) {
                var pair = Pair(x, y);
                return Flexible(
                  child: GestureDetector(
                      onTap: () {
                        if (positionCallback != null) {
                          positionCallback!(pair);
                        }
                      },
                      child: lifeArray[pair] == 0 ? deadCell : aliveCell),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
