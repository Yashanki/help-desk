import 'package:flutter/material.dart';

class EmployeeHome extends StatelessWidget {
  const EmployeeHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // use parent Scaffold
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Employee Dashboard (temp)')),
    );
  }
}
