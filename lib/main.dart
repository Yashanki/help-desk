import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'pages/login_page.dart';
import 'pages/customer_dashboard.dart';
import 'pages/employee_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const HelpDeskApp());
}

class HelpDeskApp extends StatelessWidget {
  const HelpDeskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HelpDesk',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const AuthGate(),
    );
  }
}

/// Shows Login when signed-out, else resolves user role and routes.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        final user = snap.data;
        if (snap.connectionState == ConnectionState.waiting) {
          return const _ScaffoldLoader();
        }
        if (user == null) {
          return const LoginPage();
        }
        return RoleGate(uid: user.uid);
      },
    );
  }
}

/// Fetches /users/{uid} and routes to the correct dashboard.
class RoleGate extends StatelessWidget {
  final String uid;
  const RoleGate({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance.collection('users').doc(uid);
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: ref.get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _ScaffoldLoader();
        }
        if (!snap.hasData || !snap.data!.exists) {
          // Fallback if user doc missing: show message + sign out.
          return _ErrorWithSignOut(
            message:
                'User profile not found. Create /users/$uid with a "role" field.',
          );
        }
        final role = snap.data!.data()?['role'] as String?;
        if (role == 'employee') return const EmployeeDashboard();
        if (role == 'customer') return const CustomerDashboard();
        return _ErrorWithSignOut(
          message:
              'Unknown role. Set "role" to "customer" or "employee" in /users/$uid.',
        );
      },
    );
  }
}

class _ScaffoldLoader extends StatelessWidget {
  const _ScaffoldLoader();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ErrorWithSignOut extends StatelessWidget {
  final String message;
  const _ErrorWithSignOut({required this.message, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
