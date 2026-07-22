import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/api_service.dart';

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

  static const _accent = Color(0xFF6C5CE7);
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
      setState(() => _isUrgent = false);
    } catch (e) {
      if (!mounted) return;
      _showResultModal(success: false, errorMessage: e.toString());
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Modal แจ้งผลลัพธ์หลังกดบันทึก/ส่งข้อมูล
  void _showResultModal({required bool success, String? errorMessage}) {
    final color = success ? const Color(0xFF00B894) : const Color(0xFFE74C3C);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(
                  success ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                success ? 'บันทึกสำเร็จ' : 'เกิดข้อผิดพลาด',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                success ? 'ข้อมูลถูกส่งไปยัง backend เรียบร้อย' : (errorMessage ?? ''),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('ตกลง'),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('ชื่อรายการ'),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('เช่น จัดซื้ออุปกรณ์ใหม่'),
                      validator: (v) => (v == null || v.isEmpty) ? 'กรุณากรอกชื่อ' : null,
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('รายละเอียด'),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _inputDecoration('อธิบายรายละเอียดเพิ่มเติม'),
                      maxLines: 3,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'กรุณากรอกรายละเอียด' : null,
                    ),
                    const SizedBox(height: 16),
                    _fieldLabel('หมวดหมู่'),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: _inputDecoration(null),
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (value) => setState(() => _category = value ?? 'General'),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F5FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CheckboxListTile(
                        value: _isUrgent,
                        onChanged: (value) => setState(() => _isUrgent = value ?? false),
                        title: const Text(
                          'ทำเครื่องหมายเป็นเร่งด่วน',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                        ),
                        activeColor: _accent,
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C5CE7), Color(0xFF8E7CFB)],
                          ),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _submit,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_rounded, size: 18),
                          label: Text(_isSaving ? 'กำลังบันทึก...' : 'บันทึก / ส่งข้อมูล'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B894), Color(0xFF55D8B4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B894).withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.save_alt_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'บันทึก / ส่งข้อมูล',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'กรอกฟอร์มแล้วส่งข้อมูลไปยัง backend',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: Color(0xFF2D2D3A)),
      ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF6F5FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _accent, width: 1.6),
      ),
    );
  }
}
