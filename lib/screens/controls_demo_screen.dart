import 'package:flutter/material.dart';

class ControlsDemoScreen extends StatefulWidget {
  const ControlsDemoScreen({super.key});

  @override
  State<ControlsDemoScreen> createState() => _ControlsDemoScreenState();
}

class _ControlsDemoScreenState extends State<ControlsDemoScreen> {
  final TextEditingController _controller = TextEditingController();
  String _lastSubmitted = '';

  static const _accent = Color(0xFF6C5CE7);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            const SizedBox(height: 22),
            _buildSection(
              icon: Icons.label_outline_rounded,
              color: const Color(0xFF00B894),
              title: 'Label (Text widget)',
              description:
                  'ใช้ Text() แสดงข้อความแบบ static บนหน้าจอ ปรับรูปแบบผ่าน '
                  'TextStyle เช่น ขนาดตัวอักษร สี ความหนา',
              child: const Text(
                'นี่คือตัวอย่าง Label',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D2D3A),
                ),
              ),
            ),
            _buildSection(
              icon: Icons.edit_note_rounded,
              color: const Color(0xFF0984E3),
              title: 'TextField',
              description:
                  'ใช้รับข้อความจากผู้ใช้ ต้องผูกกับ TextEditingController '
                  'เพื่ออ่านค่าที่พิมพ์ และมี InputDecoration ช่วยกำหนด label/border',
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'พิมพ์ข้อความที่นี่',
                  filled: true,
                  fillColor: const Color(0xFFF6F5FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _accent, width: 1.6),
                  ),
                ),
              ),
            ),
            _buildSection(
              icon: Icons.smart_button_rounded,
              color: _accent,
              title: 'Button (ElevatedButton)',
              description:
                  'ใช้ onPressed รับ callback เมื่อผู้ใช้กดปุ่ม สามารถใส่ icon '
                  'ผ่าน ElevatedButton.icon ได้',
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _lastSubmitted = _controller.text);
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('ยืนยัน'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            if (_lastSubmitted.isNotEmpty) _buildResultBanner(),
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
          colors: [Color(0xFF6C5CE7), Color(0xFF8E7CFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.28),
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
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.widgets_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UI Controls Demo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'ตัวอย่างการใช้งาน Label, TextField และ Button',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF00B894).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF00B894).withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF00B894), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'ค่าที่ส่ง: $_lastSubmitted',
              style: const TextStyle(
                color: Color(0xFF00795A),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// การ์ดสำหรับแต่ละหัวข้อ มีไอคอนสี + คำอธิบาย + ตัวอย่างจริง
  Widget _buildSection({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 19, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.5,
                  color: Color(0xFF2D2D3A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
