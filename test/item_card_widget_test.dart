import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/widgets/item_card.dart';

void main() {
  testWidgets('ItemCard แสดงชื่อและรายละเอียดถูกต้อง', (tester) async {
    final item = Item(
      id: '1',
      name: 'ตัวอย่าง',
      description: 'รายละเอียดทดสอบ',
      category: 'General',
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ItemCard(item: item))),
    );

    expect(find.text('ตัวอย่าง'), findsOneWidget);
    expect(find.textContaining('รายละเอียดทดสอบ'), findsOneWidget);
  });

  testWidgets('การกด Checkbox เรียก callback พร้อมค่าที่ถูกต้อง', (tester) async {
    final item = Item(id: '1', name: 'A', description: 'B', category: 'C');
    bool? tappedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemCard(
            item: item,
            onCheckboxChanged: (value) => tappedValue = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    expect(tappedValue, true);
  });

  testWidgets('การแตะที่การ์ดเรียก onTap', (tester) async {
    final item = Item(id: '1', name: 'A', description: 'B', category: 'C');
    var wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ItemCard(item: item, onTap: () => wasTapped = true),
        ),
      ),
    );

    await tester.tap(find.byType(ListTile));
    await tester.pump();

    expect(wasTapped, true);
  });
}
