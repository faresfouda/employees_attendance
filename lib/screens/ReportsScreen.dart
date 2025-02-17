import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../provider/WorkerProvider.dart';
import '../models/worker_model.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime endDate = DateTime.now();

  // دالة لحساب أيام الحضور لكل عامل بناءً على الفترة المحددة
  Map<String, int> _calculateAttendance(List<Worker> workers) {
    Map<String, int> attendanceCount = {};

    for (var worker in workers) {
      for (var record in worker.attendanceRecords) {
        if (record.date.isAfter(startDate.subtract(Duration(days: 1))) &&
            record.date.isBefore(endDate.add(Duration(days: 1)))) {
          attendanceCount[worker.name] = (attendanceCount[worker.name] ?? 0) + 1;
        }
      }
    }

    return attendanceCount;
  }

  // دالة تصدير البيانات إلى Excel
  Future<void> _exportToExcel(List<Worker> workers) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['التقرير'];

    // إضافة عنوان الجدول
    sheet.appendRow([TextCellValue('اسم العامل'), TextCellValue('عدد أيام الحضور')]);

    // إضافة بيانات التقرير
    _calculateAttendance(workers).forEach((worker, daysPresent) {
      sheet.appendRow([TextCellValue(worker), TextCellValue(daysPresent.toString())]);
    });

    // حفظ الملف في التخزين
    Directory? directory = await getExternalStorageDirectory();
    String filePath = '${directory?.path}/Attendance_Report.xlsx';

    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('📁 تم حفظ التقرير في: $filePath')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();
    Map<String, int> attendanceCount = _calculateAttendance(workerProvider.workers);

    return Scaffold(
      appBar: AppBar(title: Text('📊 التقارير')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // اختيار التاريخ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDatePicker('📅 من', startDate, () => _selectDate(context, true)),
                _buildDatePicker('📅 إلى', endDate, () => _selectDate(context, false)),
              ],
            ),
            SizedBox(height: 16),

            // أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _exportToExcel(workerProvider.workers),
                    child: Text('📄 تصدير إلى Excel'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // قائمة التقارير
            Expanded(
              child: attendanceCount.isEmpty
                  ? Center(child: Text('❌ لا يوجد حضور في هذه الفترة'))
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
