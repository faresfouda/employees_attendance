import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../components/workercard.dart';
import '../models/worker_model.dart';
import 'WorkersDetails.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Box<Worker> workerBox;
  List<Worker> workers = [];
  List<Worker> filteredWorkers = [];
  TextEditingController searchController = TextEditingController();
  String selectedDepartment = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadWorkers();
    searchController.addListener(_filterWorkers);
  }

  void _filterWorkers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredWorkers = workers.where((worker) {
        bool matchesSearch = worker.name.toLowerCase().contains(query);
        bool matchesDepartment =
            selectedDepartment == 'الكل' || worker.department == selectedDepartment;
        return matchesSearch && matchesDepartment;
      }).toList();
    });
  }

  void _loadWorkers() async {
    workerBox = await Hive.openBox<Worker>('workers');
    setState(() {
      workers = workerBox.values.toList();
      filteredWorkers = List.from(workers);
    });
  }
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<bool?> _confirmDeleteWorker(int index) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text.rich(
          TextSpan(
            text: 'هل أنت متأكد من حذف العامل ',
            children: [
              TextSpan(
                text: workers[index].name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: '؟ لا يمكن التراجع عن هذا الإجراء.'),
            ],
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Return false
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Return true
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteWorker(int index) async {
    await workerBox.deleteAt(index);
    setState(() {
      workers.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حذف العامل بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        _filterWorkers();
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
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      bool? shouldDelete = await _confirmDeleteWorker(index);
                      if (shouldDelete == true) {
                        _deleteWorker(index);
                      }
                      return shouldDelete;
                    },
                    child: WorkerCard(
                      name: worker.name,
                      department: worker.department,
                      status: worker.isRegistered,
                      onpressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkerScreen(
                                worker: worker
                            ),
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
