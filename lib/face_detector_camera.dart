import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:ml_facedetection/camera_image_converter.dart';
import 'package:ml_facedetection/camera_view.dart';
import 'package:ml_facedetection/painters/face_detector_painter.dart';
import 'package:image/image.dart' as image_;
import 'package:bitmap/bitmap.dart' as bitmap;

class FaceDetectorCamera extends StatefulWidget {
  @override
  _FaceDetectorCameraState createState() => _FaceDetectorCameraState();
}

class _FaceDetectorCameraState extends State<FaceDetectorCamera> {
  final FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
          enableContours: false,
          mode: FaceDetectorMode.accurate,
          enableTracking: true));

  bool isDetecting = false;

  CustomPaint? customPaint;

  CameraImageConverter _cameraImageConverter = CameraImageConverter();

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Face Detector',
      customPaint: customPaint,
      onImage: (inputImage, cameraImage) {
        processImage(inputImage, cameraImage);
      },
    );
  }

  Future<void> processImage(
      InputImage inputImage, CameraImage? cameraImage) async {
    if (isDetecting) return;
    isDetecting = true;

    List<Face> faces = await faceDetector.processImage(inputImage);
    print('Found ${faces.length} faces');
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      try {
        var croppedImages = await cropFaces(faces, cameraImage);
        customPaint = CustomPaint(
          painter: painter,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              width: 100,
              height: 100,
              child: Image.memory(
                Uint8List.fromList(image_.encodeJpg(croppedImages)),
                scale: 0.1,
              ),
            ),
          ),
        );
      } catch (e) {
        print(e);
      }
    } else {
      customPaint = null;
    }

    isDetecting = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<image_.Image> cropFaces(
      List<Face> faces, CameraImage? cameraImage) async {
    List cropImages = [];
    List<Map<String, int>> faceMaps = [];
    for (Face face in faces) {
      int x = face.boundingBox.left.toInt();
      int y = face.boundingBox.top.toInt();
      int w = face.boundingBox.width.toInt();
      int h = face.boundingBox.height.toInt();
      Map<String, int> thisMap = {'x': x, 'y': y, 'w': w, 'h': h};
      faceMaps.add(thisMap);
    }

    var image = _cameraImageConverter.convert(cameraImage!);
    // cropImages.add(jpeg);
    return image;
  }
}

Future<ui.Image> bytesToImage(Uint8List imgBytes) async {
  ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
  ui.FrameInfo frame = await codec.getNextFrame();

  return frame.image;
}
