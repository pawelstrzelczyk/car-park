import 'package:flutter/material.dart';
import 'package:parking_info/pages/home_page.dart';
import 'package:parking_info/providers/entries_provider.dart';
import 'package:parking_info/providers/gas_provider.dart';
import 'package:parking_info/services/api.dart';
import 'package:provider/provider.dart';

void main() {
  ApiService apiService = ApiService.getInstance();
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<GasController>(
          create: (_) => GasController(apiService),
        ),
        ChangeNotifierProvider<EntriesController>(
          create: (_) => EntriesController(apiService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking Info',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
