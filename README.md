# วิธีนำโค้ดชุดนี้ไปใช้ในโปรเจค Flutter ของคุณ

โค้ดชุดนี้ตอบโจทย์ข้อ 1.3 (b, d, e, f) สำหรับฝั่ง Flutter frontend โดยยังไม่ได้ติดตั้ง
package เพิ่มเติมนอกเหนือจาก `http` ซึ่งเป็น package มาตรฐานที่จำเป็นสำหรับเรียก REST API

## 1) คัดลอกไฟล์
คัดลอกโฟลเดอร์ `lib/` และ `test/` ทั้งหมดในนี้ ไปทับ/รวมกับโฟลเดอร์
`FlutterTestParnsWork/frontend/` ของคุณ (ถ้ามีไฟล์ `main.dart` เดิมอยู่แล้ว ให้ backup ไว้ก่อน)

## 2) เพิ่ม dependency `http` ใน pubspec.yaml
เปิดไฟล์ `pubspec.yaml` แล้วเพิ่มบรรทัดนี้ในส่วน `dependencies:`

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
```

จากนั้นรัน:

```
flutter pub get
```

## 3) ตรวจสอบชื่อ package ในไฟล์ test
ไฟล์ทดสอบ (`test/item_model_test.dart`, `test/item_card_widget_test.dart`)
import ด้วยชื่อ package `frontend` เช่น `import 'package:frontend/models/item.dart';`
ถ้าชื่อ `name:` ใน `pubspec.yaml` ของคุณไม่ใช่ `frontend` ให้แก้ import ตรงนี้ให้ตรงกัน

## 4) ตั้งค่า URL ของ backend
แก้ค่า `baseUrl` ในไฟล์ `lib/config/app_config.dart` ให้ตรงกับ URL จริงของ backend .NET Core
(ดูได้จากไฟล์ `Properties/launchSettings.json` ของ backend หรือหน้า Swagger ตอนรัน)

## 5) รันแอปและทดสอบ

```
flutter run
```

รัน unit test / widget test ด้วย:

```
flutter test
```

## โครงสร้างไฟล์และหน้าที่

| ไฟล์ | หน้าที่ |
|---|---|
| `lib/main.dart` | จุดเริ่มแอป + bottom navigation สลับ 3 หน้าจอ |
| `lib/config/app_config.dart` | ค่า config เช่น base URL ของ API |
| `lib/models/item.dart` | โครงสร้างข้อมูลที่รับส่งกับ API |
| `lib/services/api_service.dart` | ฟังก์ชันเรียก API (fetchItems, saveItem) |
| `lib/widgets/item_card.dart` | การ์ดแสดงข้อมูล 1 รายการ (reusable) |
| `lib/widgets/status_widgets.dart` | Widget แสดง loading/error (reusable) |
| `lib/screens/controls_demo_screen.dart` | หน้าจอ 1 — ตัวอย่าง Label, TextField, Button |
| `lib/screens/data_list_screen.dart` | หน้าจอ 2 — Card/Table, Dropdown, Checkbox, Modal |
| `lib/screens/save_data_screen.dart` | หน้าจอ 3 — ฟอร์มบันทึก/ส่งข้อมูล |
| `test/item_model_test.dart` | Unit test ของ Item model |
| `test/item_card_widget_test.dart` | Widget test ของ ItemCard |

## หมายเหตุเรื่อง backend
`lib/services/api_service.dart` คาดหวัง endpoint แบบนี้จาก backend .NET Core:

- `GET  {baseUrl}/items` → คืนค่า array ของ object `{ id, name, description, category }`
- `POST {baseUrl}/items` → รับ body `{ name, description, category }` คืนค่า object ที่บันทึกแล้ว

ถ้า endpoint จริงของคุณต่างจากนี้ ให้แก้ path หรือ field name ใน `api_service.dart`
และ `models/item.dart` ให้ตรงกัน
