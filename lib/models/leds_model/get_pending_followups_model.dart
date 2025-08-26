// To parse this JSON data, do
//
//     final getPendingFollowsByMember = getPendingFollowsByMemberFromJson(jsondynamic);

import 'dart:convert';



class GetPendingFollowsByMember {
    dynamic id;
    dynamic name;
    dynamic email;
    dynamic mobile;
    dynamic source;
    dynamic website;
    dynamic createdBy; 
    dynamic position;
    dynamic industry;
    dynamic fbProfile;
    dynamic twitterProfile;
    dynamic state;
    dynamic city;
    dynamic comment;
    dynamic address;
    dynamic reference;
    dynamic branch;
    dynamic prority;
    dynamic status;
    dynamic conversionStatus;
    DateTime contactDate;
    DateTime meetingDate;
    dynamic meetingTime;
    dynamic meetingDescription;
    dynamic description;
    dynamic fbCampaignName;
    bool isDeleted;
    dynamic estimatedBudget;
    bool isStatusUpdated;
    dynamic createdAt;
    dynamic updatedAt;
    dynamic location;
    dynamic leadId;
    dynamic v;

    GetPendingFollowsByMember({
        required this.id,
        required this.name,
        required this.email,
        required this.mobile,
        required this.source,
        required this.website,
        required this.createdBy,
        required this.position,
        required this.industry,
        required this.fbProfile,
        required this.twitterProfile,
        required this.state,
        required this.city,
        required this.comment,
        required this.address,
        required this.reference,
        required this.branch,
        required this.prority,
        required this.status,
        required this.conversionStatus,
        required this.contactDate,
        required this.meetingDate,
        required this.meetingTime,
        required this.meetingDescription,
        required this.description,
        required this.fbCampaignName,
        required this.isDeleted,
        required this.estimatedBudget,
        required this.isStatusUpdated,
        required this.createdAt,
        required this.updatedAt,
        required this.leadId,
        required this.location,
        required this.v,
    });

    factory GetPendingFollowsByMember.fromJson(Map<dynamic, dynamic> json) => GetPendingFollowsByMember(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
        mobile: json["mobile"],
        source: json["source"],
        website: json["website"],
        createdBy: json["createdBy"],
        position: json["position"],
        industry: json["industry"],
        fbProfile: json["fbProfile"],
        twitterProfile: json["twitterProfile"],
        state: json["state"],
        city: json["city"],
        comment: json["comment"],
        address: json["address"],
        reference: json["reference"],
        branch: json["branch"],
        prority: json["prority"],
        status: json["status"],
        conversionStatus: json["conversionStatus"],
        contactDate: DateTime.parse(json["contactDate"]),
        meetingDate: DateTime.parse(json["meetingDate"]),
        meetingTime: json["meetingTime"],
        meetingDescription: json["meetingDescription"],
        description: json["description"],
        fbCampaignName: json["fbCampaignName"],
        isDeleted: json["isDeleted"],
        estimatedBudget: json["estimatedBudget"],
        location: json["location"],
        isStatusUpdated: json["isStatusUpdated"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        leadId: json["leadId"],
        v: json["__v"],
    );

    Map<dynamic, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
        "mobile": mobile,
        "source": source,
        "website": website,
        "createdBy": createdBy,
        "position": position,
        "industry": industry,
        "fbProfile": fbProfile,
        "twitterProfile": twitterProfile,
        "state": state,
        "city": city,
        "comment": comment,
        "address": address,
        "reference": reference,
        "branch": branch,
        "prority": prority,
        "status": status,
        "conversionStatus": conversionStatus,
        "contactDate": contactDate,
        "meetingDate": meetingDate,
        "meetingTime": meetingTime,
        "meetingDescription": meetingDescription,
        "description": description,
        "fbCampaignName": fbCampaignName,
        "isDeleted": isDeleted,
        "estimatedBudget": estimatedBudget,
        "isStatusUpdated": isStatusUpdated,
        "location": location,
        "createdAt": createdAt.toIso8601dynamic(),
        "updatedAt": updatedAt.toIso8601dynamic(),
        "leadId": leadId,
        "__v": v,
    };
}
