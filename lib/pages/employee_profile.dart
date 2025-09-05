import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeProfileTemp extends StatelessWidget {
  const EmployeeProfileTemp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?.displayName ?? 'Support Agent',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(user?.email ?? 'employee@example.com'),
                const SizedBox(height: 16),
                const Text('This is a temporary profile page.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
