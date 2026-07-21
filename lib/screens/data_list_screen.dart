import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../widgets/item_card.dart';
import '../widgets/status_widgets.dart';

/// หน้าจอที่ 2: ดึงข้อมูลจาก API มาแสดงในรูปแบบ Cards อย่างน้อย 2 รายการ
/// รองรับ Dropdown (filter), Grid/Table (สลับมุมมองแสดงผลทั้งหมด),
/// Checkbox (เลือกได้มากกว่า 1 รายการ), และ Modal (แสดงรายละเอียด)
/// (ตอบโจทย์ข้อ 1.3-d ทั้งหมด)
class DataListScreen extends StatefulWidget {
  const DataListScreen({super.key});

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Item>> _futureItems;
  List<Item> _allItems = [];
  String _selectedCategory = 'ทั้งหมด';
  bool _showAsTable = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    _futureItems = _apiService.fetchItems();
  }

  List<Item> get _filteredItems {
    if (_selectedCategory == 'ทั้งหมด') return _allItems;
    return _allItems.where((i) => i.category == _selectedCategory).toList();
  }

  /// Modal (dialog) แสดงรายละเอียดของ item ที่เลือก
  void _showItemModal(Item item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('หมวดหมู่: ${item.category}'),
            const SizedBox(height: 8),
            Text(item.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Item>>(
      future: _futureItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }
        if (snapshot.hasError) {
          return ErrorView(
            message: 'เกิดข้อผิดพลาด: ${snapshot.error}',
            onRetry: () => setState(_loadItems),
          );
        }

        _allItems = snapshot.data ?? [];
        final categories = ['ทั้งหมด', ..._allItems.map((e) => e.category).toSet()];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Dropdown list ใช้เลือกข้อมูล 1 รายการ (filter หมวดหมู่)
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'กรองตามหมวดหมู่',
                        border: OutlineInputBorder(),
                      ),
                      items: categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value ?? 'ทั้งหมด');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    tooltip: _showAsTable ? 'ดูแบบ Card' : 'ดูแบบ Table',
                    icon: Icon(_showAsTable ? Icons.view_agenda : Icons.table_chart),
                    onPressed: () => setState(() => _showAsTable = !_showAsTable),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _showAsTable ? _buildTableView() : _buildCardListView(),
            ),
          ],
        );
      },
    );
  }

  /// แสดงข้อมูลเป็น Cards (ค่าเริ่มต้น)
  Widget _buildCardListView() {
    final items = _filteredItems;
    if (items.isEmpty) {
      return const Center(child: Text('ไม่มีข้อมูล'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ItemCard(
          item: item,
          onTap: () => _showItemModal(item),
          onCheckboxChanged: (value) {
            setState(() => item.isSelected = value ?? false);
          },
        );
      },
    );
  }

  /// Grid/Table แสดงผลข้อมูลทั้งหมด พร้อม Checkbox เลือกได้หลายรายการ
  Widget _buildTableView() {
    final items = _filteredItems;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('เลือก')),
          DataColumn(label: Text('ชื่อ')),
          DataColumn(label: Text('หมวดหมู่')),
          DataColumn(label: Text('รายละเอียด')),
        ],
        rows: items
            .map(
              (item) => DataRow(
                onSelectChanged: (_) => _showItemModal(item),
                cells: [
                  DataCell(Checkbox(
                    value: item.isSelected,
                    onChanged: (value) => setState(() => item.isSelected = value ?? false),
                  )),
                  DataCell(Text(item.name)),
                  DataCell(Text(item.category)),
                  DataCell(Text(item.description)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
