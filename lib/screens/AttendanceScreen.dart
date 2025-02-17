import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../provider/WorkerProvider.dart';
import '../models/worker_model.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime selectedDate = DateTime.now();

  // دالة لاختيار التاريخ
  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();

    // تحويل التاريخ إلى الصيغة المطلوبة (yyyy-MM-dd)
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    // استخراج العمال الذين لديهم حضور في التاريخ المحدد
    List<Worker> presentWorkers = workerProvider.workers.where((worker) {
      return worker.attendanceRecords.any((record) =>
      DateFormat('yyyy-MM-dd').format(record.date) == formattedDate);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('سجل الحضور')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // زر اختيار التاريخ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التاريخ: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.blue),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            SizedBox(height: 16),

            // عرض قائمة العمال الحاضرين
            Expanded(
              child: presentWorkers.isEmpty
                  ? Center(child: Text('لا يوجد عمال مسجلين في هذا اليوم'))
                  : ListView.builder(
                itemCount: presentWorkers.length,
                itemBuilder: (context, index) {
                  Worker worker = presentWorkers[index];

                  // استخراج سجل الحضور لهذا اليوم
                  AttendanceRecord? attendanceRecord = worker.attendanceRecords.firstWhere(
                        (record) => DateFormat('yyyy-MM-dd').format(record.date) == formattedDate,
                    orElse: () => AttendanceRecord(date: selectedDate),
                  );

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, color: Colors.blue),
                      ),
                      title: Text(worker.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('القسم: ${worker.department}'),
                          Text(
                            'وقت الدخول: ${attendanceRecord.checkInTime != null ? attendanceRecord.checkInTime!.format(context) : "غير مسجل"}',
                          ),
                          Text(
                            'وقت الخروج: ${attendanceRecord.checkOutTime != null ? attendanceRecord.checkOutTime!.format(context) : "غير مسجل"}',
                          ),
                          Text(
                            'مدة العمل: ${attendanceRecord.workDuration.inHours} ساعات ${attendanceRecord.workDuration.inMinutes % 60} دقائق',
                          ),
                        ],
                      ),
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
}
