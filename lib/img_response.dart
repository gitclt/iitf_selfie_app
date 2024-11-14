// To parse this JSON data, do
//
//     final imageUploadModel = imageUploadModelFromJson(jsonString);

import 'dart:convert';

ImageUploadModel imageUploadModelFromJson(String str) =>
    ImageUploadModel.fromJson(json.decode(str));

String imageUploadModelToJson(ImageUploadModel data) =>
    json.encode(data.toJson());

class ImageUploadModel {
  bool? status;
  String? message;
  String? path;

  ImageUploadModel({
    this.status,
    this.message,
    this.path,
  });

  factory ImageUploadModel.fromJson(Map<String, dynamic> json) =>
      ImageUploadModel(
        status: json["status"],
        message: json["Message"],
        path: json["path"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "Message": message,
        "path": path,
      };
}
