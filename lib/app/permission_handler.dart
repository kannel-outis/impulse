import 'package:impulse_utils/impulse_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class ImpulsePermissionHandler {
  static Future<bool> checkStoragePermission() async {
    final request = (await _sdkInt) >= 30
        ? await Permission.manageExternalStorage.request()
        : await Permission.storage.request();
    if (request.isGranted) {
      return true;
    } else if (request.isDenied) {
      return false;
    } else if (request.isPermanentlyDenied) {
      final openSettings = await openAppSettings();
      return openSettings;
    } else {
      return false;
    }
  }

  static Future<int> get _sdkInt async =>
      await ImpulseUtils().getPlatformSdkInt() ?? 0;
}
