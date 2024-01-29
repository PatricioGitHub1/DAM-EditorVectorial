// Cada acció ha d'implementar les funcions undo i redo
import 'dart:ui';

import 'app_data.dart';
import 'util_shape.dart';

abstract class Action {
  void undo();
  void redo();
}

// Gestiona la llista d'accions per poder desfer i refer
class ActionManager {
  List<Action> actions = [];
  int currentIndex = -1;

  void register(Action action) {
    // Elimina les accions que estan després de l'índex actual
    if (currentIndex < actions.length - 1) {
      actions = actions.sublist(0, currentIndex + 1);
    }
    actions.add(action);
    currentIndex++;
    action.redo();
  }

  void undo() {
    if (currentIndex >= 0) {
      actions[currentIndex].undo();
      currentIndex--;
    }
  }

  void redo() {
    if (currentIndex < actions.length - 1) {
      currentIndex++;
      actions[currentIndex].redo();
    }
  }
}

class ActionSetDocWidth implements Action {
  final double previousValue;
  final double newValue;
  final AppData appData;

  ActionSetDocWidth(this.appData, this.previousValue, this.newValue);

  _action(double value) {
    appData.docSize = Size(value, appData.docSize.height);
    appData.forceNotifyListeners();
  }

  @override
  void undo() {
    _action(previousValue);
  }

  @override
  void redo() {
    _action(newValue);
  }
}

class ActionSetDocHeight implements Action {
  final double previousValue;
  final double newValue;
  final AppData appData;

  ActionSetDocHeight(this.appData, this.previousValue, this.newValue);

  _action(double value) {
    appData.docSize = Size(appData.docSize.width, value);
    appData.forceNotifyListeners();
  }

  @override
  void undo() {
    _action(previousValue);
  }

  @override
  void redo() {
    _action(newValue);
  }
}

class ActionAddNewShape implements Action {
  final AppData appData;
  final Shape newShape;

  ActionAddNewShape(this.appData, this.newShape);

  @override
  void undo() {
    if (newShape.isSelected) {
      appData.shapeSelected = -1;
      newShape.isSelected = false;
      appData.highlightPoints.remove(newShape);
    }
    appData.shapesList.remove(newShape);
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    appData.shapesList.add(newShape);
    appData.forceNotifyListeners();
  }
}

class ActionRemoveShape implements Action {
  final AppData appData;
  final Shape shape;

  ActionRemoveShape(this.appData, this.shape);

  @override
  void undo() {
    appData.shapesList.add(shape);
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    if (shape.isSelected) {
      appData.shapeSelected = -1;
      shape.isSelected = false;
      appData.highlightPoints.remove(shape);
    }
    appData.shapesList.remove(shape);
    appData.forceNotifyListeners();
  }
}

class ActionAddNewBackground implements Action {
  final AppData appData;
  final Color previousColor;
  final Color newColor;

  ActionAddNewBackground(this.appData, this.previousColor, this.newColor);

  _action(Color value) {
    appData.currentBackgroundColor = value;
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    _action(newColor);
  }

  @override
  void undo() {
    _action(previousColor);
  }
}

class ActionMoveSelectedShape implements Action {
  final AppData appData;
  final Shape movedShape;
  final Offset startingPosition;
  final Offset endingPosition;

  ActionMoveSelectedShape(this.appData, this.movedShape, this.startingPosition, this.endingPosition);

  _action(Offset value) {
    movedShape.setPosition(value);
    appData.getHighlightOffsets(movedShape);
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    _action(endingPosition);
  }

  @override
  void undo() {
    _action(startingPosition);
  }

}

class ActionFormatStrokeWidth implements Action {
  final AppData appData;
  final Shape shape;
  final double previousWidth;
  final double newWidth;

  ActionFormatStrokeWidth(this.appData, this.shape, this.previousWidth, this.newWidth);

  _action(double value) {
    shape.setStrokeWidth(value);
    appData.setNewShapeStrokeWidth(value);
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    _action(newWidth);
  }

  @override
  void undo() {
    _action(previousWidth);
  }

}

class ActionFormatStrokeColor implements Action {
  final AppData appData;
  final Shape shape;
  final Color previousColor;
  final Color newColor;

  ActionFormatStrokeColor(this.appData, this.shape, this.previousColor, this.newColor);

  _action(Color value) {
    shape.setStrokeColor(value);
    appData.setNewShapeColor(value);
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    _action(newColor);
  }

  @override
  void undo() {
    _action(previousColor);
  }

}

class ActionCloseShape implements Action {
  final AppData appData;
  final Shape shape;
  final bool wasClosed;
  final bool isClosed;

  ActionCloseShape(this.appData, this.shape, this.wasClosed, this.isClosed);

  _action(bool value) {
    shape.closed = value;
    appData.setIsShapeClosed(value);
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    _action(isClosed);
  }

  @override
  void undo() {
    _action(wasClosed);
  }

}

class ActionFormatFillColor implements Action {
  final AppData appData;
  final Shape shape;
  final Color previousColor;
  final Color newColor;

  ActionFormatFillColor(this.appData, this.shape, this.previousColor, this.newColor);

  _action(Color value) {
    shape.setNewShapeFillcolor(value);
    appData.setNewShapeFillcolor(value);
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    _action(newColor);
  }

  @override
  void undo() {
    _action(previousColor);
  }
}
