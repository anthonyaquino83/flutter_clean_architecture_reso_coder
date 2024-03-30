import 'package:flutter/material.dart';
import 'features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'injection_container.dart' as di;

// 1 - Domain
// Entity
// Failure (returned after Exception)
// Abstract repository (interface)
// Use case
// Test (red, green, refactor from TDD)
// Abstract use case (interface)
// 2 - Data
// Model
// Test fixture
// Repository implementation
// Abstract data source (remote and local)
// Exceptions
// Test repository implementation
// 3 - Core
// Network check
// Network check test
// Network check implementation
// 4 - Presentation
// Bloc
// Input converter
// Bloc test
// Dependency injection (get_it)
// Pages

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Trivia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const NumberTriviaPage(),
    );
  }
}
