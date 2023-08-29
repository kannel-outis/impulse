import 'package:flutter/material.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/views/shared/padded_body.dart';

import 'widgets/settings_dialog.dart';
import 'package:file_picker/file_picker.dart' as picker;

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String? _destinationLocation;
  String? _rootFolderLocation;
  bool _alwaysAcceptConnection = false;
  bool _allowToBrowseFile = false;

  @override
  void initState() {
    super.initState();
    _destinationLocation = Configurations.instance.destinationLocation;
    _alwaysAcceptConnection = Configurations.instance.alwaysAcceptConnection;
    _allowToBrowseFile = Configurations.instance.allowToBrowseFile;
    _rootFolderLocation = Configurations.instance.rootFolderLocation;
  }

  @override
  Widget build(BuildContext context) {
    return PaddedBody(
      child: Column(
        children: [
          ChangeSettingsTile(
            title: "Brightness Mode",
            subTitle: "Change App Theme",
            onTap: () async {
              await showDialog(
                context: context,
                useRootNavigator: true,
                builder: (context) {
                  return SettingsDialog<ThemeMode>(
                    title: "Brightness Mode",
                    value:
                        Configurations.instance.themeMode ?? ThemeMode.system,
                    values: ThemeMode.values,
                    labels: ThemeMode.values
                        .map((e) => "${e.name.capitalize} Mode")
                        .toList(),
                    onSelected: (theme) {
                      Configurations.of(context).state.toggleThemeMode(theme);
                      Configurations.instance.setThemeMode(theme);
                    },
                  );
                },
              );
            },
          ),
          ChangeSettingsTile(
            title: "Allow Browse File",
            subTitle: "Allow browse file on connection: $_allowToBrowseFile",
            onTap: () async {
              await showDialog(
                context: context,
                useRootNavigator: true,
                builder: (context) {
                  return SettingsDialog<bool>(
                    title: "Allow Browse File",
                    value: _allowToBrowseFile,
                    values: const [true, false],
                    labels: const ["True", "False"],
                    onSelected: (allow) {
                      Configurations.instance.setAllowToBrowseFile(allow);
                      _allowToBrowseFile = allow;
                      setState(() {});
                    },
                  );
                },
              );
            },
          ),
          ChangeSettingsTile(
            title: "Always Accept Connection",
            subTitle:
                "Always Allow Connections, Don't Fling: $_alwaysAcceptConnection",
            onTap: () async {
              await showDialog(
                context: context,
                useRootNavigator: true,
                builder: (context) {
                  return SettingsDialog<bool>(
                    title: "Always Accept Connection",
                    value: _alwaysAcceptConnection,
                    values: const [true, false],
                    labels: const ["True", "False"],
                    onSelected: (allow) {
                      Configurations.instance.setAlwaysAcceptConnection(allow);
                      _alwaysAcceptConnection = allow;
                      setState(() {});
                    },
                  );
                },
              );
            },
          ),
          SelectSettingsTile(
            title: "Storage Location",
            subTitle: _destinationLocation ?? "Select Location",
            onTap: () async {
              final path = await picker.FilePicker.platform.getDirectoryPath();
              if (path != null) {
                Configurations.instance.setDestinationLocation(path);
                _destinationLocation = path;
                setState(() {});
              }
            },
          ),
          if (!isAndroid)
            SelectSettingsTile(
              title: "Root Folder Location",
              subTitle: _rootFolderLocation ?? "Select Location",
              onTap: () async {
                final path =
                    await picker.FilePicker.platform.getDirectoryPath();
                if (path != null) {
                  Configurations.instance.setRootFolderLocation(path);
                  _rootFolderLocation = path;
                  setState(() {});
                }
              },
            ),

          ///////////////////
          /////////////////////
          SizedBox(
            height: 70,
            width: MediaQuery.of(context).size.width,
            // color: Colors.black,
            child: LayoutBuilder(builder: (context, constraints) {
              return SizedBox(
                height: 70,
                width: constraints.maxWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Port Number",
                          style: $styles.text.bodyBold.copyWith(height: 1.2),
                        ),
                        SizedBox(
                          width: constraints.maxWidth - 90,
                          child: Text(
                            "Will only be used when connected as a receiver",
                            maxLines: 5,
                            style: $styles.text.bodySmall.copyWith(
                              height: 1.2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiary
                                  .withOpacity(.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 80.scale,
                      height: 60,
                      child: TextField(
                        cursorColor: Theme.of(context).colorScheme.tertiary,
                        style: $styles.text.body.copyWith(letterSpacing: 2),

                        // cursorHeight: 15,
                        maxLength: 5,
                        maxLines: 1,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 20.scale,
                            horizontal: $styles.insets.xs,
                          ),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .tertiary
                              .withOpacity(.1),
                          focusColor: Theme.of(context).colorScheme.tertiary,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}

class SelectSettingsTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final VoidCallback? onTap;
  const SelectSettingsTile({
    super.key,
    required this.title,
    required this.subTitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: MediaQuery.of(context).size.width,
      // color: Colors.black,
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          height: 70,
          width: constraints.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: $styles.text.bodyBold.copyWith(height: 1.2),
                  ),
                  SizedBox(
                    width: constraints.maxWidth - 90,
                    child: Text(
                      subTitle,
                      maxLines: 5,
                      style: $styles.text.bodySmall.copyWith(
                        height: 1.2,
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(.5),
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  height: 30,
                  width: 80.scale,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    borderRadius: BorderRadius.circular($styles.corners.sm),
                  ),
                  child: Center(
                    child: Text(
                      "Select",
                      style: $styles.text.bodySmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class ChangeSettingsTile extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final String subTitle;
  const ChangeSettingsTile({
    super.key,
    required this.title,
    required this.subTitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: double.infinity,
      // color: Colors.black,
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          height: 70,
          width: constraints.maxWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: $styles.text.bodyBold.copyWith(height: 1.2),
                  ),
                  SizedBox(
                    width: constraints.maxWidth - 90,
                    child: Text(
                      subTitle,
                      maxLines: 5,
                      style: $styles.text.bodySmall.copyWith(
                        height: 1.2,
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(.5),
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  height: 30,
                  width: 80.scale,
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
        );
      }),
    );
  }
}
