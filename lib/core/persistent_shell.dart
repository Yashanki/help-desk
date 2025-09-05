import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/customer/customer_dashboard_page.dart';
import '../features/employee/employee_dashboard_page.dart';
import '../features/employee/employee_customers_page.dart';
import '../features/employee/employee_profile_page.dart';

class PersistentShell extends ConsumerStatefulWidget {
  final int selectedIndex;
  final String role; // 'customer' or 'employee'

  const PersistentShell({
    super.key,
    required this.selectedIndex,
    required this.role,
  });

  @override
  ConsumerState<PersistentShell> createState() => _PersistentShellState();
}

class _PersistentShellState extends ConsumerState<PersistentShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  void _nav(int i) {
    setState(() {
      _currentIndex = i;
    });
  }

  Widget _getCurrentPage() {
    if (widget.role == 'employee') {
      switch (_currentIndex) {
        case 0:
          return const EmployeeDashboardPage();
        case 1:
          return const EmployeeCustomersPage();
        case 2:
          return const EmployeeProfilePage();
        default:
          return const EmployeeDashboardPage();
      }
    } else {
      switch (_currentIndex) {
        case 0:
          return const CustomerDashboardPage();
        case 1:
          return const CustomerDashboardPage(); // later: customer tickets
        case 2:
          return const CustomerDashboardPage(); // later: customer profile
        default:
          return const CustomerDashboardPage();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _currentIndex,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: _nav,
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
          Expanded(child: _getCurrentPage()),
        ],
      ),
    );
  }
}
