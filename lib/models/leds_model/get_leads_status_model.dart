class GetLeadStatusUpdateModel {
  final dynamic? id;
  final dynamic? name;
  final dynamic? email;
  final dynamic? mobile;
  final dynamic? source;
  final dynamic? location;
  final dynamic? website;
  final CreatedBy? createdBy;
  final dynamic? position;
  final dynamic? industry;
  final dynamic? fbProfile;
  final dynamic? twitterProfile;
  final dynamic? state;
  final dynamic? city;
  final dynamic? comment;
  final dynamic? address;
  final dynamic? reference;
  final dynamic? branch;
  final int? prority;
  final int? status;
  final int? conversionStatus;
  final dynamic? contactDate;
  final dynamic? meetingDate;
  final dynamic? meetingTime;
  final dynamic? meetingDescription;
  final dynamic? description;
  final dynamic? fbCampaignName;
  final bool? isDeleted;
  final int? estimatedBudget;
  final bool? isStatusUpdated;
  final dynamic? createdAt;
  final dynamic? updatedAt;
  final int? leadId;
  final dynamic? flatType;

  GetLeadStatusUpdateModel({
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
    this.flatType,
    this.location,
  });

  factory GetLeadStatusUpdateModel.fromJson(Map<dynamic, dynamic> json) {
    return GetLeadStatusUpdateModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      source: json['source'],
      website: json['website'],
      createdBy:
          json['createdBy'] != null
              ? CreatedBy.fromJson(json['createdBy'])
              : null,
      position: json['position'],
      industry: json['industry'],
      fbProfile: json['fbProfile'],
      twitterProfile: json['twitterProfile'],
      state: json['state'],
      city: json['city'],
      comment: json['comment'],
      address: json['address'],
      reference: json['reference'],
      branch: json['branch'],
      prority: json['prority'],
      status: json['status'],
      conversionStatus: json['conversionStatus'],
      contactDate: json['contactDate'],
      meetingDate: json['meetingDate'],
      meetingTime: json['meetingTime'],
      meetingDescription: json['meetingDescription'],
      description: json['description'],
      fbCampaignName: json['fbCampaignName'],
      isDeleted: json['isDeleted'],
      estimatedBudget: json['estimatedBudget'],
      isStatusUpdated: json['isStatusUpdated'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      leadId: json['leadId'],
      flatType: json['flatType'],
      location: json['location'],
    );
  }
}

class CreatedBy {
  final dynamic? id;
  final dynamic? middleName;
  final dynamic? profileImage;
  final dynamic? otp;
  final dynamic? otpExpires;
  final dynamic? assignedTo;
  final dynamic? assignedStatus;
  final dynamic? firstName;
  final dynamic? lastName;
  final dynamic? email;
  final dynamic? phone;
  final dynamic? gender;
  final dynamic? dateOfBirth;
  final dynamic? address;
  final dynamic? branch;
  final dynamic? resetToken;
  final int? role;
  final dynamic? createdAt;
  final dynamic? updatedAt;
  final int? memberId;
  

  final dynamic? password;

  CreatedBy({
    this.id,
    this.middleName,
    this.profileImage,
    this.otp,
    this.otpExpires,
    this.assignedTo,
    this.assignedStatus,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.branch,
    this.resetToken,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.memberId,
    // this.flatType,

    this.password,
  });

  factory CreatedBy.fromJson(Map<dynamic, dynamic> json) {
    return CreatedBy(
      id: json['_id'],
      middleName: json['middleName'],
      profileImage: json['profileImage'],
      otp: json['otp'],
      otpExpires: json['otpExpires'],
      assignedTo: json['assignedTo'],
      assignedStatus: json['assignedStatus'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      address: json['address'],
      branch: json['branch'],
      resetToken: json['resetToken'],
      role: json['role'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      memberId: json['memberId'],
      // flatType: json['flatType'] ,
      password: json['password'],
    );
  }
}
