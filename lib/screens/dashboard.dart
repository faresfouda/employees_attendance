import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/workercard.dart';
import '../models/worker_model.dart';
import '../provider/WorkerProvider.dart';
import 'WorkersDetails.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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

  Future<bool?> _confirmDeleteWorker(Worker worker) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text.rich(
          TextSpan(
            text: 'هل أنت متأكد من حذف العامل ',
            children: [
              TextSpan(
                text: worker.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: '؟ لا يمكن التراجع عن هذا الإجراء.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteWorker(Worker worker) async {
    final workerProvider = context.read<WorkerProvider>();
    int index = workerProvider.workers.indexOf(worker);

    if (index != -1) {
      workerProvider.deleteWorker(index);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف العامل بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workerProvider = context.watch<WorkerProvider>();
    List<Worker> workers = workerProvider.workers;

    // Filter workers dynamically
    List<Worker> filteredWorkers = workers.where((worker) {
      bool matchesSearch = worker.name.toLowerCase().contains(searchController.text.toLowerCase());
      bool matchesDepartment = selectedDepartment == 'الكل' || worker.department == selectedDepartment;
      return matchesSearch && matchesDepartment;
    }).toList();

// فرز النشطين أولًا
    filteredWorkers.sort((a, b) => b.isRegistered ? 1 : -1);


    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('لوحة تحكم العمال', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن اسم العامل...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedDepartment,
                  icon: Icon(Icons.filter_list, color: Colors.blue),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedDepartment = newValue;
                      });
                    }
                  },
                  items: ['الكل', ...workers.map((e) => e.department).toSet()]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 30),
                itemCount: filteredWorkers.length,
                itemBuilder: (context, index) {
                  final worker = filteredWorkers[index];

                  return Dismissible(
                    key: Key(worker.name),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      bool? shouldDelete = await _confirmDeleteWorker(worker);
                      if (shouldDelete == true) {
                        _deleteWorker(worker);
                      }
                      return shouldDelete;
                    },
                    child: WorkerCard(
                      name: worker.name,
                      department: worker.department,
                      status: worker.isRegistered,
                      onpressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkerScreen(worker: worker),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
