import 'package:editor_base/app_click_selecto.dart';
import 'package:editor_base/util_shape.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'layout_design_painter.dart';
import 'util_custom_scroll_vertical.dart';
import 'util_custom_scroll_horizontal.dart';
import 'package:flutter/gestures.dart';

class LayoutDesign extends StatefulWidget {
  const LayoutDesign({super.key});

  @override
  LayoutDesignState createState() => LayoutDesignState();
}

class LayoutDesignState extends State<LayoutDesign> {
  final GlobalKey<UtilCustomScrollHorizontalState> _keyScrollX = GlobalKey();
  final GlobalKey<UtilCustomScrollVerticalState> _keyScrollY = GlobalKey();
  Offset _scrollCenter = const Offset(0, 0);
  bool _isMouseButtonPressed = false;
  final FocusNode _focusNode = FocusNode();

  Offset _dragStartPosition = Offset(0, 0);
  Offset _dragStartOffset = Offset(0, 0);
  Offset docPosition = Offset(0, 0);

  @override
  void initState() {
    super.initState();
    initShaders();
  }

  Future<void> initShaders() async {
    await LayoutDesignPainter.initShaders();
    setState(() {});
  }

  // Retorna l'area de scroll del document
  Size _getScrollArea(AppData appData) {
    return Size(((appData.docSize.width * appData.zoom) / 100) + 50,
        ((appData.docSize.height * appData.zoom) / 100) + 50);
    // Force 50 pixels padding (to show 25 pixels rulers)
  }

  // Retorna el desplacament del document respecte el centre de la pantalla
  Offset _getDisplacement(Size scrollArea, BoxConstraints constraints) {
    return Offset(((scrollArea.width - constraints.maxWidth) / 2),
        ((scrollArea.height - constraints.maxHeight) / 2));
  }

