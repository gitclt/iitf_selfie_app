// To parse this JSON data, do
//
//     final apiKeyModel = apiKeyModelFromJson(jsonString);

import 'dart:convert';

ApiKeyModel apiKeyModelFromJson(String str) =>
    ApiKeyModel.fromJson(json.decode(str));

String apiKeyModelToJson(ApiKeyModel data) => json.encode(data.toJson());

class ApiKeyModel {
  bool? status;
  String? message;
  List<KeyData>? data;

  ApiKeyModel({
    this.status,
    this.message,
    this.data,
  });

  factory ApiKeyModel.fromJson(Map<String, dynamic> json) => ApiKeyModel(
        status: json["status"],
        message: json["Message"],
        data: json["data"] == null
            ? []
            : List<KeyData>.from(json["data"]!.map((x) => KeyData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "Message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class KeyData {
  String? key;

  KeyData({
    this.key,
  });

  factory KeyData.fromJson(Map<String, dynamic> json) => KeyData(
        key: json["key"],
      );

  Map<String, dynamic> toJson() => {
        "key": key,
      };
}
