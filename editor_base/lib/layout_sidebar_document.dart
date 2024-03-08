import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'package:path/path.dart' as path;

class LayoutSidebarDocument extends StatefulWidget {
  const LayoutSidebarDocument({super.key});

  @override
  LayoutSidebarDocumentState createState() => LayoutSidebarDocumentState();
}

class LayoutSidebarDocumentState extends State<LayoutSidebarDocument> {
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
                Text("Document properties:", style: fontBold),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                      alignment: Alignment.centerRight,
                      width: labelsWidth,
                      child: Text("Width:", style: font)),
                  const SizedBox(width: 4),
                  Container(
                      alignment: Alignment.centerLeft,
                      width: 80,
                      child: CDKFieldNumeric(
                        value: appData.docSize.width,
                        min: 1,
                        max: 2500,
                        units: "px",
                        increment: 100,
                        decimals: 0,
                        onValueChanged: (value) {
                          appData.setDocWidth(value);
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
                        child: Text("Height:", style: font)),
                    const SizedBox(width: 4),
                    Container(
                        alignment: Alignment.centerLeft,
                        width: 80,
                        child: CDKFieldNumeric(
                          value: appData.docSize.height,
                          min: 1,
                          max: 2500,
                          units: "px",
                          increment: 100,
                          decimals: 0,
                          onValueChanged: (value) {
                            appData.setDocHeight(value);
                          },
                        ))
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        alignment: Alignment.centerRight,
                        width: labelsWidth,
                        child: Text("Background color:", style: font)),
                    const SizedBox(width: 4),
                    Container(
                        alignment: Alignment.centerLeft,
                        width: 80,
                        child: CDKButtonColor(
                            onPressed: () {
                              Color initialColor = appData.currentBackgroundColor;
                              showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) =>
                                    CupertinoAlertDialog(
                                        title: const Text('Color Picker'),
                                        content: CDKPickerColor(
                                          color: appData.currentBackgroundColor,
                                          onChanged: (selectedColor) {
                                            appData.setNewBackgroundColor(initialColor, selectedColor, false);
                                          },
                                        )),
                              ).then((value) {
                                appData.setNewBackgroundColor(initialColor, appData.currentBackgroundColor, true);
                              });
                            },
                            color: appData.currentBackgroundColor)),
                  ],
                ),
                const SizedBox(height: 16),
                Text("File actions:", style: fontBold),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        alignment: Alignment.centerRight,
                        width: labelsWidth,
                        child: CDKButton(
                          child: const Text("Load File"),
                          onPressed: () {
                            appData.selectJsonFile();
                          },)
                    ),
                    const SizedBox(width: 4), 
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        alignment: Alignment.centerRight,
                        width: labelsWidth,
                        child: CDKButton(child: appData.openedFile == null ? const Text("Save as") : const Text("Save"),
                        onPressed: () {
                            appData.saveAsNewFile("json");
                        },)
                    ),
                    const SizedBox(width: 4),
                    Container(
                        alignment: Alignment.centerLeft,
                        width: 80,
                        child: appData.openedFile == null ? const Text("") :  Text(path.basename(appData.openedFile!.path), style: const TextStyle(fontSize: 10),),
                    ), 
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        alignment: Alignment.centerRight,
                        width: labelsWidth,
                        child: CDKButton(child: const Text("Export as SVG"),
                        onPressed: () {
                          appData.saveAsNewFile("svg");
                        },)
                    ),
                    const SizedBox(width: 4), 
                  ],
                ),
                const SizedBox(height: 8),
              ]);
        },
      ),
    );
  }
}
