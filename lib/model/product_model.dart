class Product {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String category;
  final String? imagePath;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.category,
    this.imagePath,
    required this.createdAt,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? category,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'category': category,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      category: json['category'],
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
