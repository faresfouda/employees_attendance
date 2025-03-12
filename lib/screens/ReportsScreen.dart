import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/worker_model.dart';
import '../provider/WorkerProvider.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime? startDate;
  DateTime? endDate;
  String? exportedFilePath;

  @override
  void initState() {
    super.initState();
    DateTime today = DateTime.now();
    // القيمة المبدئية: من أسبوع قبل اليوم (7 أيام) حتى اليوم.
    // لضمان فترة 7 أيام، نحسب startDate كالتالي:
    startDate = today.subtract(Duration(days: 6));
    endDate = today;
  }

  // دالة لمساعدتك في تنسيق TimeOfDay إلى سلسلة HH:mm.
  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute;
    return '$hour:${minute.toString().padLeft(2, '0')}';
  }

  // دالة لمقارنة يومين إذا كانوا في نفس اليوم.
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> requestPermissions() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      print("Storage permission granted");
    } else {
      print("Storage permission denied");
    }
  }

  Future<void> _exportToExcel(BuildContext context) async {
    final workerProvider = Provider.of<WorkerProvider>(context, listen: false);
    List<Worker> workers = workerProvider.workers;

    var excel = Excel.createExcel();
    Sheet sheet = excel["Workers Report"];

    if (startDate == null || endDate == null) return;
    // حساب عدد الأيام بناءً على الفرق بين التاريخين.
    final duration = endDate!.difference(startDate!);
    final numberOfDays = duration.inDays + 1;

    // إعداد رؤوس الأعمدة مع التواريخ من startDate حتى endDate.
    List<TextCellValue> headerDates = [];
    for (int i = 0; i < numberOfDays; i++) {
      DateTime currentDate = startDate!.add(Duration(days: i));
      headerDates.add(TextCellValue(currentDate.toLocal().toString().split(' ')[0]));
    }

    sheet.appendRow([
      TextCellValue("الاسم"),
      TextCellValue("القسم"),
      TextCellValue("إجمالي الساعات"),
      TextCellValue("تكلفة الساعة"),
      TextCellValue("التكلفة الإجمالية"),
      ...headerDates,
    ]);

    // إضافة بيانات العمال.
    for (var worker in workers) {
      double totalMinutes = 0;
      // إنشاء قائمة لتخزين بيانات الحضور لكل يوم في الفترة.
      List<String> attendanceDays = List.filled(numberOfDays, "غير محدد");

      // المرور على كل يوم في الفترة.
      for (int i = 0; i < numberOfDays; i++) {
        DateTime currentDay = startDate!.add(Duration(days: i));
        // تصفية سجلات الحضور التي تتوافق مع اليوم الحالي.
        var recordsForDay = worker.attendanceRecords
            .where((record) => isSameDay(record.date, currentDay))
            .toList();

        // جمع الدقائق في اليوم الحالي.
        double dayMinutes = recordsForDay.fold(
            0.0, (sum, record) => sum + record.workDuration.inMinutes);
        totalMinutes += dayMinutes;

        // إذا كان في سجلات في اليوم الحالي، نجمعها.
        if (recordsForDay.isNotEmpty) {
          List<String> dayRecords = recordsForDay.map((attendance) {
            final checkInTimeFormatted = attendance.checkInTime != null
                ? formatTimeOfDay(attendance.checkInTime!)
                : 'غير محدد';
            final checkOutTimeFormatted = attendance.checkOutTime != null
                ? formatTimeOfDay(attendance.checkOutTime!)
                : 'غير محدد';
            return "حضور: $checkInTimeFormatted, انصراف: $checkOutTimeFormatted";
          }).toList();
          attendanceDays[i] = dayRecords.join(" | ");
        }
      }

      // حساب التكلفة بناءً على الدقائق.
      double totalCost = (totalMinutes / 60) * worker.hourCost;

      sheet.appendRow([
        TextCellValue(worker.name),
        TextCellValue(worker.department),
        TextCellValue((totalMinutes / 60).toStringAsFixed(2)),
        TextCellValue(worker.hourCost.toString()),
        TextCellValue(totalCost.toStringAsFixed(2)),
        ...attendanceDays.map((attendance) => TextCellValue(attendance)),
      ]);
    }

    // حفظ الملف.
    Future<void> saveFile() async {
      Directory? directory = await getExternalStorageDirectory();
      if (directory != null) {
        String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        String path = "${directory.path}/تقفيل_العمال_بتاريخ_$formattedDate.xlsx";
        File file = File(path);
        var bytes = excel.encode();
        await file.writeAsBytes(bytes!);
        setState(() {
          exportedFilePath = path;
        });
      }
    }

    await saveFile();

    // حذف السجلات التي تم اصدارها بالفعل ضمن الفترة المحددة
    // باستخدام الطريقة الأولى: إزالة كل سجل يكون تاريخه بين startDate و endDate (شاملة اليومين)
    for (var worker in workers) {
      worker.attendanceRecords.removeWhere((record) =>
      record.date.isAfter(startDate!.subtract(Duration(days: 1))) &&
          record.date.isBefore(endDate!.add(Duration(days: 1))));
    }
    workerProvider.notifyListeners();
  }

  void _shareFile() async {
    await _exportToExcel(context);
    if (exportedFilePath != null) {
      Share.shareFiles([exportedFilePath!],
          text: "Here is the Worker Report");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please export the report first!")),
      );
    }
  }

  // دالة لاختيار التاريخ باستخدام DatePicker.
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime initialDate = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = selectedDate;
        } else {
          endDate = selectedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("تصدير تقرير العمال")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text("تاريخ البداية"),
                subtitle: Text(startDate == null
                    ? "لم يتم التحديد"
                    : "${startDate!.toLocal()}".split(' ')[0]),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, true),
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4,
              child: ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text("تاريخ النهاية"),
                subtitle: Text(endDate == null
                    ? "لم يتم التحديد"
                    : "${endDate!.toLocal()}".split(' ')[0]),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, false),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text("مشاركة التقرير"),
                  onPressed: _shareFile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
