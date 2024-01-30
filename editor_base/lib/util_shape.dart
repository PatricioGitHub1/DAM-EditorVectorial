import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';

abstract class Shape {
  Offset position = const Offset(0, 0);
  Size scale = const Size(1, 1);
  double rotation = 0;
  List<Offset> vertices = [];
  double strokeWidth = 10;
  Color strokeColor = CDKTheme.black;
  Color fillColor = Color.fromRGBO(0, 0, 0,0);
  bool isSelected = false;
  bool closed = false;
  
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

  void setNewShapeFillcolor(Color color) {
    fillColor = color;
  }

  void setOffsetByPostion(Offset offset, int index);

  // Converteix la forma en un mapa per serialitzar
  Map<String, dynamic> toMap() {
    return {
      "type": "shape_drawing",
      "object": {
        "position": {"dx": position.dx, "dy": position.dy},
        "vertices": vertices.map((v) => {"dx": v.dx, "dy": v.dy}).toList(),
        "strokeWidth": strokeWidth,
        "strokeColor": strokeColor.value, 
    // Guarda el color com un valor enter
      }
    };
  }

   // Crea una forma a partir d'un mapa
  static Shape fromMap(Map<String, dynamic> map) {
    if (map['type'] != 'shape_drawing') {
      throw Exception('Type is not a shape_drawing');
    }

    var objectMap = map['object'] as Map<String, dynamic>;
    var shape = ShapeDrawing()
      ..setPosition(
          Offset(objectMap['position']['dx'], objectMap['position']['dy']))
      ..setStrokeWidth(objectMap['strokeWidth'])
      ..setStrokeColor(Color(objectMap['strokeColor']));

    if (objectMap['vertices'] != null) {
      var verticesList = objectMap['vertices'] as List;
      shape.vertices =
          verticesList.map((v) => Offset(v['dx'], v['dy'])).toList();
    }

    return shape;
  }


}

class ShapeDrawing extends Shape {
  @override
  void setOffsetByPostion(Offset offset, int position) {
    
  }
  
}

class ShapeLine extends Shape {
  @override
  void setOffsetByPostion(Offset offset, int index) {
    vertices[index] = Offset(offset.dx - position.dx, offset.dy - position.dy);

  }
  
}

class ShapeMultiline extends Shape {
  @override
  void setOffsetByPostion(Offset offset, int index) {
    
  }
  
}

class ShapeRectangle extends Shape {
  @override
  void setOffsetByPostion(Offset offset, int index) {
    vertices[index] = Offset(offset.dx - position.dx, offset.dy - position.dy);
  }
  
}

class ShapeEllipsis extends Shape {
  @override
  void setOffsetByPostion(Offset offset, int index) {
    vertices[index] = Offset(offset.dx - position.dx, offset.dy - position.dy);
  }

}
