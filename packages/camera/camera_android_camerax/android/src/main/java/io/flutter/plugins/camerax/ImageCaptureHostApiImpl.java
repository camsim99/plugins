// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import java.util.Objects;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.ImageCapture;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ImageCaptureHostApi;

public class ImageCaptureHostApiImpl implements ImageCaptureHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  @VisibleForTesting public CameraXProxy cameraXProxy = new CameraXProxy();

  public ImageCaptureHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  /** Creates a {@link ImageCapture} with the requested flash mode and target resolution if specified. */
  @Override
  public void create(
      @NonNull Long identifier,
      @Nullable Long flashMode,
      @Nullable ResolutionInfo targetResolution) {
    ImageCapture.Builder imageCaptureBuilder = cameraXProxy.createImageCaptureBuilder();
    if (flashMode != null) {
      // This sets the requested flash mode, but may fail silently.
      imageCaptureBuilder.setFlashMode(flashMode);
    }
    if (targetResolution != nul) {
      imageCaptureBuilder.setTargetResolution(
          new Size(
              targetResolution.getWidth().intValue(), targetResolution.getHeight().intValue()));
    }
    ImageCapture imageCapture = imageCaptureBuilder.build();
    instanceManager.addDartCreatedInstance(imageCapture, identifier);
  }

  /** 
   * Sets the flash mode of the {@link ImageCapture} instance with the specified identifier.
   * 
   * <p>Will have no effect if there is no flash unit. See
   * https://developer.android.com/reference/androidx/camera/core/ImageCapture#setFlashMode(int)
   * for further details.
  */
  @Override
  public void setFlashMode(@NonNull Long identifier, @NonNull Long flashMode) {
    ImageCapture imageCapture = (ImageCapture) Objects.requireNonNull(instanceManager.getInstance(identifier));
    imageCapture.setFlashMode(flashMode);
  }

  /** Captures a still image and uses the result to return its absolute path in memory. */
  @Override
  public void takePicture(@NonNull Long identifier, @NonNull Result<String> result) {

  }


}
