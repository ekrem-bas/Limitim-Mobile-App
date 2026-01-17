import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:limitim/models/expense.dart';
import 'package:limitim/models/month.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(MonthAdapter());
  Hive.registerAdapter(ExpenseAdapter());

  await Hive.openBox<Month>("months");
  await Hive.openBox<Expense>("expenses");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const Scaffold());
  }
}
