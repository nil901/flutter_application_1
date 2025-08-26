// To parse this JSON data, do
//
//     final leadIdTaskModel = leadIdTaskModelFromJson(jsonString);

import 'dart:convert';


class LeadIdTaskModel {
    String name;
    int leadId;

    LeadIdTaskModel({
        required this.name,
        required this.leadId,
    });

    factory LeadIdTaskModel.fromJson(Map<String, dynamic> json) => LeadIdTaskModel(
        name: json["name"],
        leadId: json["leadId"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "leadId": leadId,
    };
}
