import 'package:arabic_font/arabic_font.dart';
import 'package:attendance/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'models/boxes.dart';
import 'models/time_of_day_adapter.dart';
import 'models/worker_model.dart';
import 'provider/WorkerProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  await Hive.initFlutter();
  Hive.registerAdapter(WorkerAdapter());
  Hive.registerAdapter(AttendanceRecordAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());
  boxWorkers = await Hive.openBox<Worker>('workers');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkerProvider()..loadWorkers()), // ✅ تحميل العمال عند بدء التطبيق
      ],
      child: MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حضور وانصراف الموظف',
      theme: ThemeData(
        fontFamily: ArabicThemeData.font(
            arabicFont: ArabicFont.dinNextLTArabic
        ),
        package: ArabicThemeData.package,
      ),
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: HomeScreen(),
      ),
    );
  }
}
