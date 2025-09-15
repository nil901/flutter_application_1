class ProductsModel {
  final String id;
  final String name;
  final int productId;

  ProductsModel({
    required this.id,
    required this.name,
    required this.productId,
  });

  factory ProductsModel.fromJson(Map<String, dynamic> json) {
    return ProductsModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      productId: json['productId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'productId': productId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductsModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
