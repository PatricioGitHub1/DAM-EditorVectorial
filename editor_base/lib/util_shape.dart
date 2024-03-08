import 'package:editor_base/app_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:xml/xml.dart' as xml;

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
      "type": runtimeType.toString(),
      "object": {
        "position": {"dx": position.dx, "dy": position.dy},
        "vertices": vertices.map((v) => {"dx": v.dx, "dy": v.dy}).toList(),
        "strokeWidth": strokeWidth,
        "strokeColor": strokeColor.value, 
        "fillColor": fillColor.value
    // Guarda el color com un valor enter
      }
    };
  }

   // Crea una forma a partir d'un mapa
  static Shape fromMap(Map<String, dynamic> map) {
    Shape shape;
    switch (map['type']) {
      case 'ShapeDrawing':
        shape = ShapeDrawing();
        break;
      case 'ShapeLine':
        shape = ShapeLine();
        break;
      case 'ShapeMultiline':
        shape = ShapeMultiline();
        break;
      case 'ShapeRectangle':
        shape = ShapeRectangle();
        break;
      case 'ShapeEllipsis':
        shape = ShapeEllipsis();
        break;
      default:
        throw Exception('Type is not a shape_drawing');
    }

    var objectMap = map['object'] as Map<String, dynamic>;

    shape
      ..setPosition(
          Offset(objectMap['position']['dx'], objectMap['position']['dy']))
      ..setStrokeWidth(objectMap['strokeWidth'])
      ..setStrokeColor(Color(objectMap['strokeColor']))
      ..setNewShapeFillcolor(Color(objectMap['fillColor']));

    if (objectMap['vertices'] != null) {
      var verticesList = objectMap['vertices'] as List;
      shape.vertices =
          verticesList.map((v) => Offset(v['dx'], v['dy'])).toList();
    }

    return shape;
  }

  Offset getRectanglePositionSVG(List<Offset> vertexs, double width, double height) {
    Offset temporalPosition;

    if (vertices[0].dx > vertices[1].dx) {
      if (vertices[0].dy < vertices[1].dy) {
        temporalPosition = Offset(position.dx - width, position.dy);
        print("caso 4");
      } else {
        temporalPosition = Offset(position.dx - width, position.dy - height);
        print("caso 1");
      }
        
    } else {
      if (vertices[0].dy > vertices[1].dy) {
        temporalPosition = Offset(position.dx, position.dy - height);
        print("caso 2");
      } else {
        temporalPosition = position;
        print("caso 3");
      }
  
    }

    return temporalPosition;
  }

  xml.XmlElement mapShapeSVG();
}

class ShapeDrawing extends Shape {
  @override
  void setOffsetByPostion(Offset offset, int position) {
    
  }
  
  @override
  xml.XmlElement mapShapeSVG() {
    double strokeOpacity = strokeColor.alpha / 255.0;
    String path = "";

    Offset absoluteCurrentPosition;
    Rect rect = Rect.fromPoints(vertices[0], vertices[1]);
    double width = rect.right - rect.left;
    double height = rect.bottom - rect.top;

    absoluteCurrentPosition = getRectanglePositionSVG(vertices, width, height);

    for (int i = 0; i < vertices.length; i++) {
      if (i == 0) {
        path += "M${absoluteCurrentPosition.dx} ${absoluteCurrentPosition.dy}";

      } else if (vertices[i] == vertices.last && closed) {
        double diffX = vertices[i].dx - vertices[i - 1].dx;
        double diffY = vertices[i].dy - vertices[i - 1].dy;

        absoluteCurrentPosition = Offset(absoluteCurrentPosition.dx + diffX, absoluteCurrentPosition.dy + diffY);

        path += " L${absoluteCurrentPosition.dx} ${absoluteCurrentPosition.dy} Z";

      } else {
        double diffX = vertices[i].dx - vertices[i - 1].dx;
        double diffY = vertices[i].dy - vertices[i - 1].dy;

        absoluteCurrentPosition = Offset(absoluteCurrentPosition.dx + diffX, absoluteCurrentPosition.dy + diffY);

        path += " L${absoluteCurrentPosition.dx} ${absoluteCurrentPosition.dy}";
      }
    }

    var attributes = [
      xml.XmlAttribute(xml.XmlName('d'), path),
      xml.XmlAttribute(xml.XmlName('stroke'), 'rgb(${strokeColor.red},${strokeColor.green},${strokeColor.blue})'),
      xml.XmlAttribute(xml.XmlName('stroke-opacity'), '$strokeOpacity'),
      xml.XmlAttribute(xml.XmlName('stroke-width'), strokeWidth.toString()),
      xml.XmlAttribute(xml.XmlName('opacity'), "1.0"),
      xml.XmlAttribute(xml.XmlName('fill'), 'rgb(${fillColor.red},${fillColor.green},${fillColor.blue})')
    ];
    
    if (closed) {
      double fillOpacity = fillColor.alpha / 255.0;
      attributes.add(xml.XmlAttribute(xml.XmlName('fill-opacity'), '$fillOpacity'));
      
    } else {
      attributes.add(xml.XmlAttribute(xml.XmlName('fill-opacity'), '0.0'));
    }

    var pathElement = xml.XmlElement(xml.XmlName('path'), attributes);

    return pathElement;
  }
}


