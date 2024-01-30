import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'app_data_actions.dart';
import 'util_shape.dart';

class AppData with ChangeNotifier {
  // Access appData globaly with:
  // AppData appData = Provider.of<AppData>(context);
  // AppData appData = Provider.of<AppData>(context, listen: false)

  ActionManager actionManager = ActionManager();
  bool isAltOptionKeyPressed = false;
  double zoom = 95;
  Size docSize = const Size(500, 400);
  String toolSelected = "shape_drawing";
  Shape newShape = ShapeDrawing();
  List<Shape> shapesList = [];

  Color currentShapeColor = CDKTheme.black;
  Color currentBackgroundColor = Color.fromRGBO(0, 0, 0, 0.0);
  Color currentFillColor = Color.fromRGBO(0, 0, 0, 0.0);
  bool currentShapeClosed = false;

  Map<Shape,List<Offset>> highlightPoints = {};

  bool readyExample = false;
  late dynamic dataExample;

  int shapeSelected = -1;

  void forceNotifyListeners() {
    super.notifyListeners();
  }

  void setZoom(double value) {
    zoom = value.clamp(25, 500);
    notifyListeners();
  }

  void setZoomNormalized(double value) {
    if (value < 0 || value > 1) {
      throw Exception(
          "AppData setZoomNormalized: value must be between 0 and 1");
    }
    if (value < 0.5) {
      double min = 25;
      zoom = zoom = ((value * (100 - min)) / 0.5) + min;
    } else {
      double normalizedValue = (value - 0.51) / (1 - 0.51);
      zoom = normalizedValue * 400 + 100;
    }
    notifyListeners();
  }

  double getZoomNormalized() {
    if (zoom < 100) {
      double min = 25;
      double normalized = (((zoom - min) * 0.5) / (100 - min));
      return normalized;
    } else {
      double normalizedValue = (zoom - 100) / 400;
      return normalizedValue * (1 - 0.51) + 0.51;
    }
  }

  void setDocWidth(double value) {
    double previousWidth = docSize.width;
    actionManager.register(ActionSetDocWidth(this, previousWidth, value));
  }

  void setDocHeight(double value) {
    double previousHeight = docSize.height;
    actionManager.register(ActionSetDocHeight(this, previousHeight, value));
  }

  void setToolSelected(String name) {
    toolSelected = name;
    notifyListeners();
  }

  void addNewShape(Offset position) {
    newShape.setPosition(position);
    newShape.addPoint(const Offset(0, 0));
    notifyListeners();
  }

  void addRelativePointToNewShape(Offset point) {
    newShape.addRelativePoint(point);
    notifyListeners();
  }

  void setOffsetByPostion(Offset offset, int index) { 
    newShape.setOffsetByPostion(offset, index);
    notifyListeners();
  }

  void addNewShapeToShapesList() {
    // Si no hi ha almenys 2 punts, no es podrà dibuixar res
    if (newShape.vertices.length >= 2) {
      double strokeWidthConfig = newShape.strokeWidth;
      actionManager.register(ActionAddNewShape(this, newShape));
      newShape = ShapeDrawing();
      newShape.setStrokeWidth(strokeWidthConfig);
    }
  }

  void setNewShapeStrokeWidth(double value) {
    newShape.setStrokeWidth(value);
    notifyListeners();
  }

  void setNewShapeColor(Color color) {
    newShape.setStrokeColor(color);
    currentShapeColor = color;
    notifyListeners();
  }

  void setNewShapeFillcolor (Color color) {
    newShape.setNewShapeFillcolor(color);
    currentFillColor = color;
    notifyListeners();
  }

  void setIsShapeClosed(bool value) {
    newShape.closed = value;
    currentShapeClosed = value;
    notifyListeners();
  }

  void setNewBackgroundColor(Color oldColor, Color newColor, bool toRegister) {
    currentBackgroundColor = newColor;
    if (toRegister) {
      actionManager.register(ActionAddNewBackground(this, oldColor, newColor));
    }
    forceNotifyListeners();
  }

  void getHighlightOffsets(Shape shape) {
    highlightPoints[shape] = getOuterOffsetList(shape);
  }

  List<Offset> getOuterOffsetList(Shape shape) {
    // Primer punto
      Offset minDxOffset = shape.vertices.reduce((currentMin, offset) =>
        offset.dx < currentMin.dx ? offset : currentMin);
      Offset minDyOffset = shape.vertices.reduce((currentMin, offset) =>
        offset.dy < currentMin.dy ? offset : currentMin);
      // Segundo punto
      Offset maxDxOffset = shape.vertices.reduce((currentMax, offset) =>
        offset.dx > currentMax.dx ? offset : currentMax);
      Offset maxDyOffset = shape.vertices.reduce((currentMax, offset) =>
        offset.dy > currentMax.dy ? offset : currentMax);

      // Ajustamos añadiendo la posicion del shape + su stroke
      List<Offset> lista = [];
      lista.add(Offset(minDxOffset.dx + shape.position.dx - shape.strokeWidth/2, minDyOffset.dy + shape.position.dy - shape.strokeWidth/2));
      lista.add(Offset(maxDxOffset.dx + shape.position.dx + shape.strokeWidth/2, maxDyOffset.dy + shape.position.dy + shape.strokeWidth/2));

      return lista;
  }

  Shape getSelectedShape() {
    for (var i = 0; i < shapesList.length; i++) {
      if (shapesList[i].isSelected) {
        return shapesList[i];
      }
    }

    return ShapeDrawing();
  }

  void updateShapePosition(Offset newShapePosition) {
    Shape shape = getSelectedShape();
    shape.setPosition(newShapePosition);
    getHighlightOffsets(shape);
    notifyListeners();
  }

  void setShapePosition(Offset startingPosition, Offset endingPosition) {
    actionManager.register(ActionMoveSelectedShape(this, getSelectedShape(), startingPosition, endingPosition));
  }

  void setStrokeRegister(Shape shape, double starting, double ending) {
    actionManager.register(ActionFormatStrokeWidth(this, shape, starting, ending));
  } 

  void setStrokeColorRegister(Shape shape, Color previousColor, Color newColor) {
    actionManager.register(ActionFormatStrokeColor(this, shape, previousColor, newColor));
  }

  void setCloseRegister(AppData appData, Shape shape, bool wasClosed, bool isClosed) {
    actionManager.register(ActionCloseShape(appData, shape, wasClosed, isClosed));
  }

  void setFillColorRegister(AppData appData, Shape shape, Color previousColor, Color newColor) {
    actionManager.register(ActionFormatFillColor(appData, shape, previousColor, newColor));
  }

  void deleteShape() {
    if (shapeSelected != -1) {
      Shape shapeToDelete = getSelectedShape();
      shapesList.remove(shapeToDelete);
      actionManager.register(ActionRemoveShape(this, shapeToDelete));
      notifyListeners();
    }
  }

  void copyShapeToClipboard() {
    if (shapeSelected != -1) {
      //Clipboard.setData(ClipboardData(text: getSelectedShape().toMap().toString()));
      Clipboard.setData(ClipboardData(text: jsonEncode(getSelectedShape().toMap())));
    }
  }

  //  
  void pasteShapeFromClipboard(String format) async {
    ClipboardData? data = await Clipboard.getData("text/plain");
        
    if (data != null && data.text != null) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(data.text!);
        if (jsonData["type"] == "shape_drawing") {
          Shape clipboardShape = Shape.fromMap(jsonData);
          actionManager.register(ActionAddNewShape(this, clipboardShape));
          notifyListeners();
        }
        
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    } else {
      print("Clipboard data or text is null");
    }
    
  }
}

