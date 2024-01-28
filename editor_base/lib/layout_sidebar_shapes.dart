import 'package:editor_base/layout_shapes_listview.dart';
import 'package:flutter/cupertino.dart';
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
                    ShapesListView(
                      shapesList: appData.shapesList,
                    ),
                  ],
                ),
              ),
            );
        
  }
}

