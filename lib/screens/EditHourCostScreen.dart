import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/worker_model.dart';
import '../provider/WorkerProvider.dart';

class EditHourCostScreen extends StatefulWidget {
  final Worker worker;

  const EditHourCostScreen({Key? key, required this.worker}) : super(key: key);

  @override
  _EditHourCostScreenState createState() => _EditHourCostScreenState();
}

class _EditHourCostScreenState extends State<EditHourCostScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.worker.hourCost.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveHourCost() {
    double? newCost = double.tryParse(_controller.text);
    if (newCost != null && newCost >= 0) {
      context.read<WorkerProvider>().updateWorkerHourCost(widget.worker, newCost);
      Navigator.pop(context, newCost); // إرجاع القيمة الجديدة عند الرجوع
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال رقم صالح')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تعديل سعر الساعة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('العامل: ${widget.worker.name}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'سعر الساعة الجديد',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveHourCost,
                child: Text('حفظ التعديل'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