class ShapeLine extends Shape {
  @override
  void setOffsetByPostion(Offset offset, int index) {
    vertices[index] = Offset(offset.dx - position.dx, offset.dy - position.dy);

  }
  
  @override
  xml.XmlElement mapShapeSVG() {
    Offset temporalPosition;
    Rect rect = Rect.fromPoints(vertices[0], vertices[1]);
    double width = rect.right - rect.left;
    double height = rect.bottom - rect.top;

    // line points
    double x1;
    double y1;
    double x2;
    double y2;

    if (vertices[0].dx > vertices[1].dx) {
      if (vertices[0].dy < vertices[1].dy) {
        temporalPosition = Offset(position.dx - width, position.dy);
        x1 = temporalPosition.dx + width;
        y1 = temporalPosition.dy ;
        x2 = temporalPosition.dx;
        y2 = temporalPosition.dy + height;
        print("caso 4");
      } else {
        temporalPosition = Offset(position.dx - width, position.dy - height);
        x1 = temporalPosition.dx;
        y1 = temporalPosition.dy;
        x2 = temporalPosition.dx + width;
        y2 = temporalPosition.dy + height;
        print("caso 1");
      }
        
    } else {
      if (vertices[0].dy > vertices[1].dy) {
        temporalPosition = Offset(position.dx, position.dy - height);
        x1 = temporalPosition.dx + width;
        y1 = temporalPosition.dy;
        x2 = temporalPosition.dx;
        y2 = temporalPosition.dy + height;
        print("caso 2");
      } else {
        temporalPosition = position;
        x1 = temporalPosition.dx;
        y1 = temporalPosition.dy;
        x2 = temporalPosition.dx + width;
        y2 = temporalPosition.dy + height;
        print("caso 3");
      }
  
    }
    double strokeOpacity = strokeColor.alpha / 255.0;

    var lineElement = xml.XmlElement(xml.XmlName('line'), [
      xml.XmlAttribute(xml.XmlName('x1'), x1.toString()),
      xml.XmlAttribute(xml.XmlName('y1'), y1.toString()),
      xml.XmlAttribute(xml.XmlName('x2'), x2.toString()),
      xml.XmlAttribute(xml.XmlName('y2'), y2.toString()),
      xml.XmlAttribute(xml.XmlName('stroke'), 'rgb(${strokeColor.red},${strokeColor.green},${strokeColor.blue})'),
      xml.XmlAttribute(xml.XmlName('stroke-opacity'), '$strokeOpacity'),
      xml.XmlAttribute(xml.XmlName('stroke-width'), strokeWidth.toString()),
      xml.XmlAttribute(xml.XmlName('opacity'), "1.0")
    ]);

    return lineElement;
  }
  
}

class ShapeMultiline extends Shape {
  @override
  void setOffsetByPostion(Offset offset, int index) {
    
  }
  
  @override
  xml.XmlElement mapShapeSVG() {
    double strokeOpacity = strokeColor.alpha / 255.0;
    String path = "";

    Offset absoluteCurrentPosition;
    Rect rect = Rect.fromPoints(vertices[0], vertices[1]);
    double width = rect.right - rect.left;
    double height = rect.bottom - rect.top;

    absoluteCurrentPosition = getRectanglePositionSVG(vertices, width, height);

    for (int i = 0; i < vertices.length; i++) {
      if (i == 0) {
        path += "${absoluteCurrentPosition.dx},${absoluteCurrentPosition.dy}";

      } else {

        double diffX = vertices[i].dx - vertices[i - 1].dx;
        double diffY = vertices[i].dy - vertices[i - 1].dy;

        absoluteCurrentPosition = Offset(absoluteCurrentPosition.dx + diffX, absoluteCurrentPosition.dy + diffY);

        path += " ${absoluteCurrentPosition.dx},${absoluteCurrentPosition.dy}";
      }
    }

    double fillOpacity = fillColor.alpha / 255.0;

    var attributes = [
      xml.XmlAttribute(xml.XmlName('points'), path),
      xml.XmlAttribute(xml.XmlName('stroke'), 'rgb(${strokeColor.red},${strokeColor.green},${strokeColor.blue})'),
      xml.XmlAttribute(xml.XmlName('stroke-opacity'), '$strokeOpacity'),
      xml.XmlAttribute(xml.XmlName('stroke-width'), strokeWidth.toString()),
      xml.XmlAttribute(xml.XmlName('opacity'), "1.0"),
      xml.XmlAttribute(xml.XmlName('fill'), 'rgb(${fillColor.red},${fillColor.green},${fillColor.blue})'),
      xml.XmlAttribute(xml.XmlName('fill-opacity'), '$fillOpacity')
    ];

    var multilineElement = xml.XmlElement(xml.XmlName('polyline'), attributes);

    return multilineElement;
  }
  
}

