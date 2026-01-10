// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'src/features/splash/presentation/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Market Admin',
          theme: ThemeData(
            // 1. New Color: #1986e6
            primaryColor: const Color(0xFF1986E6),
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFFF3F5F9), // Light greyish-blue bg

            // 2. New Font: Plus Jakarta Sans
            textTheme: GoogleFonts.plusJakartaSansTextTheme(),

            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1986E6),
              primary: const Color(0xFF1986E6),
            ),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}