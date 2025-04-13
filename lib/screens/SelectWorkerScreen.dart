import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/worker_model.dart';
import '../provider/WorkerProvider.dart';
import 'EditHourCostScreen.dart';

class SelectWorkerScreen extends StatefulWidget {
  @override
  _SelectWorkerScreenState createState() => _SelectWorkerScreenState();
}

class _SelectWorkerScreenState extends State<SelectWorkerScreen> {
  TextEditingController searchController = TextEditingController();
  String selectedDepartment = 'الكل';

  @override
  void initState() {
    super.initState();
    searchController.addListener(() => setState(() {}));
    Future.microtask(() => context.read<WorkerProvider>().loadWorkers());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();
    List<Worker> workers = workerProvider.workers;

    // تصفية العمال بناءً على البحث والقسم المختار
    List<Worker> filteredWorkers = workers.where((worker) {
      bool matchesSearch = worker.name.toLowerCase().contains(searchController.text.toLowerCase());
      bool matchesDepartment = selectedDepartment == 'الكل' || worker.department == selectedDepartment;
      return matchesSearch && matchesDepartment;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('اختر عاملًا لتعديل سعر الساعة')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'ابحث عن عامل...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: filteredWorkers.length,
              itemBuilder: (context, index) {
                final worker = filteredWorkers[index];

                return Card(
                  child: ListTile(
                    title: Text(worker.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('القسم: ${worker.department} | سعر الساعة: ${worker.hourCost}'),
                    trailing: Icon(Icons.edit, color: Colors.blue),
                    onTap: () async {
                      final updatedCost = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditHourCostScreen(worker: worker),
                        ),
                      );

                      if (updatedCost != null) {
                        setState(() {}); // تحديث الشاشة بعد تعديل السعر
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
