import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/name_screen.dart';

const supabaseUrl = 'https://mlajnyilelsgkvxxgdwt.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1sYWpueWlsZWxzZ2t2eHhnZHd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkzOTc0NDUsImV4cCI6MjA5NDk3MzQ0NX0.joLANiWUmbY0PLOh8IMEV3QTIvjwvPYP7KL5dXDgj6I';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const NameScreen(),
    );
  }
}
