import 'package:app/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: GoogleFonts.raleway(fontWeight: FontWeight.w600).fontFamily,
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
