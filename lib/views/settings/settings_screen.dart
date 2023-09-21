import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:impulse/app/app.dart';
import 'package:impulse/views/shared/padded_body.dart';

import 'widgets/change_setting_tile.dart';
import 'widgets/select_settings_tile.dart';
import 'widgets/settings_dialog.dart';
import 'package:file_picker/file_picker.dart' as picker;

import 'widgets/settings_tile.dart';
import 'widgets/settings_tile_textfield.dart';

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
  String? _themeMode;
  late final TextEditingController _portNumberTextController;

  @override
  void initState() {
    super.initState();
    _destinationLocation = Configurations.instance.destinationLocation;
    _alwaysAcceptConnection = Configurations.instance.alwaysAcceptConnection;
    _allowToBrowseFile = Configurations.instance.allowToBrowseFile;
    _rootFolderLocation = Configurations.instance.rootFolderLocation;
    _portNumberTextController = TextEditingController(
        text: Configurations.instance.receiverPortNumber.toString());
    _themeMode = Configurations.of(context).state.themeMode.name;
  }

  @override
  Widget build(BuildContext context) {
    return PaddedBody(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const _Spacer(),
            SettingsTile(
              title: "Edit Profile",
              subTitle: "Change profile name and profile image here !",
              onTap: () {
                context.pushNamed(
                  ImpulseRouter.routes.setInfo.split("/").last,
                  queryParameters: {
                    "username": Configurations.instance.user?.name,
                    "profileImage": Configurations.instance.user?.displayImage,
                  },
                );
              },
            ),
            const _Spacer(),
            ChangeSettingsTile(
              title: "Theme Brightness",
              subTitle: "${_themeMode!.capitalize} Theme",
              onTap: () async {
                await showDialog(
                  context: context,
                  useRootNavigator: true,
                  builder: (context) {
                    return SettingsDialog<ThemeMode>(
                      title: "Theme Brightness",
                      value: Configurations.instance.themeMode,
                      values: ThemeMode.values,
                      labels: ThemeMode.values
                          .map((e) => "${e.name.capitalize} Mode")
                          .toList(),
                      onSelected: (theme) {
                        Configurations.of(context).state.toggleThemeMode(theme);
                        Configurations.instance.setThemeMode(theme);
                        _themeMode = theme.name;
                        setState(() {});
                      },
                    );
                  },
                );
              },
            ),
            const _Spacer(),
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
                      labels: const ["Allow", "Deny"],
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
            const _Spacer(),
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
                      labels: const ["Allow", "Deny"],
                      onSelected: (allow) {
                        Configurations.instance
                            .setAlwaysAcceptConnection(allow);
                        _alwaysAcceptConnection = allow;
                        setState(() {});
                      },
                    );
                  },
                );
              },
            ),
            const _Spacer(),
            SelectSettingsTile(
              title: "Storage Location",
              subTitle: _destinationLocation ?? "Select Location",
              onTap: () async {
                final path = await picker.FilePicker.platform
                    .getDirectoryPath(lockParentWindow: true);
                if (path != null) {
                  Configurations.instance.setDestinationLocation(path);
                  _destinationLocation = path;
                  setState(() {});
                }
              },
            ),
            if (!isAndroid) const _Spacer(),
            if (!isAndroid)
              SelectSettingsTile(
                title: "Root Folder Location",
                subTitle: _rootFolderLocation ?? "Select Location",
                onTap: () async {
                  final path = await picker.FilePicker.platform
                      .getDirectoryPath(lockParentWindow: true);
                  if (path != null) {
                    Configurations.instance.setRootFolderLocation(path);
                    _rootFolderLocation = path;
                    setState(() {});
                  }
                },
              ),

            ///////////////////
            /////////////////////
            const _Spacer(),
            SettingsTileTextField(
              portNumberTextController: _portNumberTextController,
            ),
            const _Spacer(),
            SettingsTile(
              title: "History",
              subTitle: "View all shared and received items",
              onTap: () {
                context.push(ImpulseRouter.routes.history);
              },
            ),
            const _Spacer(),
            SettingsTile(
              title: "Licenses",
              subTitle: "View licenses for all open source packages used",
              onTap: () {
                context.push(ImpulseRouter.routes.license);
              },
            ),
            const _Spacer(),
            SettingsTile(
              title: "About",
              subTitle: Configurations.versionNumber,
              onTap: () {
                context.push(ImpulseRouter.routes.about);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Spacer extends StatelessWidget {
  // ignore: unused_element
  const _Spacer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 20);
  }
}
