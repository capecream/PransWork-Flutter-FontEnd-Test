import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';

/// หน้าจอที่ 3: ฟอร์มกรอกข้อมูลและปุ่มบันทึก/ส่งข้อมูลไปยัง backend
/// (ตอบโจทย์ข้อ 1.3-e)
class SaveDataScreen extends StatefulWidget {
  const SaveDataScreen({super.key});

  @override
  State<SaveDataScreen> createState() => _SaveDataScreenState();
}

class _SaveDataScreenState extends State<SaveDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ApiService _apiService = ApiService();

  String _category = 'General';
  bool _isUrgent = false;
  bool _isSaving = false;

  final List<String> _categories = ['General', 'Urgent', 'Follow-up'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final newItem = Item(
        id: '',
        name: _nameController.text,
        description: _descriptionController.text,
        category: _isUrgent ? 'Urgent' : _category,
      );
      await _apiService.saveItem(newItem);
      if (!mounted) return;
      _showResultModal(success: true);
      _formKey.currentState!.reset();
      _nameController.clear();
      _descriptionController.clear();
    } catch (e) {
      if (!mounted) return;
      _showResultModal(success: false, errorMessage: e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Modal แจ้งผลลัพธ์หลังกดบันทึก/ส่งข้อมูล
  void _showResultModal({required bool success, String? errorMessage}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(success ? 'บันทึกสำเร็จ' : 'เกิดข้อผิดพลาด'),
        content: Text(
          success ? 'ข้อมูลถูกส่งไปยัง backend เรียบร้อย' : (errorMessage ?? ''),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ตกลง')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อรายการ',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'กรุณากรอกชื่อ' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'รายละเอียด',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (v) => (v == null || v.isEmpty) ? 'กรุณากรอกรายละเอียด' : null,
            ),
            const SizedBox(height: 12),
            // Dropdown list เลือกหมวดหมู่ 1 รายการ
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'หมวดหมู่',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) => setState(() => _category = value ?? 'General'),
            ),
            // Checkbox เลือกเพิ่มเติมนอกเหนือจาก dropdown
            CheckboxListTile(
              value: _isUrgent,
              onChanged: (value) => setState(() => _isUrgent = value ?? false),
              title: const Text('ทำเครื่องหมายเป็นเร่งด่วน'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'กำลังบันทึก...' : 'บันทึก / ส่งข้อมูล'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
