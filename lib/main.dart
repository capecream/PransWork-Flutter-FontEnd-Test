import 'package:flutter/material.dart';
import 'screens/controls_demo_screen.dart';
import 'screens/data_list_screen.dart';
import 'screens/save_data_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test Parns Work',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MainNavigation(),
    );
  }
}

/// หน้าหลักที่คุมการสลับไปมาระหว่าง 3 หน้าจอตามโจทย์:
/// 1) UI Controls Demo  2) Data List (API)  3) Save Data
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ControlsDemoScreen(),
    DataListScreen(),
    SaveDataScreen(),
  ];

  final List<String> _titles = const [
    'UI Controls Demo',
    'Data List (API)',
    'Save Data',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.widgets), label: 'Controls'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Data'),
          BottomNavigationBarItem(icon: Icon(Icons.save), label: 'Save'),
        ],
      ),
    );
  }
}