  // Retorna la posició x,y al document, respecte on s'ha fet click
  Offset _getDocPosition(Offset position, double zoom,
      BoxConstraints constraints, Size docSize, Offset center) {
    double scale = zoom / 100;
    double translateX =
        (constraints.maxWidth / (2 * scale)) - (docSize.width / 2) - center.dx;
    double translateY = (constraints.maxHeight / (2 * scale)) -
        (docSize.height / 2) -
        center.dy;
    double originalX = (position.dx / scale) - translateX;
    double originalY = (position.dy / scale) - translateY;

    return Offset(originalX, originalY);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      AppData appData = Provider.of<AppData>(context);
      CDKTheme theme = CDKThemeNotifier.of(context)!.changeNotifier;

      Size scrollArea = _getScrollArea(appData);
      Offset scrollDisplacement = _getDisplacement(scrollArea, constraints);

      double tmpScrollX = _scrollCenter.dx;
      double tmpScrollY = _scrollCenter.dy;
      if (_keyScrollX.currentState != null) {
        if (scrollArea.width < constraints.maxWidth) {
          _keyScrollX.currentState!.setOffset(0);
        } else {
          tmpScrollX = _keyScrollX.currentState!.getOffset() *
              (scrollDisplacement.dx * 100 / appData.zoom);
        }
      }

      if (_keyScrollY.currentState != null) {
        if (scrollArea.height < constraints.maxHeight) {
          _keyScrollY.currentState!.setOffset(0);
        } else {
          tmpScrollY = _keyScrollY.currentState!.getOffset() *
              (scrollDisplacement.dy * 100 / appData.zoom);
        }
      }

      _scrollCenter = Offset(tmpScrollX, tmpScrollY);

      return Stack(
        children: [
          GestureDetector(
              onPanEnd: (details) {
                _keyScrollX.currentState!.startInertiaAnimation();
                _keyScrollY.currentState!.startInertiaAnimation();
              },
              onPanUpdate: (DragUpdateDetails details) {
                if (!_isMouseButtonPressed) {
                  if (appData.isAltOptionKeyPressed) {
                    appData.setZoom(appData.zoom + details.delta.dy);
                  } else {
                    if (details.delta.dx != 0) {
                      _keyScrollX.currentState!
                          .setTrackpadDelta(details.delta.dx);
                    }
                    if (details.delta.dy != 0) {
                      _keyScrollY.currentState!
                          .setTrackpadDelta(details.delta.dy);
                    }
                  }
                }
              },
              child: MouseRegion(
                  cursor: switch (appData.toolSelected) {
                    "pointer_shapes" => SystemMouseCursors.basic,
                    "shape_drawing" => SystemMouseCursors.precise,
                    "view_grab" =>  _isMouseButtonPressed
                          ? SystemMouseCursors.grabbing
                          : SystemMouseCursors.grab,
                    _ => MouseCursor.defer, 
                  },
                  child: Listener(
                      onPointerDown: (event) {
                        _focusNode.requestFocus();
                        _isMouseButtonPressed = true;
                        if (appData.toolSelected == "shape_drawing") {
                          Size docSize = Size(
                              appData.docSize.width, appData.docSize.height);
                          appData.addNewShape(_getDocPosition(
                              event.localPosition,
                              appData.zoom,
                              constraints,
                              docSize,
                              _scrollCenter));
                        } 
                        
                        if (appData.toolSelected == "pointer_shapes") {
                          Size docSize = Size(
                              appData.docSize.width, appData.docSize.height);
                          docPosition = _getDocPosition(event.localPosition,appData.zoom,constraints, docSize,_scrollCenter);
                          AppClickSelector.selectShapeAtPosition(docPosition, appData);
                          
                          if (appData.shapeSelected != -1) {
                            _dragStartPosition = appData.getSelectedShape().position;
                            _dragStartOffset = docPosition - _dragStartPosition;

                          }
                        }

                        if (appData.toolSelected == "shape_line") {
                          appData.newShape = ShapeLine();

                          Size docSize = Size(
                              appData.docSize.width, appData.docSize.height);
                          appData.addNewShape(_getDocPosition(
                              event.localPosition,
                              appData.zoom,
                              constraints,
                              docSize,
                              _scrollCenter));

                          appData.addRelativePointToNewShape(_getDocPosition(
                              event.localPosition,
                              appData.zoom,
                              constraints,
                              docSize,
                              _scrollCenter));
                        }

                        if (appData.toolSelected == "shape_rectangle") {
                          appData.newShape = ShapeRectangle();

                          Size docSize = Size(
                              appData.docSize.width, appData.docSize.height);
                          appData.addNewShape(_getDocPosition(
                              event.localPosition,
                              appData.zoom,
                              constraints,
                              docSize,
                              _scrollCenter));

                          appData.addRelativePointToNewShape(_getDocPosition(
                              event.localPosition,
                              appData.zoom,
                              constraints,
                              docSize,
                              _scrollCenter));
                        }

                        if (appData.toolSelected == "shape_ellipsis") {
                          appData.newShape = ShapeEllipsis();

                          Size docSize = Size(
                              appData.docSize.width, appData.docSize.height);
                          appData.addNewShape(_getDocPosition(
                              event.localPosition,
                              appData.zoom,
                              constraints,
                              docSize,
                              _scrollCenter));

                          appData.addRelativePointToNewShape(_getDocPosition(
                              event.localPosition,
                              appData.zoom,
                              constraints,
                              docSize,
                              _scrollCenter));
                        }

                        setState(() {});
                      },
                      
                      onPointerMove: (event) {
                        if (appData.toolSelected == "pointer_shapes" && appData.shapeSelected != -1) {
                          Size docSize = Size(
                              appData.docSize.width, appData.docSize.height);
                          docPosition = _getDocPosition(event.localPosition,appData.zoom,constraints, docSize,_scrollCenter);
                          Offset newShapePosition = docPosition - _dragStartOffset;
                          appData.updateShapePosition(newShapePosition); 
                        }

                        if (_isMouseButtonPressed) {
                          if (appData.toolSelected == "shape_drawing") {
                            Size docSize = Size(
                                appData.docSize.width, appData.docSize.height);
                            appData.addRelativePointToNewShape(_getDocPosition(
                                event.localPosition,
                                appData.zoom,
                                constraints,
                                docSize,
                                _scrollCenter));
                          }
                        }
                        if (_isMouseButtonPressed &&
                            appData.toolSelected == "view_grab") {
                          if (event.delta.dx != 0) {
                            _keyScrollX.currentState!
                                .setTrackpadDelta(event.delta.dx);
                          }
                          if (event.delta.dy != 0) {
                            _keyScrollY.currentState!
                                .setTrackpadDelta(event.delta.dy);
                          }
                        }

                        if (_isMouseButtonPressed && appData.toolSelected == "shape_line") {
                          Size docSize = Size(
                                appData.docSize.width, appData.docSize.height);

                          docPosition = _getDocPosition(event.localPosition,appData.zoom,constraints, docSize,_scrollCenter);
                          appData.setOffsetByPostion(docPosition, 1);
                        }

                        if (_isMouseButtonPressed && appData.toolSelected == "shape_rectangle") {
                          Size docSize = Size(
                                appData.docSize.width, appData.docSize.height);

                          docPosition = _getDocPosition(event.localPosition,appData.zoom,constraints, docSize,_scrollCenter);
                          appData.setOffsetByPostion(docPosition, 1);
                        }

                        if (_isMouseButtonPressed && appData.toolSelected == "shape_ellipsis") {
                          Size docSize = Size(
                                appData.docSize.width, appData.docSize.height);

                          docPosition = _getDocPosition(event.localPosition,appData.zoom,constraints, docSize,_scrollCenter);
                          appData.setOffsetByPostion(docPosition, 1);
                        }
                      },
                      onPointerUp: (event) {
                        _isMouseButtonPressed = false;
                        if (appData.toolSelected == "shape_drawing") {
                          appData.addNewShapeToShapesList();
                        }
                        if (appData.toolSelected == "pointer_shapes" && appData.shapeSelected != -1) {
                            Size docSize = Size(appData.docSize.width, appData.docSize.height);
                            Offset docPosition = _getDocPosition(event.localPosition, appData.zoom, constraints, docSize, _scrollCenter);
                            Offset newShapePosition = docPosition - _dragStartOffset;
                            if (_dragStartPosition != newShapePosition) {
                                appData.setShapePosition(_dragStartPosition, newShapePosition);
                            }
                        }
                        if (appData.toolSelected == "shape_line") {
                          appData.addNewShapeToShapesList();
                        }

                        if (appData.toolSelected == "shape_rectangle") {
                          appData.addNewShapeToShapesList();
                        }
                        
                        if (appData.toolSelected == "shape_ellipsis") {
                          appData.addNewShapeToShapesList();
                        }
                        setState(() {});
                      },
                      onPointerSignal: (pointerSignal) {
                        if (pointerSignal is PointerScrollEvent) {
                          if (!_isMouseButtonPressed) {
                            if (appData.isAltOptionKeyPressed) {
                              appData.setZoom(
                                  appData.zoom + pointerSignal.scrollDelta.dy);
                            } else {
                              _keyScrollX.currentState!
                                  .setWheelDelta(pointerSignal.scrollDelta.dx);
                              _keyScrollY.currentState!
                                  .setWheelDelta(pointerSignal.scrollDelta.dy);
                            }
                          }
                        }
                      },
                      child: CustomPaint(
                        painter: LayoutDesignPainter(
                          appData: appData,
                          theme: theme,
                          centerX: _scrollCenter.dx,
                          centerY: _scrollCenter.dy,
                        ),
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                      )))),
          UtilCustomScrollHorizontal(
            key: _keyScrollX,
            size: constraints.maxWidth,
            contentSize: scrollArea.width,
            onChanged: (value) {
              setState(() {});
            },
          ),
          UtilCustomScrollVertical(
            key: _keyScrollY,
            size: constraints.maxHeight,
            contentSize: scrollArea.height,
            onChanged: (value) {
              setState(() {});
            },
          ),
        ],
      );
    });
  }
}
