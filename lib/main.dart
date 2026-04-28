import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('iOS app started', style: TextStyle(fontSize: 24)),
        ),
      ),
    ),
  );
}
