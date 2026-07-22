class Item {
  final String id;
  final String name;
  final String description;
  final String category;
  bool isSelected;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.isSelected = false,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
    };
  }
}
