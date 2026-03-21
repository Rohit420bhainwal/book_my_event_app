class MenuItem {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CategoryField> fields;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.fields,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['categoryId'] ?? '',           // NEW
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      fields: (json['fields'] as List<dynamic>? ?? []) // NEW
          .map((e) => CategoryField.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'categoryId': categoryId,          // NEW
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'fields': fields.map((e) => e.toJson()).toList(), // NEW
    };
  }
}

class CategoryField {
  final String key;
  final String label;
  final String type;
  final List<String> options;

  CategoryField({
    required this.key,
    required this.label,
    required this.type,
    required this.options,
  });

  factory CategoryField.fromJson(Map<String, dynamic> json) {
    return CategoryField(
      key: json['key'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? '',
      options: List<String>.from(json['options'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'type': type,
      'options': options,
    };
  }
}
