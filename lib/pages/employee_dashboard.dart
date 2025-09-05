import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(child: Text('Blank employee dashboard (stub)')),
    );
  }
}
