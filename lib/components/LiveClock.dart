import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LiveClock extends StatefulWidget {
  @override
  _LiveClockState createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  String _time = '';

  @override
  void initState() {
    super.initState();
    _updateTime(); // تحديث الوقت أول مرة
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateTime();
      } else {
        timer.cancel(); // إيقاف التايمر إذا لم تعد الصفحة موجودة
      }
    });
  }

  void _updateTime() {
    setState(() {
      _time = DateFormat('hh:mm:ss a', 'ar').format(DateTime.now()); // تنسيق الوقت
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'الوقت: $_time',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}
