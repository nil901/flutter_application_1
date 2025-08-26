// To parse this JSON data, do
//
//     final getGetCallHistoryByPersonModelByPersonModel = getGetCallHistoryByPersonModelByPersonModelFromJson(jsonString);

import 'dart:convert';

class GetCallHistoryByPersonModel {
  bool isConnected;
  String id;

  String caller;
  String reciever;
  String duration;
  dynamic name;
  DateTime date;
  DateTime createdAt;
  DateTime updatedAt;

  GetCallHistoryByPersonModel({
    required this.isConnected,
    required this.id,

    required this.caller,
    required this.reciever,
    required this.duration,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
 
  });

  factory GetCallHistoryByPersonModel.fromJson(Map<String, dynamic> json) =>
      GetCallHistoryByPersonModel(
        isConnected: json["isConnected"],
        id: json["_id"],

        caller: json["caller"],
        reciever: json["reciever"],
        duration: json["duration"],
        name: json["name"],
        date: DateTime.parse(json["date"]),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
       
      );

  Map<String, dynamic> toJson() => {
    "isConnected": isConnected,
    "_id": id,

    "caller": caller,
    "reciever": reciever,
    "name": name,
    "duration": duration,
    "date": date.toIso8601String(),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
   
  };
}
