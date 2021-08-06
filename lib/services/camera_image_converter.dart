import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:image/image.dart' as imglib;

import 'package:camera/camera.dart';

typedef convert_func = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Int32, Int32, Int32, Int32);
typedef Convert = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, int, int);

class CameraImageConverter {
  final DynamicLibrary convertImageLib = Platform.isAndroid
      ? DynamicLibrary.open("libconvertImage.so")
      : DynamicLibrary.process();
  late Convert conv;

  CameraImageConverter() {
    // Load the convertImage() function from the library
    conv = convertImageLib
        .lookup<NativeFunction<convert_func>>('convertImage')
        .asFunction<Convert>();
    print('initializing converter...');
  }

  Future<imglib.Image> convert(CameraImage cameraImage) async {
    late imglib.Image img;

    if (Platform.isAndroid) {
      // Allocate memory for the 3 planes of the image
      Pointer<Uint8> p = calloc.allocate(cameraImage.planes[0].bytes.length);
      Pointer<Uint8> p1 = calloc.allocate(cameraImage.planes[1].bytes.length);
      Pointer<Uint8> p2 = calloc.allocate(cameraImage.planes[2].bytes.length);

      // Assign the planes data to the pointers of the image
      Uint8List pointerList = p.asTypedList(cameraImage.planes[0].bytes.length);
      Uint8List pointerList1 =
          p1.asTypedList(cameraImage.planes[1].bytes.length);
      Uint8List pointerList2 =
          p2.asTypedList(cameraImage.planes[2].bytes.length);
      pointerList.setRange(
          0, cameraImage.planes[0].bytes.length, cameraImage.planes[0].bytes);
      pointerList1.setRange(
          0, cameraImage.planes[1].bytes.length, cameraImage.planes[1].bytes);
      pointerList2.setRange(
          0, cameraImage.planes[2].bytes.length, cameraImage.planes[2].bytes);

      // Call the convertImage function and convert the YUV to RGB
      Pointer<Uint32> imgP = conv(
          p,
          p1,
          p2,
          cameraImage.planes[1].bytesPerRow,
          cameraImage.planes[1].bytesPerPixel!,
          cameraImage.width,
          cameraImage.height);

      // Get the pointer of the data returned from the function to a List
      List<int> imgData = imgP.asTypedList(
          (cameraImage.planes[0].bytesPerRow * cameraImage.height));
      // Generate image from the converted data
      img = imglib.Image.fromBytes(
          cameraImage.height, cameraImage.planes[0].bytesPerRow, imgData);

      // Free the memory space allocated
      // from the planes and the converted data
      calloc.free(p);
      calloc.free(p1);
      calloc.free(p2);
      calloc.free(imgP);
    } else if (Platform.isIOS) {
      img = imglib.Image.fromBytes(
        cameraImage.planes[0].bytesPerRow,
        cameraImage.height,
        cameraImage.planes[0].bytes,
        format: imglib.Format.bgra,
      );
    }

    return img;
  }
}
