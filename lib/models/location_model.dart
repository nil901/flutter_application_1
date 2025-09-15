
class LocationModel {
  final String id;
  final String name;

  final int locationId;
  final int v;

  LocationModel({
    required this.id,
    required this.name,
    required this.locationId,
    required this.v,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      locationId: json["locationId"] ?? 0,
      v: json["__v"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "locationId": locationId,
      "__v": v,
    };
  }
}
