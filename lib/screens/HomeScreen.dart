import 'package:attendance/models/boxes.dart';
import 'package:attendance/screens/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'AddWorkerScreen.dart';
import 'AttendanceScreen.dart';
import 'ReportsScreen.dart';

class HomeScreen extends StatefulWidget {
  final String userRole; // قيمة الدور: "user" أو "admin"

  const HomeScreen({Key? key, required this.userRole}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    // إذا كان الدور admin يعرض جميع الشاشات، وإذا كان user يعرض أول شاشتين فقط
    if (widget.userRole == 'admin') {
      _pages = [
        DashboardScreen(),
        AddWorkerScreen(),
        AttendanceScreen(),
        ReportScreen(),
      ];
      _navItems = [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_add),
          label: 'إضافة عامل',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time),
          label: 'الحضور',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'التقارير',
        ),
      ];
    } else {
      _pages = [
        DashboardScreen(),
        AddWorkerScreen(),
      ];
      _navItems = [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_add),
          label: 'إضافة عامل',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: _navItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
