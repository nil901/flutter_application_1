
import 'dart:convert';


class GetTasksAssignedByMeModel {
  String id;
  String title;
  DateTime startDate;
  DateTime endDate;
  AssignedTo assignedTo;
  AssignedTo observer;
  LeadId leadId;
  int priority;
  String description;
  bool isActive;
  int status;
  dynamic checkIn;
  dynamic checkOut;
  DateTime createdAt;
  DateTime updatedAt;
  int getTasksAssignedByMeModelId;
  int v;

  GetTasksAssignedByMeModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.assignedTo,
    required this.observer,
    required this.leadId,
    required this.priority,
    required this.description,
    required this.isActive,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.createdAt,
    required this.updatedAt,
    required this.getTasksAssignedByMeModelId,
    required this.v,
  });

  factory GetTasksAssignedByMeModel.fromJson(Map<String, dynamic> json) {
    return GetTasksAssignedByMeModel(
      id: json["_id"] ?? "",
      title: json["title"] ?? "",
      startDate: DateTime.parse(json["startDate"]),
      endDate: DateTime.parse(json["endDate"]),
      assignedTo: AssignedTo.fromJson(json["assignedTo"]),
      observer: AssignedTo.fromJson(json["observer"]),
      leadId: LeadId.fromJson(json["leadId"]),
      priority: json["priority"] ?? 0,
      description: json["description"] ?? "",
      isActive: json["isActive"] ?? false,
      status: json["status"] ?? 0,
      checkIn: json["checkIn"],
      checkOut: json["checkOut"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      getTasksAssignedByMeModelId: json["GetTasksAssignedByMeModelId"] ?? 0,
      v: json["__v"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "startDate": startDate.toIso8601String(),
        "endDate": endDate.toIso8601String(),
        "assignedTo": assignedTo.toJson(),
        "observer": observer.toJson(),
        "leadId": leadId.toJson(),
        "priority": priority,
        "description": description,
        "isActive": isActive,
        "status": status,
        "checkIn": checkIn,
        "checkOut": checkOut,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "GetTasksAssignedByMeModelId": getTasksAssignedByMeModelId,
        "__v": v,
      };
}

class AssignedTo {
  String id;
  String firstName;
  String lastName;
  String email;
  String password;
  String? phone;
  String gender;
  DateTime dateOfBirth;
  String? address;
  String? branch;
  dynamic profileImage;
  dynamic resetToken;
  dynamic otp;
  dynamic otpExpires;
  int role;
  dynamic assignedTo;
  bool assignedStatus;
  DateTime createdAt;
  DateTime updatedAt;
  int memberId;
  int v;

  AssignedTo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.phone,
    required this.gender,
    required this.dateOfBirth,
    this.address,
    this.branch,
    this.profileImage,
    this.resetToken,
    this.otp,
    this.otpExpires,
    required this.role,
    this.assignedTo,
    required this.assignedStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.memberId,
    required this.v,
  });

  factory AssignedTo.fromJson(Map<String, dynamic> json) => AssignedTo(
        id: json["_id"] ?? "",
        firstName: json["firstName"] ?? "",
        lastName: json["lastName"] ?? "",
        email: json["email"] ?? "",
        password: json["password"] ?? "",
        phone: json["phone"],
        gender: json["gender"] ?? "",
        dateOfBirth: DateTime.parse(json["dateOfBirth"]),
        address: json["address"],
        branch: json["branch"],
        profileImage: json["profileImage"],
        resetToken: json["resetToken"],
        otp: json["otp"],
        otpExpires: json["otpExpires"],
        role: json["role"] ?? 0,
        assignedTo: json["assignedTo"],
        assignedStatus: json["assignedStatus"] ?? false,
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        memberId: json["memberId"] ?? 0,
        v: json["__v"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
        "phone": phone,
        "gender": gender,
        "dateOfBirth": dateOfBirth.toIso8601String(),
        "address": address,
        "branch": branch,
        "profileImage": profileImage,
        "resetToken": resetToken,
        "otp": otp,
        "otpExpires": otpExpires,
        "role": role,
        "assignedTo": assignedTo,
        "assignedStatus": assignedStatus,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "memberId": memberId,
        "__v": v,
      };
}

class LeadId {
  String id;
  String name;
  String email;
  String phone;
  String source;
  String industry;
  String address;
  int status;
  bool isActive;
  DateTime createdAt;
  DateTime updatedAt;
  int leadId;
  int v;

  LeadId({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.source,
    required this.industry,
    required this.address,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.leadId,
    required this.v,
  });

  factory LeadId.fromJson(Map<String, dynamic> json) => LeadId(
        id: json["_id"] ?? "",
        name: json["name"] ?? "",
        email: json["email"] ?? "",
        phone: json["phone"] ?? "",
        source: json["source"] ?? "",
        industry: json["industry"] ?? "",
        address: json["address"] ?? "",
        status: json["status"] ?? 0,
        isActive: json["isActive"] ?? false,
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        leadId: json["leadId"] ?? 0,
        v: json["__v"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "source": source,
        "industry": industry,
        "address": address,
        "status": status,
        "isActive": isActive,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "leadId": leadId,
        "__v": v,
      };
}
