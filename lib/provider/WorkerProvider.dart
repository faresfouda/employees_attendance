import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/worker_model.dart';

class WorkerProvider with ChangeNotifier {
  late Box<Worker> _workerBox;
  List<Worker> _workers = [];

  List<Worker> get workers => _workers;

  Future<void> loadWorkers() async {
    _workerBox = await Hive.openBox<Worker>('workers');
    _workers = _workerBox.values.toList();
    notifyListeners();
  }

  void addWorker(Worker worker) async {
    await _workerBox.add(worker);
    _workers.add(worker);
    notifyListeners();
  }

  void updateWorker(int index, Worker updatedWorker) async {
    await _workerBox.putAt(index, updatedWorker);
    _workers[index] = updatedWorker;
    notifyListeners();
  }

  void deleteWorker(int index) async {
    await _workerBox.deleteAt(index);
    _workers.removeAt(index);
    notifyListeners();
  }

  void updateWorkerHourCost(Worker worker, double newHourCost) async {
    int index = _workers.indexOf(worker);
    if (index != -1) {
      Worker updatedWorker = Worker(
        name: worker.name,
        department: worker.department,
        totalHours: worker.totalHours,
        hourCost: newHourCost, // تحديث سعر الساعة الجديد
        isRegistered: worker.isRegistered,
        attendanceRecords: worker.attendanceRecords,
      );

      await _workerBox.putAt(index, updatedWorker);
      _workers[index] = updatedWorker;
      notifyListeners();
    }
  }

}
