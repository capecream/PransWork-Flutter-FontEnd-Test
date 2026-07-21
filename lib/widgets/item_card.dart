import 'package:flutter/material.dart';
import '../models/item.dart';

/// การ์ดแสดงข้อมูล 1 รายการ แยกเป็น widget ต่างหาก
/// เพื่อให้นำกลับมาใช้ซ้ำได้ และทดสอบแยกจากหน้าจอหลักได้
/// (ตอบโจทย์ข้อ 1.3-f: แยก widget/component)
class ItemCard extends StatelessWidget {
  final Item item;
  final ValueChanged<bool?>? onCheckboxChanged;
  final VoidCallback? onTap;

  const ItemCard({
    super.key,
    required this.item,
    this.onCheckboxChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: item.isSelected,
          onChanged: onCheckboxChanged,
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${item.category} • ${item.description}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
