import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/views/shared/padded_body.dart';

import 'widgets/mode_child.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaddedBody(
      child: Column(
        children: [
          Container(
            height: 70,
            width: double.infinity,
            // color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Brightness Mode",
                      style: $styles.text.bodyBold.copyWith(height: 1.2),
                    ),
                    Text(
                      "Dark Mode",
                      style: $styles.text.bodySmall.copyWith(
                        height: 1.2,
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(.5),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    await showDialog(
                      context: context,
                      useRootNavigator: true,
                      builder: (context) => const NewWidget(),
                    );
                  },
                  child: Container(
                    height: 30,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      borderRadius: BorderRadius.circular($styles.corners.sm),
                    ),
                    child: Center(
                      child: Text(
                        "Change",
                        style: $styles.text.bodySmall,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class NewWidget extends StatefulWidget {
  const NewWidget({
    super.key,
  });

  @override
  State<NewWidget> createState() => _NewWidgetState();
}

class _NewWidgetState extends State<NewWidget> {
  ThemeMode _selectedTheme = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _selectedTheme = Configurations.of(context).state.themeMode;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 300,
        height: 200,
        padding: ($styles.insets.md, 0.0).insets,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular($styles.corners.md),
        ),
        child: Column(
          children: [
            Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.bottomLeft,
              margin: $styles.insets.xs.insetsBottom,
              child: Text(
                "Brightness Mode",
                style: $styles.text.bodyBold,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  for (final themeMode in ThemeMode.values)
                    ModeChild(
                      label: "${themeMode.name.capitalize} Mode",
                      value: themeMode,
                      selected: _selectedTheme,
                      onSelected: (theme) {
                        _selectedTheme = theme;
                        Configurations.of(context).state.toggleThemeMode(theme);
                        setState(() {});
                        Configurations.instance.localPref
                            .setThemeMode(_selectedTheme.name);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
