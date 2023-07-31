// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsServices {
  /// Request permission Storage
  Future<bool> requestStoragePermissions() async {
    const granted = PermissionStatus.granted;
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();
    debugPrint("Permission: $statuses");
    return (statuses[Permission.storage] == granted) &&
        (statuses[Permission.manageExternalStorage] == granted);
  }

  /// Request permission SEND SMS
  void requestSendSMSPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      // Permission.contacts,
      Permission.sms,
    ].request();
    debugPrint("Permission: $statuses");
  }

  /// Request multiple permissions at once.
  /// In this case location & storage
  void requestMultiplePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      // Permission.contacts,
      Permission.manageExternalStorage,
      Permission.sms,
    ].request();
    debugPrint("Multiple Permissions: ${statuses.values}");
  }

  /// The user opted to never again see the permission request dialog for this
  /// app. The only way to change the permission's status now is to let the
  /// user manually enable it in the system settings.
  void requestPermissionWithOpenSettings() async {
    //if (await Permission.speech.isPermanentlyDenied) {
    openAppSettings();
    //}
  }
}