class ShapeRectangle extends Shape {
  @override
  void setOffsetByPostion(Offset offset, int index) {
    vertices[index] = Offset(offset.dx - position.dx, offset.dy - position.dy);
  }
  
  @override
  xml.XmlElement mapShapeSVG() {
    Rect rect = Rect.fromPoints(vertices[0], vertices[1]);
    Offset temporalPosition;
    
    double width = rect.right - rect.left;
    double height = rect.bottom - rect.top;

    temporalPosition = getRectanglePositionSVG(vertices, width, height);

    double fillOpacity = fillColor.alpha / 255.0;
    double strokeOpacity = strokeColor.alpha / 255.0;

    var rectElement = xml.XmlElement(xml.XmlName('rect'), [
      xml.XmlAttribute(xml.XmlName('x'), temporalPosition.dx.toString()),
      xml.XmlAttribute(xml.XmlName('y'), temporalPosition.dy.toString()),
      xml.XmlAttribute(xml.XmlName('width'), width .toString()),
      xml.XmlAttribute(xml.XmlName('height'), height.toString()),
      xml.XmlAttribute(xml.XmlName('stroke'), 'rgb(${strokeColor.red},${strokeColor.green},${strokeColor.blue})'),
      xml.XmlAttribute(xml.XmlName('stroke-opacity'), '$strokeOpacity'),
      xml.XmlAttribute(xml.XmlName('stroke-width'), strokeWidth.toString()),
      xml.XmlAttribute(xml.XmlName('fill'), 'rgb(${fillColor.red},${fillColor.green},${fillColor.blue})'),
      xml.XmlAttribute(xml.XmlName('fill-opacity'), '$fillOpacity'),
      xml.XmlAttribute(xml.XmlName('opacity'), "1.0")
    ]);

    return rectElement;
  }
  
}

class ShapeEllipsis extends Shape {
  @override
  void setOffsetByPostion(Offset offset, int index) {
    vertices[index] = Offset(offset.dx - position.dx, offset.dy - position.dy);
  }
  
  @override
  xml.XmlElement mapShapeSVG() {
    Rect rect = Rect.fromPoints(vertices[0], vertices[1]);
    Offset temporalPosition;
    
    double width = rect.right - rect.left;
    double height = rect.bottom - rect.top;

    temporalPosition = getRectanglePositionSVG(vertices, width, height);

    double fillOpacity = fillColor.alpha / 255.0;
    double strokeOpacity = strokeColor.alpha / 255.0;

    var elipElement = xml.XmlElement(xml.XmlName('ellipse'), [
      xml.XmlAttribute(xml.XmlName('rx'), (rect.width/2).toString()),
      xml.XmlAttribute(xml.XmlName('ry'), (rect.height/2).toString()),
      xml.XmlAttribute(xml.XmlName('cy'), (temporalPosition.dy + height/2).toString()),
      xml.XmlAttribute(xml.XmlName('cx'), (temporalPosition.dx + width/2).toString()),
      xml.XmlAttribute(xml.XmlName('stroke'), 'rgb(${strokeColor.red},${strokeColor.green},${strokeColor.blue})'),
      xml.XmlAttribute(xml.XmlName('stroke-opacity'), '$strokeOpacity'),
      xml.XmlAttribute(xml.XmlName('stroke-width'), strokeWidth.toString()),
      xml.XmlAttribute(xml.XmlName('fill'), 'rgb(${fillColor.red},${fillColor.green},${fillColor.blue})'),
      xml.XmlAttribute(xml.XmlName('fill-opacity'), '$fillOpacity'),
      xml.XmlAttribute(xml.XmlName('opacity'), "1.0")
    ]);

    return elipElement;
  }

}
