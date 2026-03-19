import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wlwgoscbixzyhxkcwynw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indsd2dvc2NiaXh6eWh4a2N3eW53Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM4NzIxOTIsImV4cCI6MjA4OTQ0ODE5Mn0.bUBgdB4eSRgy7kohizeWOTYyL49_wsaRsBaGiTO9Pmk',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF34C759),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
