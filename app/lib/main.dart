import 'package:app/ui/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ozwvxxubkseztcakoobv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im96d3Z4eHVia3NlenRjYWtvb2J2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3MTc3NTgsImV4cCI6MjA1NDI5Mzc1OH0.jVZtbMUn0fuQzprp-AP0Evz03v_6Zxq2s2RFEp8UlSk',
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins(fontWeight: FontWeight.w600).fontFamily,
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
