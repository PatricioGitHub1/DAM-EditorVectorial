import 'dart:math';

import 'package:editor_base/layout_design_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_theme.dart';
import 'package:provider/provider.dart';
import 'util_shape.dart';
import 'app_data.dart';

class ShapesListView extends StatefulWidget {
  final List<Shape> shapesList;

  const ShapesListView({super.key, required this.shapesList});

  @override
  LayoutShapeListViewState createState() => LayoutShapeListViewState();

}

class LayoutShapeListViewState extends State<ShapesListView> {
  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(0),
        itemCount: widget.shapesList.length,
        itemBuilder: (BuildContext context, int index) {
          Color tileColor = widget.shapesList[index].isSelected ? CupertinoColors.activeBlue : CDKTheme.white; 
          return GestureDetector(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: tileColor,
                border: const Border(
                  bottom: BorderSide(
                    color: CDKTheme.black,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Padding(padding: EdgeInsets.only(right: 20)),
                  Text("Shape ${index + 1}"),
                  const Padding(padding: EdgeInsets.only(right: 8)),
                  Container(
                    height: 10,
                    width: 10,
                    color: widget.shapesList[index].strokeColor,
                  ),
                  const Padding(padding: EdgeInsets.only(right: 8)),
                  Text(
                    "${widget.shapesList[index].strokeWidth} px",
                    style: const TextStyle(fontSize: 12),
                  ),
                  const Padding(padding: EdgeInsets.only(right: 20)),
                  CustomPaint(
                    size: const Size(30, 30),  // Set an appropriate size
                    painter: SidebarShapePainter(widget.shapesList[index]),
                  ),
                  
                ],
              ),
            ),
            onTap: () {
            appData.setToolSelected("pointer_shapes");

            if (appData.highlightPoints.containsKey(appData.shapesList[index])) {
              appData.highlightPoints.remove(appData.shapesList[index]);
              appData.shapesList[index].isSelected = false;
              appData.shapeSelected = -1;

            } else if(appData.shapeSelected == -1) {
              appData.getHighlightOffsets(appData.shapesList[index]);
              appData.shapesList[index].isSelected = true;
              appData.shapeSelected = 1;
              
            }

            appData.forceNotifyListeners();
          }
          );
        },
      ),
    );
  }
}

class SidebarShapePainter extends CustomPainter {
 final Shape shape;

 SidebarShapePainter(this.shape);

 @override
 void paint(Canvas canvas, Size size) {
   // Defineix els límits de dibuix del canvas
   Rect visibleRect = Rect.fromLTWH(0, 0, size.width, size.height);
   canvas.clipRect(visibleRect);

   // Calcula les dimensions màximes del polígon
   double minX = double.infinity, minY = double.infinity;
   double maxX = -double.infinity, maxY = -double.infinity;
   for (final vertex in shape.vertices) {
     double vertexX = shape.position.dx + vertex.dx;
     double vertexY = shape.position.dy + vertex.dy;
     minX = min(minX, vertexX);
     minY = min(minY, vertexY);
     maxX = max(maxX, vertexX);
     maxY = max(maxY, vertexY);
   }

   // Dimensions màximes del polígon
   double width = maxX - minX;
   double height = maxY - minY;
  // Centre del polígon
   double centerX = minX + width / 2;
   double centerY = minY + height / 2;

   // Escala per ajustar el polígon dins del canvas
   double scaleX = size.width / width;
   double scaleY = size.height / height;
   double scale = min(scaleX, scaleY);

   // Centre del canvas
   double canvasCenterX = size.width / 2;
   double canvasCenterY = size.height / 2;

   double tX = canvasCenterX - centerX * scale;
   double tY = canvasCenterY - centerY * scale;

   canvas.translate(tX, tY);
   canvas.scale(scale);

   // Dibuixa el polígon
   LayoutDesignPainter.paintShape(canvas, shape);
 }

 @override
 bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
