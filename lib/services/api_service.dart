import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/item.dart';

class ApiService {
  final String baseUrl;

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.baseUrl;

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
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
