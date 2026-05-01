import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Country Explorer App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF0C38E),
          secondary: Color(0xFFF1AA9B),
          surface: Color(0xFF48426D),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF312C51),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF312C51),
          foregroundColor: Color(0xFFF0C38E),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF48426D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14.0)),
          ),
          elevation: 3,
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF1AA9B),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.0),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 14.0,
              horizontal: 24.0,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF3D3863),
          hintStyle: const TextStyle(color: Colors.white54),
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIconColor: Colors.white70,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.0),
            borderSide: BorderSide.none,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white70),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
