// To parse this JSON data, do
//
//     final getAllgetAllLeadsModelsModel = getAllgetAllLeadsModelsModelFromJson(jsonString);

import 'dart:convert';

class getAllLeadsModel {
  dynamic id;
  dynamic name;
  dynamic leadId;

  getAllLeadsModel({
    required this.id,
    required this.name,
    required this.leadId,
  });

  factory getAllLeadsModel.fromJson(Map<String, dynamic> json) =>
      getAllLeadsModel(
        id: json["_id"],
        name: json["name"],
        leadId: json["leadId"]??"",
      );

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "leadId": leadId};
}
