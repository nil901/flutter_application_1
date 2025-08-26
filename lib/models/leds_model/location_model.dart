class LocationModel {
  final String id;
  final String name;
  final int locationId;

  LocationModel({
    required this.id,
    required this.name,
    required this.locationId,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      locationId: json['location'] ?? 0,
    );
  }

  @override
  String toString() => 'LocationModel(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
