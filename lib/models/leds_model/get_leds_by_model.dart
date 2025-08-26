class GetLedsByHistoryModel {
  final String? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? source;
  final String? website;
  final CreatedBy? createdBy;
  final String? position;
  final String? industry;
  final String? fbProfile;
  final String? twitterProfile;
  final String? state;
  final String? city;
  final String? location;
  final String? comment;
  final String? address;
  final String? reference;
  final dynamic branch;
  final dynamic prority;
  final dynamic status;
  final dynamic conversionStatus;                         
  final DateTime? contactDate;
  final DateTime? meetingDate;
  final String? meetingTime;
  final String? meetingDescription;
  final String? description;
  final String? fbCampaignName;
  final bool? isDeleted;
  final dynamic estimatedBudget;
  final bool? isStatusUpdated;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic leadId;
  final dynamic flat;
  final int? v;

  GetLedsByHistoryModel({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.source,
    this.website,
    this.createdBy,
    this.position,
    this.industry,
    this.fbProfile,
    this.twitterProfile,
    this.state,
    this.city,
    this.comment,
    this.address,
    this.reference,
    this.branch,
    this.prority,
    this.location,
    this.status,
    this.conversionStatus,
    this.contactDate,
    this.meetingDate,
    this.meetingTime,
    this.meetingDescription,
    this.description,
    this.fbCampaignName,
    this.isDeleted,
    this.estimatedBudget,
    this.isStatusUpdated,
    this.createdAt,
    this.updatedAt,
    this.leadId,
    this.flat,
    this.v,
  });

  factory GetLedsByHistoryModel.fromJson(Map<String, dynamic> json) =>
      GetLedsByHistoryModel(
        id: json["_id"]?.toString(),
        name: json["name"]?.toString(),
        email: json["email"]?.toString(),
        mobile: json["mobile"]?.toString(),
        source: json["source"]?.toString(),
        website: json["website"]?.toString(),
        location: json["location"]?.toString(),
        createdBy: json["createdBy"] != null
            ? CreatedBy.fromJson(json["createdBy"])
            : null,
        position: json["position"]?.toString(),
        industry: json["industry"]?.toString(),
        fbProfile: json["fbProfile"]?.toString(),
        twitterProfile: json["twitterProfile"]?.toString(),
        state: json["state"]?.toString(),
        city: json["city"]?.toString(),
        comment: json["comment"]?.toString(),
        address: json["address"]?.toString(),
        reference: json["reference"]?.toString(),
        branch: json["branch"],
        prority: json["prority"],
        status: json["status"],
        conversionStatus: json["conversionStatus"],
        contactDate: json["contactDate"] != null
            ? DateTime.tryParse(json["contactDate"])
            : null,
        meetingDate: json["meetingDate"] != null
            ? DateTime.tryParse(json["meetingDate"])
            : null,
        meetingTime: json["meetingTime"]?.toString(),
        meetingDescription: json["meetingDescription"]?.toString(),
        description: json["description"]?.toString(),
        fbCampaignName: json["fbCampaignName"]?.toString(),
        flat: json["flatType"]?.toString(),
        isDeleted: json["isDeleted"] ?? false,
        estimatedBudget: json["estimatedBudget"],
        isStatusUpdated: json["isStatusUpdated"] ?? false,
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
        leadId: json["leadId"],
        v: json["__v"] as int?,
      );
}


class CreatedBy {
  final String? id;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? address;
  final dynamic branch;
  final String? profileImage;
  final String? resetToken;
  final String? otp;
  final dynamic otpExpires;
  final int? role;
  final dynamic assignedTo;
  final bool? assignedStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? password;
  final int? memberId;
  final int? v;

  CreatedBy({
    this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    this.email,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.branch,
    this.profileImage,
    this.resetToken,
    this.otp,
    this.otpExpires,
    this.role,
    this.assignedTo,
    this.assignedStatus,
    this.createdAt,
    this.updatedAt,
    this.password,
    this.memberId,
    this.v,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        id: json["_id"]?.toString(),
        firstName: json["firstName"]?.toString(),
        middleName: json["middleName"]?.toString(),
        lastName: json["lastName"]?.toString(),
        email: json["email"]?.toString(),
        phone: json["phone"]?.toString(),
        gender: json["gender"]?.toString(),
        dateOfBirth: json["dateOfBirth"] != null
            ? DateTime.tryParse(json["dateOfBirth"])
            : null,
        address: json["address"]?.toString(),
        branch: json["branch"],
        profileImage: json["profileImage"]?.toString(),
        resetToken: json["resetToken"]?.toString(),
        otp: json["otp"]?.toString(),
        otpExpires: json["otpExpires"],
        role: json["role"] as int?,
        assignedTo: json["assignedTo"],
        assignedStatus: json["assignedStatus"] == true,
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"])
            : null,
        password: json["password"]?.toString(),
        memberId: json["memberId"] as int?,
        v: json["__v"] as int?,
      );
}
