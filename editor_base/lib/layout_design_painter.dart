import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'app_data.dart';
import 'util_shape.dart';

class LayoutDesignPainter extends CustomPainter {
  final AppData appData;
  final CDKTheme theme;
  final double centerX;
  final double centerY;
  static bool _shadersReady = false;
  static ui.Shader? _shaderGrid;

  LayoutDesignPainter({
    required this.appData,
    required this.theme,
    this.centerX = 0,
    this.centerY = 0,
  });

  static Future<void> initShaders() async {
    const double size = 5.0;
    int matSize = 4;
    List<List<double>> matIdent =
        List.generate(matSize, (_) => List.filled(matSize, 0.0));
    for (int i = 0; i < matSize; i++) {
      matIdent[i][i] = 1.0;
    }
    List<double> vecIdent = [];
    for (int i = 0; i < matSize; i++) {
      vecIdent.addAll(matIdent[i]);
    }

    // White and grey grid
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas imageCanvas = Canvas(recorder);
    final paint = Paint()..color = CDKTheme.white;
    imageCanvas.drawRect(const Rect.fromLTWH(0, 0, size, size), paint);
    imageCanvas.drawRect(const Rect.fromLTWH(size, size, size, size), paint);
    paint.color = CDKTheme.grey100;
    imageCanvas.drawRect(const Rect.fromLTWH(size, 0, size, size), paint);
    imageCanvas.drawRect(const Rect.fromLTWH(0, size, size, size), paint);
    int s = (size * 2).toInt();
    ui.Image? gridImage = await recorder.endRecording().toImage(s, s);
    _shaderGrid = ui.ImageShader(
      gridImage,
      TileMode.repeated,
      TileMode.repeated,
      Float64List.fromList(vecIdent),
    );

    _shadersReady = true;
  }

  void drawRulers(Canvas canvas, CDKTheme theme, Size size, Size docSize,
      double scale, double translateX, double translateY) {
    Rect rectRullerTop = Rect.fromLTWH(0, 0, size.width, 20);
    Paint paintRulerTop = Paint();
    paintRulerTop.color = theme.backgroundSecondary1;
    canvas.drawRect(rectRullerTop, paintRulerTop);

    // Horizontal ruler
    double xLeft = (0 + translateX) * scale;
    double xRight = ((docSize.width + translateX) * scale) - 1;

    double unitSize = 5 * scale;
    int cnt = 0;
    for (double i = xLeft; i < xRight; i += unitSize) {
      if (i > 0 && i < size.width) {
        Paint paintLine = Paint()..color = theme.colorText;
        double adjustedPosition = i;
        double top = 15;
        if ((cnt % 100) == 0) {
          top = 0;
          TextSpan span = TextSpan(
            style: TextStyle(color: theme.colorText, fontSize: 10),
            text: '$cnt',
          );

          TextPainter tp = TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
          );
          tp.layout();
          tp.paint(canvas, Offset(adjustedPosition + 2.4, 0));
        } else if ((cnt % 10) == 0) {
          top = 10;
        }
        canvas.drawLine(
          Offset(adjustedPosition, top),
          Offset(adjustedPosition, 20),
          paintLine,
        );
      }
      cnt = cnt + 5;
    }

    Rect rectRullerLeft = Rect.fromLTWH(0, 0, 20, size.height);
    Paint paintRulerLeft = Paint();
    paintRulerLeft.color = theme.backgroundSecondary1;
    canvas.drawRect(rectRullerLeft, paintRulerLeft);

    // Vertical ruler
    double yTop = (0 + translateY) * scale;
    double yBottom = ((docSize.height + translateY) * scale) - 1;

