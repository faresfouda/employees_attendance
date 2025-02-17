import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../components/LiveClock.dart';
import '../models/worker_model.dart';
import '../provider/WorkerProvider.dart';

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
    TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: initialTime);

    if (pickedTime != null) {
      setState(() {
        final workerProvider = context.read<WorkerProvider>();
        DateTime today = DateTime.now();

        if (isCheckIn) {
          AttendanceRecord newRecord = AttendanceRecord(
            date: today,
            checkInTime: pickedTime,
          );
          widget.worker.isRegistered = true;
          widget.worker.attendanceRecords.add(newRecord);
          checkInTime = pickedTime;
        } else {
          AttendanceRecord? lastCheckInRecord = widget.worker.attendanceRecords.lastWhere(
                (record) => record.checkOutTime == null,
            orElse: () => AttendanceRecord(date: today, checkInTime: pickedTime),
          );

          if (lastCheckInRecord.date.isBefore(today) || lastCheckInRecord.date.isAtSameMomentAs(today)) {
            lastCheckInRecord.checkOutTime = pickedTime;
            widget.worker.isRegistered = false;
            checkOutTime = pickedTime;
          } else {
            AttendanceRecord newCheckoutRecord = AttendanceRecord(
              date: today,
              checkOutTime: pickedTime,
            );
            widget.worker.isRegistered = false;
            widget.worker.attendanceRecords.add(newCheckoutRecord);
            checkOutTime = pickedTime;
          }
        }

        widget.worker.updateTotalHours();
        workerProvider.updateWorker(workerProvider.workers.indexOf(widget.worker), widget.worker);
      });
    }
  }


  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("تأكيد الحذف"),
          content: Text("هل أنت متأكد أنك تريد حذف هذا السجل؟ لا يمكن التراجع عن هذا الإجراء."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // إرجاع false عند الإلغاء
              },
              child: Text("إلغاء"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // إرجاع true عند التأكيد

              },
              child: Text("حذف", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ) ?? false; // في حالة إغلاق النافذة بدون اختيار
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
                            onPressed: () => _selectTime(context, true), // تسجيل الدخول
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
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      bool confirm = await _showDeleteConfirmationDialog(context);
                      if (confirm) {
                        setState(() {
                          widget.worker.attendanceRecords.removeAt(index);
                        });
                        widget.worker.save();
                      }
                      return confirm;
                    },



                    child: _buildAttendanceRecord(
                      record.checkInTime?.format(context) ?? '--:--',
                      record.checkOutTime?.format(context) ?? '--:--',
                      record.workDuration.inMinutes,
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

  Widget _buildAttendanceRecord(String checkIn, String checkOut,int minuts, String date) {
    int hours = minuts ~/ 60; // عدد الساعات
    int minutes_res = minuts % 60; // الدقائق المتبقية

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(Icons.access_time, color: Colors.blue),
        title: Text('يوم $date', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('دخول: $checkIn - خروج: $checkOut'),
        trailing:Text(
        '${hours} ساعات\n${minutes_res} دقيقة',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        textAlign: TextAlign.right,
      ),
    ),
    );
  }

}