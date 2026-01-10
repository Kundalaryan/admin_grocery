import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  // ProviderScope is required for Riverpod State Management
  runApp(const ProviderScope(child: MyApp()));
}