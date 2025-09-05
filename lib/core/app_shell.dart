import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final String role; // 'customer' or 'employee'

  const AppShell({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.role,
  });

  void _nav(BuildContext context, int i) {
    if (role == 'employee') {
      if (i == 0) context.go('/employee/dashboard');
      if (i == 1) context.go('/employee/dashboard'); // later: /employee/tickets
      if (i == 2) {} // /employee/customers
      if (i == 3) {} // /employee/profile
    } else {
      if (i == 0) context.go('/customer/dashboard');
      if (i == 1) context.go('/customer/dashboard'); // later: /customer/tickets
      if (i == 2) {} // /customer/profile maybe
      if (i == 3) {} // reserved
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (i) => _nav(context, i),
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircleAvatar(radius: 20, child: Text('U')),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.confirmation_number_outlined),
                selectedIcon: Icon(Icons.confirmation_number),
                label: Text('Tickets'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_alt_outlined),
                selectedIcon: Icon(Icons.people_alt),
                label: Text('Customers'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
