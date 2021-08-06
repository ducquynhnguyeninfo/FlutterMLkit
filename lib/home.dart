import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;
import 'package:ml_facedetection/face_detector_camera.dart';

List<List<int>> faceStorage = [];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                ),
                physics: NeverScrollableScrollPhysics(),
                // shrinkWrap: true,
                children: faceStorage
                    .map((List<int> e) => SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.memory(
                            Uint8List.fromList(e),
                            scale: 0.1,
                          ),
                        ))
                    .toList(),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: ElevatedButton(
                    onPressed: () async {
                      faceStorage = [];
                      await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FaceDetectorCamera()));
                      setState(() {});
                    },
                    child: Text("Start detector")),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
