import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'app_data.dart';
import 'util_button_icon.dart';

class LayoutSidebarTools extends StatelessWidget {
  const LayoutSidebarTools({super.key});

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    CDKTheme theme = CDKThemeNotifier.of(context)!.changeNotifier;

    List<String> tools = ["pointer_shapes", "shape_drawing", "shape_line", "shape_multiline", "shape_rectangle", "shape_ellipsis", "view_grab"];

    return Column(
      children: tools.map((tool) {
        Color iconColor = theme.isLight
            ? appData.toolSelected == tool
                ? theme.accent
                : CDKTheme.grey800
            : appData.toolSelected == tool
                ? CDKTheme.white
                : CDKTheme.grey;

        return Container(
          padding: const EdgeInsets.only(top: 2, left: 2, right: 2),
          child: UtilButtonIcon(
              size: 28,
              isSelected: appData.toolSelected == tool,
              onPressed: () {
                appData.setToolSelected(tool);
              },
              child: SizedBox(
                  height: 24,
                  width: 24,
                  child: SvgPicture.asset('assets/images/$tool.svg',
                      colorFilter:
                          ColorFilter.mode(iconColor, BlendMode.srcIn)))),
        );
      }).toList(),
    );
  }
}
