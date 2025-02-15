import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime endDate = DateTime.now();

  // بيانات الحضور (محاكاة)
  Map<String, List<String>> attendanceData = {
    '2025-02-14': ['أحمد علي', 'محمد حسن', 'سعيد محمود'],
    '2025-02-13': ['كريم ياسر', 'مصطفى فهمي'],
    '2025-02-12': ['أحمد علي', 'يوسف سامي', 'خالد عماد'],
    '2025-02-11': ['سعيد محمود', 'محمد حسن'],
    '2025-02-10': ['أحمد علي', 'كريم ياسر'],
  };

  // تصفية بيانات الحضور بناءً على النطاق الزمني المحدد
  Map<String, int> _calculateAttendance() {
    Map<String, int> attendanceCount = {};

    attendanceData.forEach((date, workers) {
      DateTime currentDate = DateTime.parse(date);
      if (currentDate.isAfter(startDate.subtract(Duration(days: 1))) &&
          currentDate.isBefore(endDate.add(Duration(days: 1)))) {
        for (String worker in workers) {
          attendanceCount[worker] = (attendanceCount[worker] ?? 0) + 1;
        }
      }
    });

    return attendanceCount;
  }

  // دالة تصدير البيانات إلى Excel
  Future<void> _exportToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['التقرير'];

    // إضافة عنوان الجدول
    // sheet.appendRow(['اسم العامل', 'عدد أيام الحضور']);

    // إضافة بيانات التقرير
    // _calculateAttendance().forEach((worker, daysPresent) {
    //   sheet.appendRow([worker, daysPresent.toString()]);
    // });

    // حفظ الملف في التخزين
    Directory? directory = await getExternalStorageDirectory();
    String filePath = '${directory?.path}/Attendance_Report.xlsx';

    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ التقرير في: $filePath')),
    );
  }

  // دالة لحذف بيانات الحضور للفترة المحددة
  void _clearAttendance() {
    attendanceData.removeWhere((date, _) {
      DateTime currentDate = DateTime.parse(date);
      return currentDate.isAfter(startDate.subtract(Duration(days: 1))) &&
          currentDate.isBefore(endDate.add(Duration(days: 1)));
    });

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم مسح بيانات الحضور للفترة المحددة')),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, int> attendanceCount = _calculateAttendance();

    return Scaffold(
      appBar: AppBar(title: Text('التقارير')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // اختيار التاريخ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDatePicker('من', startDate, () => _selectDate(context, true)),
                _buildDatePicker('إلى', endDate, () => _selectDate(context, false)),
              ],
            ),
            SizedBox(height: 16),

            // أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exportToExcel,
                    child: Text('📄 تصدير إلى Excel'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearAttendance,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('🗑️ مسح بيانات الحضور'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // قائمة التقارير
            Expanded(
              child: attendanceCount.isEmpty
                  ? Center(child: Text('لا يوجد حضور في هذه الفترة'))
                  : ListView.builder(
                itemCount: attendanceCount.length,
                itemBuilder: (context, index) {
                  String worker = attendanceCount.keys.elementAt(index);
                  int daysPresent = attendanceCount[worker]!;
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: Icon(Icons.person, color: Colors.green),
                      ),
                      title: Text(worker),
                      subtitle: Text('حضر $daysPresent يومًا في الفترة المحددة'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت اختيار التاريخ
  Widget _buildDatePicker(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            '$label: ${DateFormat('dd/MM/yyyy').format(date)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // دالة اختيار التاريخ
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = isStart ? startDate : endDate;

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (startDate.isAfter(endDate)) {
            endDate = startDate;
          }
        } else {
          endDate = picked;
          if (endDate.isBefore(startDate)) {
            startDate = endDate;
          }
        }
      });
    }
  }
}
