import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';

class LayoutSidebarShapes extends StatelessWidget {
  const LayoutSidebarShapes({super.key});

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

    return SizedBox(
      width: double.infinity, // Estira el widget horitzontalment
      child: Container(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            const Text('List of shapes', style: TextStyle(decoration: TextDecoration.underline)),
            SizedBox(
              height: MediaQuery.of(context).size.height - 100,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(0),
                itemCount: appData.shapesList.length,
                itemBuilder: (BuildContext context, int index) {

                  return GestureDetector( 
                    onTap: () {
                      appData.setToolSelected("pointer_shapes");
                      
                    },
                    child: Container(
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
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
                            color: appData.shapesList[index].strokeColor,
                          ),
                          const Padding(padding: EdgeInsets.only(right: 8)),
                          Text(
                            "${appData.shapesList[index].strokeWidth} px",
                            style: const TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                    ),
                  );
                
                }
              )
              )
          ],
        ),
      ),
    );
  }
}
