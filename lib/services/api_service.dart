import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/item.dart';

/// รวม logic การเรียก backend API ไว้ในที่เดียว แยกออกจาก UI
/// เพื่อให้ทดสอบ (unit test) และแก้ไขได้ง่าย โดยไม่ต้องยุ่งกับ widget
class ApiService {
  final String baseUrl;

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.baseUrl;

  /// ดึงรายการข้อมูลทั้งหมดจาก backend เช่น GET /api/items
  Future<List<Item>> fetchItems() async {
    final response = await http
        .get(Uri.parse('$baseUrl/items'))
        .timeout(AppConfig.requestTimeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    }
    throw ApiException('โหลดข้อมูลไม่สำเร็จ (สถานะ ${response.statusCode})');
  }

  /// บันทึกข้อมูลใหม่ไปยัง backend เช่น POST /api/items
  Future<Item> saveItem(Item item) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/items'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(item.toJson()),
        )
        .timeout(AppConfig.requestTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Item.fromJson(jsonDecode(response.body));
    }
    throw ApiException('บันทึกข้อมูลไม่สำเร็จ (สถานะ ${response.statusCode})');
  }

  /// แก้ไขข้อมูลที่มีอยู่แล้ว เช่น PUT /api/items/{id}
  Future<Item> updateItem(Item item) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/items/${item.id}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(item.toJson()),
        )
        .timeout(AppConfig.requestTimeout);

    if (response.statusCode == 200) {
      return Item.fromJson(jsonDecode(response.body));
    }
    throw ApiException('แก้ไขข้อมูลไม่สำเร็จ (สถานะ ${response.statusCode})');
  }

  /// ลบข้อมูล 1 รายการ เช่น DELETE /api/items/{id}
  Future<void> deleteItem(String id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/items/$id'))
        .timeout(AppConfig.requestTimeout);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException('ลบข้อมูลไม่สำเร็จ (สถานะ ${response.statusCode})');
    }
  }


  Future<int> deleteItems(List<String> ids) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/items/bulk-delete'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'ids': ids.map(int.parse).toList()}),
        )
        .timeout(AppConfig.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['deletedCount'] ?? ids.length;
    }
    throw ApiException('ลบข้อมูลไม่สำเร็จ (สถานะ ${response.statusCode})');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
