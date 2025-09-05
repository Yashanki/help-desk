import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'customer_home.dart';
import 'customer_profile.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _selected = 0;
  bool _extended = true;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final display = user?.displayName?.trim();
    final email = user?.email?.trim() ?? '';
    final initial =
        (display?.isNotEmpty == true
                ? display![0]
                : (email.isNotEmpty ? email[0] : 'C'))
            .toUpperCase();

    final pages = <Widget>[const CustomerHome(), const CustomerProfilePage()];

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: _extended ? 256.0 : 80.0,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    Expanded(
                      child: NavigationRail(
                        extended: _extended,
                        selectedIndex: _selected,
                        groupAlignment: -1.0,
                        onDestinationSelected: (i) =>
                            setState(() => _selected = i),
                        leading: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              IconButton(
                                tooltip: _extended ? 'Collapse' : 'Expand',
                                onPressed: () =>
                                    setState(() => _extended = !_extended),
                                icon: Icon(
                                  _extended ? Icons.menu_open : Icons.menu,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CircleAvatar(
                                radius: 20,
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.space_dashboard_outlined),
                            selectedIcon: Icon(Icons.space_dashboard),
                            label: Text('Dashboard'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.person_outline),
                            selectedIcon: Icon(Icons.person),
                            label: Text('Profile'),
                          ),
                        ],
                        trailing:
                            const SizedBox.shrink(), // don't float logout here
                      ),
                    ),

                    const Divider(height: 1),

                    // --- Bottom Logout Button ---
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: IconButton.filledTonal(
                          tooltip: 'Logout',
                          onPressed: () async =>
                              FirebaseAuth.instance.signOut(),
                          icon: const Icon(Icons.logout),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: pages[_selected],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
