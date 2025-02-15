import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/WorkersDetails.dart';


class WorkerCard extends StatelessWidget {
  final String name, department;
  final bool status;
  final VoidCallback onpressed;

  WorkerCard({required this.name, required this.department, required this.status,required this.onpressed});


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onpressed,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(CupertinoIcons.profile_circled),
          title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('القسم: #$department'),
          trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: status == 'نشط' ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status?'نشط':'غير نشط',
              style: TextStyle(
                color: status == true ? Colors.green[800] : Colors.red[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
