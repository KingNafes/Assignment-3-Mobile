import 'package:flutter/material.dart';
import 'food_ordering_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FoodOrderingScreen(), // Main screen
    );
  }
}
