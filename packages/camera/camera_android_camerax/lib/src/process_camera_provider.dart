// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'android_camera_camerax_flutter_api_impls.dart';
import 'camera_info.dart';
import 'camerax_library.pigeon.dart';
import 'instance_manager.dart';
import 'java_object.dart';

/// Provides an object to manage the camera.
///
/// See https://developer.android.com/reference/androidx/camera/lifecycle/ProcessCameraProvider.
class ProcessCameraProvider extends JavaObject {
  /// Creates a detached [ProcessCameraProvider].
  ProcessCameraProvider.detached(
      {this.binaryMessenger, InstanceManager? instanceManager})
      : super.detached(
            binaryMessenger: binaryMessenger,
            instanceManager: instanceManager) {
    this.instanceManger = instanceManager ?? JavaObject.globalInstanceManager;
    _api = ProcessCameraProviderHostApiImpl(binaryMessenger: binaryMessenger);
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
  }

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

  late final ProcessCameraProviderHostApiImpl _api;

  /// Gets an instance of [ProcessCameraProvider].
  static Future<ProcessCameraProvider> getInstance(
      {BinaryMessenger? binaryMessenger, InstanceManager? instanceManager}) {
    AndroidCameraXCameraFlutterApis.instance.ensureSetUp();
    final ProcessCameraProviderHostApiImpl api =
        ProcessCameraProviderHostApiImpl(binaryMessenger: binaryMessenger);

    return api.getInstancefromInstances(instanceManager);
  }

  /// Retrieves the cameras available to the device.
  Future<List<CameraInfo>> getAvailableCameraInfos() {
    return _api.getAvailableCameraInfosFromInstances(this, instanceManager);
  }
}

/// Host API implementation of [ProcessCameraProvider].
class ProcessCameraProviderHostApiImpl extends ProcessCameraProviderHostApi {
  /// Creates a [ProcessCameraProviderHostApiImpl].
  ProcessCameraProviderHostApiImpl({super.binaryMessenger});

  /// Retrieves an instance of a ProcessCameraProvider from the context of
  /// the FlutterActivity.
  Future<ProcessCameraProvider> getInstancefromInstances(
    InstanceManager instanceManager) async {
    return instanceManager.getInstanceWithWeakReference(await getInstance())!
        as ProcessCameraProvider;
  }

  /// Retrives the list of CameraInfos corresponding to the available cameras.
  Future<List<CameraInfo>> getAvailableCameraInfosFromInstances(
      CameraInfo instance,
      InstanceManager instanceManager,
      BinaryMessenger? binaryMessenger) async {
    int? identifier = instanceManager.getIdentifier(instance);
    identifier ??= instanceManager.addDartCreatedInstance(instance,
        onCopy: (ProcessCameraProvider original) {
      return ProcessCameraProvider.detached(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager);
    });

    final List<int?> cameraInfos = await getAvailableCameraInfos(identifier);
    return (cameraInfos.map<CameraInfo>((int? id) =>
            instanceManager.getInstanceWithWeakReference(id!)! as CameraInfo))
        .toList();
  }
}

/// Flutter API Implementation of [ProcessCameraProvider].
class ProcessCameraProviderFlutterApiImpl
    implements ProcessCameraProviderFlutterApi {
  /// Constructs a [ProcessCameraProviderFlutterApiImpl].
  ProcessCameraProviderFlutterApiImpl({
    this.binaryMessenger,
    InstanceManager? instanceManager,
  }) : instanceManager = instanceManager ?? JavaObject.globalInstanceManager;

  /// Receives binary data across the Flutter platform barrier.
  ///
  /// If it is null, the default BinaryMessenger will be used which routes to
  /// the host platform.
  final BinaryMessenger? binaryMessenger;

  /// Maintains instances stored to communicate with native language objects.
  final InstanceManager instanceManager;

  @override
  void create(int identifier) {
    instanceManager.addHostCreatedInstance(
      ProcessCameraProvider.detached(),
      identifier,
      onCopy: (ProcessCameraProvider original) {
        return ProcessCameraProvider.detached();
      },
    );
  }
}
