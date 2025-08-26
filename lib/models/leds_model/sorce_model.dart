class SourceModel {
  String id;
  String name;

  SourceModel({required this.id, required this.name});

  factory SourceModel.fromJson(Map<String, dynamic> json) =>
      SourceModel(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};

  // 👇 Override == operator
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  // 👇 Override hashCode
  @override
  int get hashCode => id.hashCode;
}