    cnt = 0;
    for (double i = yTop; i < yBottom; i += unitSize) {
      if (i > 0 && i < size.width) {
        Paint paintLine = Paint()..color = theme.colorText;
        double adjustedPosition = i;
        double left = 15;
        if ((cnt % 100) == 0) {
          left = 0;

          TextSpan span = TextSpan(
            style: TextStyle(color: theme.colorText, fontSize: 10),
            text: '$cnt',
          );

          TextPainter tp = TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
          );
          tp.layout();
          tp.paint(canvas, Offset(0, adjustedPosition + 2.4));
        } else if ((cnt % 10) == 0) {
          left = 10;
        }
        canvas.drawLine(
          Offset(left, adjustedPosition),
          Offset(20, adjustedPosition),
          paintLine,
        );
      }
      cnt = cnt + 5;
    }

    Rect rectRullerCorner = const Rect.fromLTWH(0, 0, 20, 20);
    Paint paintRulerCorner = Paint();
    paintRulerCorner.color = theme.backgroundSecondary1;
    canvas.drawRect(rectRullerCorner, paintRulerTop);
  }

  static void paintShape(Canvas canvas, Shape shape) {
    if (shape.vertices.isNotEmpty) {
      Paint paint = Paint();
      paint.color = shape.strokeColor;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = shape.strokeWidth;
      double x = shape.position.dx + shape.vertices[0].dx;
      double y = shape.position.dy + shape.vertices[0].dy;
      Path path = Path();
      path.moveTo(x, y);
      for (int i = 1; i < shape.vertices.length; i++) {
        x = shape.position.dx + shape.vertices[i].dx;
        y = shape.position.dy + shape.vertices[i].dy;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  static void paintHighlightedShape(Canvas canvas, List<Offset> offsetList, double x, double y) {
    Paint paint = Paint()..color = CDKTheme.yellow;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    Offset a = Offset(offsetList[0].dx + x, offsetList[0].dy + y);
    Offset b = Offset(offsetList[1].dx + x, offsetList[1].dy + y);
    canvas.drawLine(a,b, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    Size docSize = Size(appData.docSize.width, appData.docSize.height);

    // Defineix els límits de dibuix del canvas
    canvas.save();
    Rect visibleRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.clipRect(visibleRect);

    // Dibuixa el fons de l'àrea
    Paint paintBackground = Paint();
    paintBackground.color = theme.backgroundSecondary1;
    canvas.drawRect(visibleRect, paintBackground);

    // Guarda l'estat previ a l'escalat i translació
    canvas.save();

    // Calcula l'escalat basat en el zoom
    double scale = appData.zoom / 100;
    Size scaledSize = Size(size.width / scale, size.height / scale);
    canvas.scale(scale, scale);

    // Calcula la posició de translació per centrar el punt desitjat
    double translateX = (scaledSize.width / 2) - (docSize.width / 2) - centerX;
    double translateY =
        (scaledSize.height / 2) - (docSize.height / 2) - centerY;
    canvas.translate(translateX, translateY);

    // Dibuixa la 'reixa de fons' del document
    double docW = docSize.width;
    double docH = docSize.height;

    if (_shadersReady) {
      Paint paint = Paint();
      paint.shader = _shaderGrid;
      canvas.drawRect(Rect.fromLTWH(0, 0, docW, docH), paint);
    }

    // Dibuixa el fons del document aquí ...
    canvas.drawRect(Rect.fromLTWH(0, 0, docW, docH),
        Paint()..color = appData.currentBackgroundColor);

    // Dibuixa la llista de poligons (segons correspon, relatiu a la seva posició)
    if (appData.shapesList.isNotEmpty) {
      for (int i = 0; i < appData.shapesList.length; i++) {
        Shape shape = appData.shapesList[i];
        paintShape(canvas, shape);
      }
    }

    // Dibuixa el poligon que s'està afegint (relatiu a la seva posició)
    Shape shape = appData.newShape;
    // Ens assegurem que el color del new Shape es igual que el seleccionat
    shape.strokeColor = appData.currentShapeColor;
    paintShape(canvas, shape);

    // Pinta el requadre groc si s'esta tocant un shape

    // Restaura l'estat previ a l'escalat i translació
    canvas.restore();

    // Dibuixa la regla superior
    drawRulers(canvas, theme, size, docSize, scale, translateX, translateY);

    // Restaura l'estat de retall del canvas
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LayoutDesignPainter oldDelegate) {
    return oldDelegate.appData != appData ||
        oldDelegate.theme != theme ||
        oldDelegate.centerX != centerX ||
        oldDelegate.centerY != centerY;
  }
}
