import 'dart:math';

class Pair<X, Y> {
  final X first;
  final Y second;

  Pair(this.first, this.second);

  @override
  String toString() {
    return "Pair<${first.runtimeType},${second.runtimeType}>($first, $second)";
  }
}


class Array2D {
  final int width;
  final int height;
  late List<int> _backingArray;

  Array2D(this.width, this.height) {
    _backingArray = List.generate(width * height, (index) => 1);
  }

  Array2D.fromIterable(Iterable<int> iter, this.width, this.height): _backingArray = List.from(iter);

  operator [](Pair<int, int> index) {
    return _backingArray[width * index.first + index.second];
  }

  operator []=(Pair<int, int> index, int value) {
    _backingArray[width * index.first + index.second] = value;
  }

  Iterator<int> get rowMayorIterator => _backingArray.iterator;

  int getIndex(int val) => _backingArray[val];

  Array2D slice({required Pair<int, int> from, required Pair<int, int> to}) {
    var sliceWidth = to.first - from.first;
    var sliceHeight =  to.second - from.second;
    List<int> elements = [];
    for(var x = from.first; x < to.first; x++){
      for(var y =  from.second; y < to.second; y++){
        elements.add(this[Pair(x,y)]);
      }
    }
    assert(elements.length == sliceWidth * sliceHeight);
    return Array2D.fromIterable(elements, sliceWidth, sliceHeight);
  }

  int sum(){
    return _backingArray.reduce((value, element) => value + element);
  }

  @override
  String toString() {
    var rows = [];
    for(var y = 0; y < height; y++){
      rows.add(_backingArray.getRange(y * width, (y + 1) * width).join(","));
    }
    var arrayStr = rows.join("\n");
    return "Array2D(width: $width, height: $height)[$arrayStr]";
  }
}
