import 'package:image/image.dart';

// To parse this JSON data, do
// https://app.quicktype.io/
//     final faceData = faceDataFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

UnrecognizedFace unrecognizedFaceFromJson(String str) =>
    UnrecognizedFace.fromJson(json.decode(str));

String unrecognizedFaceToJson(UnrecognizedFace data) =>
    json.encode(data.toJson());

class UnrecognizedFace {
  UnrecognizedFace({
    required this.trackingId,
    required this.faceBytes,
    required this.position,
  });

  int? trackingId;
  List<int> faceBytes;
  List<int> position;

  UnrecognizedFace copyWith({
    int? trackingId,
    List<int>? faceBytes,
    List<int>? position,
  }) =>
      UnrecognizedFace(
        trackingId: trackingId ?? this.trackingId,
        faceBytes: faceBytes ?? this.faceBytes,
        position: position ?? this.position,
      );

  factory UnrecognizedFace.fromJson(Map<String, dynamic> json) =>
      UnrecognizedFace(
        trackingId: (json["tracking_id"] == null ? null : json["tracking_id"])!,
        faceBytes: (json["face_bytes"] == null
            ? null
            : List<int>.from(json["face_bytes"].map((x) => x)))!,
        position: (json["position"] == null
            ? null
            : List<int>.from(json["position"].map((x) => x)))!,
      );

  Map<String, dynamic> toJson() => {
        "tracking_id": trackingId,
        "face_bytes": List<dynamic>.from(faceBytes.map((x) => x)),
        "position": List<dynamic>.from(position.map((x) => x)),
      };
}

RecognizedFace recognizedFaceFromJson(String str) =>
    RecognizedFace.fromJson(json.decode(str));

String recognizedFaceToJson(RecognizedFace data) => json.encode(data.toJson());

class RecognizedFace {
  RecognizedFace({
    required this.trackingId,
    required this.faceBytes,
    required this.position,
    required this.name,
  });

  List<int> faceBytes;
  List<int> position;
  String name;
  int trackingId;

  RecognizedFace copyWith({
    int? trackingId,
    List<int>? faceBytes,
    List<int>? position,
    String? name,
  }) =>
      RecognizedFace(
        trackingId: trackingId ?? this.trackingId,
        faceBytes: faceBytes ?? this.faceBytes,
        position: position ?? this.position,
        name: name ?? this.name,
      );

  factory RecognizedFace.fromJson(Map<String, dynamic> json) => RecognizedFace(
        trackingId: json["trackingId"] == null ? null : json["trackingId"],
        faceBytes: (json["face_bytes"] == null
            ? null
            : List<int>.from(json["face_bytes"].map((x) => x)))!,
        position: (json["position"] == null
            ? null
            : List<int>.from(json["position"].map((x) => x)))!,
        name: json["name"] == null ? null : json["name"],
      );

  Map<String, dynamic> toJson() => {
        "trackingId": trackingId,
        "face_bytes": List<dynamic>.from(faceBytes.map((x) => x)),
        "position": List<dynamic>.from(position.map((x) => x)),
        "name": name,
      };
}
