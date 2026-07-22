import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../widgets/item_card.dart';
import '../widgets/status_widgets.dart';

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

  static const _accent = Color(0xFF6C5CE7);

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
    final accent = CategoryStyle.colorOf(item.category);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(CategoryStyle.iconOf(item.category), color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.category,
                  style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.description,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13.5, height: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF6F5FB),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('ปิด', style: TextStyle(color: Color(0xFF2D2D3A))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F5FB),
      child: FutureBuilder<List<Item>>(
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    // Dropdown list ใช้เลือกข้อมูล 1 รายการ (filter หมวดหมู่)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            icon: const Icon(Icons.expand_more_rounded),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            items: categories
                                .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.filter_list_rounded,
                                              size: 16, color: Colors.grey.shade500),
                                          const SizedBox(width: 8),
                                          Text(c),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedCategory = value ?? 'ทั้งหมด');
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildViewToggle(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'พบ ${_filteredItems.length} รายการ',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: _showAsTable ? _buildTableView() : _buildCardListView(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ปุ่มสลับมุมมอง Card / Table แบบ segmented control
  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleButton(icon: Icons.view_agenda_rounded, selected: !_showAsTable, onTap: () {
            setState(() => _showAsTable = false);
          }),
          _toggleButton(icon: Icons.table_chart_rounded, selected: _showAsTable, onTap: () {
            setState(() => _showAsTable = true);
          }),
        ],
      ),
    );
  }

  Widget _toggleButton({
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? _accent : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 19, color: selected ? Colors.white : Colors.grey.shade500),
      ),
    );
  }

  /// แสดงข้อมูลเป็น Cards (ค่าเริ่มต้น)
  Widget _buildCardListView() {
    final items = _filteredItems;
    if (items.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text('ไม่มีข้อมูลในหมวดหมู่นี้', style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  /// Grid/Table แสดงผลข้อมูลทั้งหมด พร้อม Checkbox เลือกได้หลายรายการ
  Widget _buildTableView() {
    final items = _filteredItems;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF6F5FB)),
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
                        onChanged: (value) =>
                            setState(() => item.isSelected = value ?? false),
                      )),
                      DataCell(Text(item.name,
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: CategoryStyle.colorOf(item.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.category,
                          style: TextStyle(
                            color: CategoryStyle.colorOf(item.category),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )),
                      DataCell(Text(item.description)),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
