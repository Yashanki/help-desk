import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(child: Text('Blank customer dashboard (stub)')),
    );
  }
}
