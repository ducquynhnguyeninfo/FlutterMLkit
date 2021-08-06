import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:ml_facedetection/models/recognition_model.dart';
import 'package:ml_facedetection/services/camera_image_converter.dart';
import 'package:ml_facedetection/camera_view.dart';
import 'package:ml_facedetection/painters/face_detector_painter.dart';
import 'package:image/image.dart' as image_;
import 'package:ml_facedetection/services/streaming_service.dart';

import 'home.dart';

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
  late StreamingService _streamingService;

  @override
  void initState() {
    super.initState();
    _streamingService = StreamingService(this.onServerFeedback);
  }

  @override
  void dispose() {
    faceDetector.close();
    _streamingService.dispose();
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
        var croppedFaces = await cropFaces(faces, cameraImage);
        customPaint = CustomPaint(
          painter: painter,
          child: Align(
              alignment: Alignment.bottomCenter, child: faceView(croppedFaces)),
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

  Future<List<image_.Image>> cropFaces(
      List<Face> faces, CameraImage? cameraImage) async {
    List<image_.Image> cropImages = [];

    var image = await _cameraImageConverter.convert(cameraImage!);

    for (Face face in faces) {
      int x = face.boundingBox.left.toInt();
      int y = face.boundingBox.top.toInt();
      int w = face.boundingBox.width.toInt();
      int h = face.boundingBox.height.toInt();

      if (faces.length < 2) {
        image = image_.copyRotate(image, 180);
      }

      var copyCropFace = image_.copyCrop(image, x, y, w, h);
      var encodeJpg = image_.encodeJpg(copyCropFace);
      addToFaceStorage(encodeJpg);

      cropImages.add(copyCropFace);
      if (faceDetector.options.enableTracking) {
        var trackingId = face.trackingId;

        _streamingService.send = UnrecognizedFace(
          trackingId: trackingId,
          faceBytes: encodeJpg,
          position: [x, y, w, h],
        ).toJson();

        // _streamingService.send = trackingId.toString();
      }
    }

    return cropImages;
  }

  Widget faceView(List<image_.Image> croppedFaces) {
    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
      ),
      physics: NeverScrollableScrollPhysics(),
      // shrinkWrap: true,
      children: croppedFaces
          .map((e) => SizedBox(
                width: 80,
                height: 80,
                child: Image.memory(
                  Uint8List.fromList(image_.encodeJpg(e)),
                  scale: 0.1,
                ),
              ))
          .toList(),
    );
  }

  void addToFaceStorage(List<int> encodedImg) {
    faceStorage.add(encodedImg);
  }

  Future onServerFeedback(RecognizedFace recognizedFace) async {
    print("recognized " + recognizedFace.trackingId.toString());
  }
}
