import 'package:flutter/material.dart';

/// หน้าจอที่ 1: แสดงตัวอย่างการใช้งาน UI control พื้นฐาน
/// (Label, TextField, Button) พร้อมคำอธิบายวิธีใช้แต่ละตัว
/// (ตอบโจทย์ข้อ 1.3-b)
class ControlsDemoScreen extends StatefulWidget {
  const ControlsDemoScreen({super.key});

  @override
  State<ControlsDemoScreen> createState() => _ControlsDemoScreenState();
}

class _ControlsDemoScreenState extends State<ControlsDemoScreen> {
  final TextEditingController _controller = TextEditingController();
  String _lastSubmitted = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: '1) Label (Text widget)',
            description:
                'ใช้ Text() แสดงข้อความแบบ static บนหน้าจอ ปรับรูปแบบผ่าน TextStyle '
                'เช่น ขนาดตัวอักษร สี ความหนา',
            child: const Text(
              'นี่คือตัวอย่าง Label',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          _buildSection(
            title: '2) TextField',
            description:
                'ใช้รับข้อความจากผู้ใช้ ต้องผูกกับ TextEditingController '
                'เพื่ออ่านค่าที่ผู้ใช้พิมพ์ และมี InputDecoration ช่วยกำหนด label/border',
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'พิมพ์ข้อความที่นี่',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          _buildSection(
            title: '3) Button (ElevatedButton)',
            description:
                'ใช้ onPressed รับ callback เมื่อผู้ใช้กดปุ่ม สามารถใส่ icon '
                'ผ่าน ElevatedButton.icon ได้',
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _lastSubmitted = _controller.text);
              },
              icon: const Icon(Icons.send),
              label: const Text('ยืนยัน'),
            ),
          ),
          if (_lastSubmitted.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'ค่าที่ส่ง: $_lastSubmitted',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  /// helper สำหรับสร้างกล่องอธิบาย + ตัวอย่าง control แต่ละอัน
  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
