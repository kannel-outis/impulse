import 'item.dart';

abstract mixin class ServiceUploadManager {
  void setCurrentUpload(Item? current);
  void onCurrentUploadComplete();
}
