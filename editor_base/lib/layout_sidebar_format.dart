import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class LayoutSidebarFormat extends StatefulWidget {
  const LayoutSidebarFormat({super.key});

  @override
  LayoutSidebarFormatState createState() => LayoutSidebarFormatState();
}

class LayoutSidebarFormatState extends State<LayoutSidebarFormat> {
  final GlobalKey anchorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

    TextStyle fontBold =
        const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    TextStyle font = const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

    return Container(
      padding: const EdgeInsets.all(4.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double labelsWidth = constraints.maxWidth * 0.5;
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Stroke and fill:", style: fontBold),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                      alignment: Alignment.centerRight,
                      width: labelsWidth,
                      child: Text("Stroke width:", style: font)),
                  const SizedBox(width: 4),
                  Container(
                      alignment: Alignment.centerLeft,
                      width: 80,
                      child: CDKFieldNumeric(
                        value: appData.newShape.strokeWidth,
                        min: 1,
                        max: 100,
                        units: "px",
                        increment: 0.5,
                        decimals: 0,
                        onValueChanged: (value) {
                          appData.setNewShapeStrokeWidth(value);
                        },
                      )),
                ]),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        alignment: Alignment.centerRight,
                        width: labelsWidth,
                        child: Text("Stroke color:", style: font)),
                    const SizedBox(width: 4),
                    Container(
                        alignment: Alignment.centerLeft,
                        width: 80,
                        child: CDKButtonColor(
                            onPressed: () {
                              showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) =>
                                    CupertinoAlertDialog(
                                        title: const Text('Color Picker'),
                                        content: CDKPickerColor(
                                          color: appData.currentShapeColor,
                                          onChanged: (selectedColor) {
                                            appData.setNewShapeColor(
                                                selectedColor);
                                          },
                                        )),
                              ).then((value) {
                                print("Cerrado");
                              });
                            },
                            color: appData.currentShapeColor)),
                  ],
                ),
                const SizedBox(height: 16),
              ]);
        },
      ),
    );
  }
}
