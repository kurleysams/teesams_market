import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/catalog/screens/catalog_screen.dart';

void main() {
  runApp(const TeesamsMarketApp());
}

class TeesamsMarketApp extends StatelessWidget {
  const TeesamsMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teesams Market',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const CatalogScreen(),
    );
  }
}
