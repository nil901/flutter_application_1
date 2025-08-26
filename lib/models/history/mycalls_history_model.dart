// To parse this JSON data, do
//
//     final myCallHistoryModel = myCallHistoryModelFromJson(jsonString);

import 'dart:convert';



class MyCallHistoryModel {
    String id;
    dynamic memberId;
    String caller;
    String reciever;
    String duration;
    dynamic name;
    DateTime date;
    dynamic status;



    MyCallHistoryModel({
        required this.id,
        required this.memberId,
        required this.caller,
        required this.reciever,
        required this.duration,
        required this.date,
        required this.name,
        required this.status,
     
    });

    factory MyCallHistoryModel.fromJson(Map<String, dynamic> json) => MyCallHistoryModel(
    id: json["_id"],
    memberId: json["memberId"],
    caller: json["caller"],
    reciever: json["reciever"],
    duration: json["duration"],
    name: json["name"],
    status: json["status"],
    date: DateTime.parse(json["date"]),
);

Map<String, dynamic> toJson() => {
    "_id": id,
    "memberId": memberId,
    "caller": caller,
    "reciever": reciever,
    "duration": duration,
    "name": name,
    "status": status,
    "date": date.toIso8601String(),
};
}