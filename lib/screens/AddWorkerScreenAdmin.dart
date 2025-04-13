import 'package:attendance/models/boxes.dart';
import 'package:attendance/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/worker_model.dart';

class AddWorkerScreenAdmin extends StatefulWidget {
  @override
  _AddWorkerScreenAdminState createState() => _AddWorkerScreenAdminState();
}

class _AddWorkerScreenAdminState extends State<AddWorkerScreenAdmin> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController hourlyRateController = TextEditingController();
  String? selectedDepartment;

  final List<String> departments = ['صالة', 'مائدة', 'كاشير', 'مدير','حسابات'];

  void addWorker() {
    final String name = nameController.text.trim()??'a';
    final String department = selectedDepartment ?? 'صالة';
    final double? hourlyCost = double.tryParse(hourlyRateController.text.trim());

    if (name.isEmpty ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال الاسم بشكل صحيح')),
      );
      return;
    }

    final worker = Worker(name: name,department: department,hourCost: hourlyCost??0.0,);
    boxWorkers.put('key_${name}', worker);
    worker.save();


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تمت إضافة العامل بنجاح')),
    );
    nameController.clear();
    hourlyRateController.clear();
    setState(() {
      selectedDepartment = null;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>HomeScreen(userRole: 'admin',)),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة عامل جديد'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedDepartment,
                items: departments.map((String department) {
                  return DropdownMenuItem<String>(
                    value: department,
                    child: Text(department),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDepartment = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'القسم',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: hourlyRateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'سعر الساعة',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    addWorker();
                  },
                  child: Text(
                    'إضافة العامل',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}