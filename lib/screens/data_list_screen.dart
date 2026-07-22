import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';
import '../widgets/item_card.dart';
import '../widgets/status_widgets.dart';
import 'save_data_screen.dart';

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
  bool _isBulkDeleting = false;

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

  List<Item> get _selectedItems => _allItems.where((i) => i.isSelected).toList();

  /// เปิดหน้าฟอร์มแก้ไข แล้ว refresh รายการถ้าแก้ไขสำเร็จ
  Future<void> _openEdit(Item item) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => SaveDataScreen(editItem: item)),
    );
    if (result == true && mounted) {
      setState(_loadItems);
    }
  }

  /// ยืนยันก่อนลบ 1 รายการ
  Future<void> _confirmDeleteSingle(Item item) async {
    final confirmed = await _showConfirmDialog(
      title: 'ลบรายการนี้?',
      message: 'ต้องการลบ "${item.name}" ใช่หรือไม่ ย้อนกลับไม่ได้',
    );
    if (confirmed != true) return;

    try {
      await _apiService.deleteItem(item.id);
      if (!mounted) return;
      setState(_loadItems);
      _showSnackBar('ลบ "${item.name}" แล้ว');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('ลบไม่สำเร็จ: $e', isError: true);
    }
  }

  /// ยืนยันก่อนลบหลายรายการที่ติ๊กเลือกไว้
  Future<void> _confirmBulkDelete() async {
    final selected = _selectedItems;
    if (selected.isEmpty) return;

    final confirmed = await _showConfirmDialog(
      title: 'ลบ ${selected.length} รายการ?',
      message: 'ต้องการลบรายการที่เลือกไว้ทั้งหมด ${selected.length} รายการ ย้อนกลับไม่ได้',
    );
    if (confirmed != true) return;

    setState(() => _isBulkDeleting = true);
    try {
      final ids = selected.map((i) => i.id).toList();
      await _apiService.deleteItems(ids);
      if (!mounted) return;
      setState(_loadItems);
      _showSnackBar('ลบ ${selected.length} รายการแล้ว');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('ลบไม่สำเร็จ: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isBulkDeleting = false);
    }
  }

  Future<bool?> _showConfirmDialog({required String title, required String message}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(message, style: TextStyle(color: Colors.grey.shade700)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ', style: TextStyle(color: Color(0xFFE74C3C))),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFE74C3C) : const Color(0xFF00B894),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openEdit(item);
                      },
                      icon: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFF0984E3)),
                      label: const Text('แก้ไข', style: TextStyle(color: Color(0xFF0984E3))),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF0984E3).withOpacity(0.08),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDeleteSingle(item);
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFE74C3C)),
                      label: const Text('ลบ', style: TextStyle(color: Color(0xFFE74C3C))),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C).withOpacity(0.08),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
          final selectedCount = _selectedItems.length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
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
              if (selectedCount > 0) _buildBulkDeleteBar(selectedCount),
              Expanded(
                child: _showAsTable ? _buildTableView() : _buildCardListView(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// แถบแสดงจำนวนที่เลือกไว้ พร้อมปุ่มลบหลายรายการ (โผล่มาเมื่อมีการติ๊ก checkbox)
  Widget _buildBulkDeleteBar(int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE74C3C).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE74C3C).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFFE74C3C), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'เลือกแล้ว $count รายการ',
              style: const TextStyle(
                color: Color(0xFFE74C3C),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _isBulkDeleting ? null : _confirmBulkDelete,
            icon: _isBulkDeleting
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline_rounded, size: 18),
            label: Text(_isBulkDeleting ? 'กำลังลบ...' : 'ลบที่เลือก'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE74C3C),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ],
      ),
    );
  }

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
          onEdit: () => _openEdit(item),
          onDelete: () => _confirmDeleteSingle(item),
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
              DataColumn(label: Text('จัดการ')),
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
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded,
                                size: 18, color: Color(0xFF0984E3)),
                            onPressed: () => _openEdit(item),
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 18, color: Color(0xFFE74C3C)),
                            onPressed: () => _confirmDeleteSingle(item),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      )),
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
