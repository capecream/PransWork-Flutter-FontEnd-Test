import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/item.dart';


void main() {
  group('Item model', () {
    test('fromJson แปลงข้อมูล JSON เป็น Item ได้ถูกต้อง', () {
      final json = {
        'id': 1,
        'name': 'Test Item',
        'description': 'Test description',
        'category': 'General',
      };

      final item = Item.fromJson(json);

      expect(item.id, '1');
      expect(item.name, 'Test Item');
      expect(item.description, 'Test description');
      expect(item.category, 'General');
      expect(item.isSelected, false);
    });

    test('fromJson ใส่ค่า default เมื่อ field เป็น null', () {
      final json = {'id': 2, 'name': null, 'description': null, 'category': null};

      final item = Item.fromJson(json);

      expect(item.name, '');
      expect(item.description, '');
      expect(item.category, 'General');
    });

    test('toJson ไม่ส่ง id และ isSelected กลับไป', () {
      final item = Item(id: '1', name: 'A', description: 'B', category: 'C');
      final json = item.toJson();

      expect(json.containsKey('id'), false);
      expect(json.containsKey('isSelected'), false);
      expect(json['name'], 'A');
      expect(json['description'], 'B');
      expect(json['category'], 'C');
    });
  });
}
