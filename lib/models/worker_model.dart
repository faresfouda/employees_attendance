import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'worker_model.g.dart';

@HiveType(typeId: 0)
class Worker extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  double totalHours;

  @HiveField(2)
  double hourCost;

  @HiveField(3)
  String department;

  @HiveField(4)
  bool isRegistered;

  @HiveField(5)
  List<AttendanceRecord> attendanceRecords; // ✅ سجل الحضور اليومي

  Worker({
    required this.name,
    required this.department,
    this.totalHours = 0.0,
    this.hourCost = 0.0,
    this.isRegistered = false,
    List<AttendanceRecord>? attendanceRecords,
  }) : attendanceRecords = attendanceRecords ?? [];



}

@HiveType(typeId: 1)
class AttendanceRecord {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  TimeOfDay? checkInTime;

  @HiveField(2)
  TimeOfDay? checkOutTime;

  AttendanceRecord({
    required this.date,
    this.checkInTime,
    this.checkOutTime,
  });


  Duration get workDuration {
    if (checkInTime == null || checkOutTime == null) return Duration.zero;

    DateTime checkIn = DateTime(date.year, date.month, date.day, checkInTime!.hour, checkInTime!.minute);
    DateTime checkOut = DateTime(date.year, date.month, date.day, checkOutTime!.hour, checkOutTime!.minute);


    if (checkOut.isBefore(checkIn)) {
      checkOut = checkOut.add(Duration(days: 1));
    }

    return checkOut.difference(checkIn);
  }

}
