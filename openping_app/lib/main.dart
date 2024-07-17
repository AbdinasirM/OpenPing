import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:openping_app/pages/server_page.dart';
import 'package:openping_app/models/server_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  try {
    await ServerDatabase.initialize();
  } catch (e) {
    // Handle initialization errors gracefully
    print('Failed to initialize database: $e');
    // Optionally, show an error message or fallback behavior
    return;
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ServerDatabase(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SafeArea(
        child: ServersPage(),
      ),
    );
  }
}
