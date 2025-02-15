import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../components/LiveClock.dart';
import '../models/worker_model.dart';

class WorkerScreen extends StatefulWidget {
  final Worker worker;

  const WorkerScreen({required this.worker, Key? key}) : super(key: key);

  @override
  _WorkerScreenState createState() => _WorkerScreenState();
}

class _WorkerScreenState extends State<WorkerScreen> {
  TimeOfDay? checkInTime;
  TimeOfDay? checkOutTime;


  String _getFormattedDate() {
    DateTime now = DateTime.now();
    String dayName = DateFormat('EEEE', 'ar').format(now);
    String formattedDate = DateFormat('d MMMM yyyy', 'ar').format(now);
    return '$dayName، $formattedDate';
  }


  Future<void> _selectTime(BuildContext context, bool isCheckIn) async {
    TimeOfDay initialTime = TimeOfDay.now();

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        DateTime today = DateTime.now();

        // البحث عن آخر سجل بدون تسجيل خروج حتى لو كان في يوم سابق
        AttendanceRecord? lastRecord = widget.worker.attendanceRecords.lastWhere(
              (record) => record.checkOutTime == null,
          orElse: () => AttendanceRecord(date: today, checkInTime: pickedTime),
        );

        if (isCheckIn) {
          // إذا لم يكن هناك سجل غير مكتمل، يتم إنشاء سجل جديد
          if (lastRecord.checkOutTime != null) {
            lastRecord = AttendanceRecord(date: today, checkInTime: pickedTime);
            widget.worker.attendanceRecords.add(lastRecord);
          } else {
            lastRecord.checkInTime = pickedTime; // تحديث وقت الدخول
          }
        } else {
          lastRecord.checkOutTime = pickedTime; // تحديث وقت الخروج
        }

        widget.worker.updateTotalHours(); // ✅ تحديث إجمالي الساعات
        widget.worker.save(); // ✅ حفظ البيانات في Hive
      });
    }
  }


  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('تسجيل الحضور'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الوقت والتاريخ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'اليوم: ${_getFormattedDate()}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                LiveClock(),
              ],
            ),
            SizedBox(height: 16),

            // بطاقة الموظف
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(CupertinoIcons.profile_circled),
                    SizedBox(height: 10),
                    Text(
                      '${widget.worker.name}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${widget.worker.department}',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 16),

                    // وقت الدخول والخروج
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text('وقت الدخول', style: TextStyle(color: Colors.grey)),
                            Text(checkInTime != null
                                ? checkInTime!.format(context)
                                : '--:--'),
                          ],
                        ),
                        Column(
                          children: [
                            Text('وقت الخروج', style: TextStyle(color: Colors.grey)),
                            Text(checkOutTime != null
                                ? checkOutTime!.format(context)
                                : '--:--'),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.worker.attendanceRecords.any((record) =>
                            isSameDay(record.date, DateTime.now()) &&
                                record.checkOutTime == null)
                                ? null // تعطيل الزر في حالة عدم تسجيل انصراف
                                : () => _selectTime(context, true), // تسجيل الحضور
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              ' تسجيل حضور',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),

                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _selectTime(context, false), // تسجيل الانصراف
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              ' تسجيل انصراف',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // سجل الحضور
            Text(
              '📜 سجل الحضور',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: widget.worker.attendanceRecords.length,
                itemBuilder: (context, index) {
                  final record = widget.worker.attendanceRecords[index];

                  return Dismissible(
                    key: Key(record.date.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        widget.worker.attendanceRecords.removeAt(index);
                        widget.worker.updateTotalHours();
                        widget.worker.save();
                      });
                    },
                    child: _buildAttendanceRecord(
                      record.checkInTime.format(context),
                      record.checkOutTime?.format(context) ?? '--:--',
                      record.workDuration.inHours,
                      DateFormat('d MMMM yyyy', 'ar').format(record.date),
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

  Widget _buildAttendanceRecord(String checkIn, String checkOut, int hours, String date) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(Icons.access_time, color: Colors.blue),
        title: Text('يوم $date', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('دخول: $checkIn - خروج: $checkOut'),
        trailing: Text('$hours ساعات', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
      ),
    );
  }

}
