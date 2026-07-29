import 'package:flutter/material.dart';
import 'dart:ui';
//import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class FrameProcessor {
  /// Converts a native CameraImage to a normalized, resized 72x72 RGB array
  static List<double>? cropAndNormalizeFace(CameraImage cameraImage, Rect boundingBox) {
    try {
      // 1. Convert YUV420/BGRA CameraImage to RGB Image object
      final img.Image? fullImage = _convertCameraImage(cameraImage);
      if (fullImage == null) return null;

      // 2. Crop the face ROI (Region of Interest) using the bounding box
      final int x = boundingBox.left.clamp(0, fullImage.width - 1).toInt();
      final int y = boundingBox.top.clamp(0, fullImage.height - 1).toInt();
      final int w = boundingBox.width.clamp(1, fullImage.width - x).toInt();
      final int h = boundingBox.height.clamp(1, fullImage.height - y).toInt();

      final img.Image croppedFace = img.copyCrop(fullImage, x: x, y: y, width: w, height: h);

      // 3. Resize to 72x72 expected by EfficientPhys
      final img.Image resizedFace = img.copyResize(croppedFace, width: 72, height: 72);

      // 4. Flatten RGB pixels into normalized double values [0.0 - 1.0]
      final List<double> normalizedPixels = [];
      for (int py = 0; py < 72; py++) {
        for (int px = 0; px < 72; px++) {
          final pixel = resizedFace.getPixel(px, py);
          normalizedPixels.add(pixel.r / 255.0);
          normalizedPixels.add(pixel.g / 255.0);
          normalizedPixels.add(pixel.b / 255.0);
        }
      }

      return normalizedPixels;
    } catch (e) {
      return null;
    }
  }

  static img.Image? _convertCameraImage(CameraImage image) {
    // Basic Plane conversion for YUV420/BGRA
    if (image.format.group == ImageFormatGroup.yuv420) {
      return img.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: image.planes[0].bytes.buffer,
        order: img.ChannelOrder.bgra,
      );
    }
    return null;
  }
}