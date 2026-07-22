import 'package:flutter/material.dart';
import '../models/item.dart';

/// สีและไอคอนประจำแต่ละหมวดหมู่ ใช้ร่วมกันทั้งแอปเพื่อความสม่ำเสมอ
class CategoryStyle {
  static Color colorOf(String category) {
    switch (category) {
      case 'Urgent':
        return const Color(0xFFE74C3C);
      case 'Follow-up':
        return const Color(0xFFF39C12);
      default:
        return const Color(0xFF6C5CE7);
    }
  }

  static IconData iconOf(String category) {
    switch (category) {
      case 'Urgent':
        return Icons.priority_high_rounded;
      case 'Follow-up':
        return Icons.schedule_rounded;
      default:
        return Icons.label_important_rounded;
    }
  }
}

/// การ์ดแสดงข้อมูล 1 รายการ มี avatar สีตามหมวดหมู่ + chip + shadow นุ่มๆ
/// พร้อมปุ่มแก้ไข (ปากกา) และปุ่มลบ ต่อรายการ
class ItemCard extends StatelessWidget {
  final Item item;
  final ValueChanged<bool?>? onCheckboxChanged;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ItemCard({
    super.key,
    required this.item,
    this.onCheckboxChanged,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accent = CategoryStyle.colorOf(item.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(CategoryStyle.iconOf(item.category), color: accent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5,
                                color: Color(0xFF2D2D3A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Checkbox(
                            value: item.isSelected,
                            onChanged: onCheckboxChanged,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.category,
                              style: TextStyle(
                                color: accent,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (onEdit != null)
                            _iconButton(
                              icon: Icons.edit_rounded,
                              color: const Color(0xFF0984E3),
                              onTap: onEdit!,
                            ),
                          if (onDelete != null) ...[
                            const SizedBox(width: 6),
                            _iconButton(
                              icon: Icons.delete_outline_rounded,
                              color: const Color(0xFFE74C3C),
                              onTap: onDelete!,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
