
import 'dart:ui';
import 'package:editor_base/app_data.dart';
import 'package:editor_base/util_shape.dart';


class AppClickSelector {

  setShapeSelected() {

  }

  static void selectShapeAtPosition(Offset currPoint, AppData appData) {
    Shape? shapeOnTop;

    for (Shape s in appData.shapesList) {
      List<Offset> limites = appData.getOuterOffsetList(s);
      Rect rect = Rect.fromPoints(limites[0], limites[1]);

      if (rect.contains(currPoint)) {
        shapeOnTop = s;
      }
    }

    if (shapeOnTop != null && appData.shapeSelected == -1) {
      shapeOnTop.isSelected = true;
      appData.shapeSelected = 1;

      appData.getHighlightOffsets(shapeOnTop);
      appData.forceNotifyListeners();

    } 
  }

}