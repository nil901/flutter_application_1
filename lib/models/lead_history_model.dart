class LeadHistoryManageModel {
  final String id;
  final int? status;
  final String meetingDate;
  final String meetingTime;
  final String remark;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeadHistoryManageModel({
    required this.id,
    required this.status,
    required this.meetingDate,
    required this.meetingTime,
    required this.remark,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeadHistoryManageModel.fromJson(Map<String, dynamic> json) {
    return LeadHistoryManageModel(
      id: json["_id"]?.toString() ?? '',
      status:
          json["status"] != null
              ? int.tryParse(json["status"].toString())
              : null,
      meetingDate: json["meetingDate"]?.toString() ?? '',
      meetingTime: json["meetingTime"]?.toString() ?? '',
      remark: json["remark"]?.toString() ?? '',
      createdAt: DateTime.tryParse(json["createdAt"] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "status": status,
    "meetingDate": meetingDate,
    "meetingTime": meetingTime,
    "remark": remark,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
  };
}
