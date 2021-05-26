import 'package:flutter/material.dart';
import 'package:ml_facedetection/face_detector_camera.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ElevatedButton(
            //     onPressed: () {
            //       Navigator.of(context)
            //           .push(MaterialPageRoute(builder: (context) => null));
            //     },
            //     child: Text("Add smile face to image")),

            ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => FaceDetectorCamera()));
                },
                child: Text("Add smile face to camera")),
          ],
        ),
      ),
    );
  }
}
