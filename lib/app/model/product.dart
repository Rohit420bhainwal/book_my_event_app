class Product {
  final String id;
  final String category;
  final Attributes attributes;

  Product({required this.id, required this.category, required this.attributes});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      category: json['category'],
      attributes: Attributes.fromJson(json['attributes']),
    );
  }
}

class Attributes {
  final String price;
  final String description;
  final String address;
  final String documentName;

  Attributes({
    required this.price,
    required this.description,
    required this.address,
    required this.documentName,
  });

  factory Attributes.fromJson(Map<String, dynamic> json) {
    return Attributes(
      price: json['price'],
      description: json['description'],
      address: json['address'],
      documentName: json['documentName'],
    );
  }
}
