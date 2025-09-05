import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmployeeHome extends StatefulWidget {
  const EmployeeHome({super.key});

  @override
  State<EmployeeHome> createState() => _EmployeeHomeState();
}

class _EmployeeHomeState extends State<EmployeeHome> {
  void _refreshStats() {
    setState(() {}); // This will trigger the FutureBuilder to rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceVariant.withOpacity(0.2),
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- STATISTICS CARDS ---
            FutureBuilder<Map<String, int>>(
              future: _fetchStats(),
              builder: (context, snap) {
                final stats =
                    snap.data ?? {'customers': 0, 'tickets': 0, 'open': 0};
                return Row(
                  children: [
                    _dashboardCard(
                      'Customers',
                      stats['customers'].toString(),
                      Icons.people,
                    ),
                    _dashboardCard(
                      'All Tickets',
                      stats['tickets'].toString(),
                      Icons.description,
                    ),
                    _dashboardCard(
                      'Open Tickets',
                      stats['open'].toString(),
                      Icons.inbox,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // --- CUSTOMERS LIST ---
            const Text(
              'Customer List',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'customer')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Text('No customers found.');

                  return Card(
                    elevation: 2,
                    child: ListView.separated(
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final customer = docs[i];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              (customer['email'] ?? '?')[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(customer['email'] ?? 'Unknown'),
                          subtitle: Text(customer['address'] ?? 'No address'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final result = await _showTicketsPopup(
                              context,
                              customer.id,
                            );
                            if (result == true) {
                              _refreshStats(); // ✅ refresh stats after popup closes
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STATS FETCH ---
  Future<Map<String, int>> _fetchStats() async {
    final usersSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'customer')
        .get();
    final ticketsSnap = await FirebaseFirestore.instance
        .collection('tickets')
        .get();
    final openCount = ticketsSnap.docs
        .where((d) => d['status'] == 'Open')
        .length;
    return {
      'customers': usersSnap.docs.length,
      'tickets': ticketsSnap.docs.length,
      'open': openCount,
    };
  }

  Future<bool?> _showTicketsPopup(
    BuildContext context,
    String customerId,
  ) async {
    final ticketsSnap = await FirebaseFirestore.instance
        .collection('tickets')
        .where('customerId', isEqualTo: customerId)
        .get();

    final tickets = ticketsSnap.docs;

    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 900,
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxHeight: 600, minHeight: 200),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'Customer Tickets',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),

              // Body
              if (tickets.isEmpty)
                const Expanded(child: Center(child: Text("No tickets found")))
              else
                Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 800),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columnSpacing: 24,
                            columns: const [
                              DataColumn(label: Text('Title')),
                              DataColumn(label: Text('Description')),
                              DataColumn(label: Text('Priority')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Employee Comment')),
                              DataColumn(label: Text('')),
                            ],
                            rows: tickets.map((doc) {
                              final data = doc.data();
                              final title = data['title'] ?? '';
                              final description = data['description'] ?? '';
                              final priority = data['priority'] ?? '';
                              final status = data['status'] ?? 'Open';
                              final comment = data['employeeComment'] ?? '';
                              final commentController = TextEditingController(
                                text: comment,
                              );

                              return DataRow(
                                cells: [
                                  DataCell(Text(title)),
                                  DataCell(Text(description)),
                                  DataCell(
                                    Chip(
                                      label: Text(priority),
                                      backgroundColor: Colors.blue.shade50,
                                      labelStyle: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    DropdownButton<String>(
                                      value: status,
                                      underline: Container(height: 0),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'Open',
                                          child: Text('Open'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'InProgress',
                                          child: Text('In Progress'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Resolved',
                                          child: Text('Resolved'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Closed',
                                          child: Text('Closed'),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          FirebaseFirestore.instance
                                              .collection('tickets')
                                              .doc(doc.id)
                                              .update({'status': val});
                                        }
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 200,
                                      child: TextField(
                                        controller: commentController,
                                        onSubmitted: (val) {
                                          FirebaseFirestore.instance
                                              .collection('tickets')
                                              .doc(doc.id)
                                              .update({
                                                'employeeComment': val.trim(),
                                              });
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'Enter comment',
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.save),
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('tickets')
                                            .doc(doc.id)
                                            .update({
                                              'employeeComment':
                                                  commentController.text.trim(),
                                            });

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Comment saved"),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DASHBOARD CARD WIDGET ---
  Widget _dashboardCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.indigo),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
