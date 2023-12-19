import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';

class Shape {
  Offset position = const Offset(0, 0);
  Size scale = const Size(1, 1);
  double rotation = 0;
  List<Offset> vertices = [];
  double strokeWidth = 10;
  Color strokeColor = CDKTheme.black;

  Shape();

  void setPosition(Offset newPosition) {
    position = newPosition;
  }

  void setScale(Size newScale) {
    scale = newScale;
  }

  void setRotation(double newRotation) {
    rotation = newRotation;
  }

  void addPoint(Offset point) {
    vertices.add(Offset(point.dx, point.dy));
  }

  void addRelativePoint(Offset point) {
    vertices.add(Offset(point.dx - position.dx, point.dy - position.dy));
  }

  void setStrokeWidth(double width) {
    strokeWidth = width;
  }

  void setStrokeColor(Color color) {
    strokeColor = color;
  }
}
