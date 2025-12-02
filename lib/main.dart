import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/device_list_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MuseLogApp(),
    ),
  );
}

class MuseLogApp extends StatelessWidget {
  const MuseLogApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Constants.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Constants.primaryColor,
          secondary: Constants.accentColor,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const DeviceListScreen(),
    );
  }
}
