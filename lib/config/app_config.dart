/// เก็บค่า config ของแอป เช่น URL ของ backend API
/// ถ้าต้องเปลี่ยน environment (dev/staging/prod) ให้แก้ค่าตรงนี้ที่เดียว
/// (ตอบโจทย์ข้อ 1.3-c: setup configuration ใน app settings)
class AppConfig {
  // TODO: เปลี่ยนเป็น URL จริงของ backend .NET Core (ดูจาก launchSettings.json ของ backend)
  //
  // หมายเหตุการเชื่อมต่อจากอุปกรณ์ต่างๆ:
  // - Android Emulator  -> ใช้ 10.0.2.2 แทน localhost เช่น https://10.0.2.2:5001/api
  // - iOS Simulator      -> ใช้ localhost ได้ปกติ
  // - Web / Windows Desktop -> ใช้ localhost ได้ปกติ
  // - อุปกรณ์จริงในวง LAN เดียวกัน -> ใช้ IP เครื่อง เช่น https://192.168.1.10:5001/api
  static const String baseUrl = 'https://localhost:5001/api';

  static const Duration requestTimeout = Duration(seconds: 15);
}
