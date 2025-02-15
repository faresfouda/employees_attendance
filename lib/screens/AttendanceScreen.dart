import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime selectedDate = DateTime.now();

  // بيانات العمال الحاضرين (محاكاة)
  final Map<String, List<String>> attendanceData = {
    '2025-02-14': ['أحمد علي', 'محمد حسن', 'سعيد محمود'],
    '2025-02-13': ['كريم ياسر', 'مصطفى فهمي'],
    '2025-02-12': ['علي إبراهيم', 'يوسف سامي', 'خالد عماد'],
  };

  // دالة لتحديث التاريخ
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
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    List<String> workers = attendanceData[formattedDate] ?? [];

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

            // قائمة العمال الحاضرين
            Expanded(
              child: workers.isEmpty
                  ? Center(child: Text('لا يوجد عمال مسجلين في هذا اليوم'))
                  : ListView.builder(
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, color: Colors.blue),
                      ),
                      title: Text(workers[index]),
                      subtitle: Text('حضر في $formattedDate'),
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
