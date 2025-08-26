// To parse this JSON data, do
//
//     final getAllGetAllMembersModelsModel = getAllGetAllMembersModelsModelFromJson(jsonString);

import 'dart:convert';

class GetAllMembersModel {
  String id;
  String firstName;
  int memberId ;
  dynamic assignedTo;

  int GetAllMembersModelId;

  GetAllMembersModel({
    required this.id,
    required this.firstName,
    required this.memberId,

    required this.GetAllMembersModelId,
  });

  factory GetAllMembersModel.fromJson(Map<String, dynamic> json) =>
      GetAllMembersModel(
        id: json["_id"],
        firstName: json["firstName"],
        memberId: json["memberId"],

        GetAllMembersModelId: json["GetAllMembersModelId"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "memberId": memberId,
    "GetAllMembersModelId": GetAllMembersModelId,
  };
}
