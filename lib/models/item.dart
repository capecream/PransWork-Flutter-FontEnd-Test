/// Model ตัวอย่างสำหรับข้อมูลที่ดึงมาจาก / ส่งไปยัง backend
/// ปรับ field ให้ตรงกับ Entity จริงฝั่ง .NET Core ได้ภายหลัง
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

  /// ไม่ส่ง id และ isSelected กลับไป เพราะเป็นค่าที่ backend สร้างเอง /
  /// เป็น state เฉพาะฝั่ง UI เท่านั้น
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
    };
  }
}
