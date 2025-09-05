import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  final user = FirebaseAuth.instance.currentUser;

  // Map to store the current values for each ticket
  final Map<String, String> _ticketPriorities = {};
  final Map<String, String> _ticketStatuses = {};

  void _refreshStats() {
    setState(() {}); // This will trigger the FutureBuilder to rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceVariant.withOpacity(0.2),
      appBar: AppBar(title: const Text('Customer Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- STATS SECTION ---
            FutureBuilder<Map<String, int>>(
              future: _fetchTicketStats(),
              builder: (context, snap) {
                final stats = snap.data ?? {'open': 0, 'closed': 0, 'all': 0};

                return Row(
                  children: [
                    _dashboardCard(
                      'Open Tickets',
                      stats['open'].toString(),
                      Icons.inbox,
                    ),
                    _dashboardCard(
                      'Closed Tickets',
                      stats['closed'].toString(),
                      Icons.check_circle,
                    ),
                    _dashboardCard(
                      'All Tickets',
                      stats['all'].toString(),
                      Icons.receipt_long,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                const Text(
                  'My Tickets',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showCreateTicketDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Ticket'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // --- TICKET TABLE FOR CUSTOMER ---
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('tickets')
                    .where('customerId', isEqualTo: user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

                  final tickets = snapshot.data!.docs;
                  if (tickets.isEmpty) return const Text('No tickets found.');

                  return Scrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 1000),
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
                              final docId = doc.id;

                              final titleController = TextEditingController(
                                text: data['title'],
                              );
                              final descController = TextEditingController(
                                text: data['description'],
                              );

                              // Initialize values if not already set
                              if (!_ticketPriorities.containsKey(docId)) {
                                _ticketPriorities[docId] =
                                    data['priority'] ?? 'Low';
                              }
                              if (!_ticketStatuses.containsKey(docId)) {
                                _ticketStatuses[docId] =
                                    data['status'] ?? 'Open';
                              }

                              final priority = _ticketPriorities[docId]!;
                              final status = _ticketStatuses[docId]!;
                              final employeeComment =
                                  data['employeeComment'] ?? '';

                              return DataRow(
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: 150,
                                      child: TextField(
                                        controller: titleController,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 250,
                                      child: TextField(
                                        controller: descController,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    DropdownButton<String>(
                                      value: priority,
                                      underline: Container(height: 0),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'Low',
                                          child: Text('Low'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Medium',
                                          child: Text('Medium'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'High',
                                          child: Text('High'),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            _ticketPriorities[docId] = val;
                                          });
                                        }
                                      },
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
                                          setState(() {
                                            _ticketStatuses[docId] = val;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      employeeComment.isNotEmpty
                                          ? employeeComment
                                          : '—',
                                    ),
                                  ),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.save),
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('tickets')
                                            .doc(docId)
                                            .update({
                                              'title': titleController.text
                                                  .trim(),
                                              'description': descController.text
                                                  .trim(),
                                              'priority':
                                                  _ticketPriorities[docId],
                                              'status': _ticketStatuses[docId],
                                            });

                                        // Refresh stats after successful update
                                        _refreshStats();

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Ticket updated'),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DASHBOARD STATS FOR CUSTOMER ---
  Future<Map<String, int>> _fetchTicketStats() async {
    if (user == null) return {'open': 0, 'closed': 0, 'all': 0};

    final snapshot = await FirebaseFirestore.instance
        .collection('tickets')
        .where('customerId', isEqualTo: user!.uid)
        .get();

    final tickets = snapshot.docs;
    final openCount = tickets.where((d) => d['status'] == 'Open').length;
    final closedCount = tickets.where((d) => d['status'] == 'Closed').length;

    return {'open': openCount, 'closed': closedCount, 'all': tickets.length};
  }

  // --- CARD WIDGET ---
  Widget _dashboardCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
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

  // --- CREATE TICKET DIALOG ---
  Future<void> _showCreateTicketDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedPriority = 'Low';
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Text(
                            'Create New Ticket',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Title Field
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Ticket Title',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a ticket title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description Field
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Priority Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.priority_high),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Low', child: Text('Low')),
                          DropdownMenuItem(
                            value: 'Medium',
                            child: Text('Medium'),
                          ),
                          DropdownMenuItem(value: 'High', child: Text('High')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedPriority = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                await _createTicket(
                                  titleController.text.trim(),
                                  descriptionController.text.trim(),
                                  selectedPriority,
                                );
                                Navigator.of(context).pop();
                                _refreshStats(); // Refresh stats after creation
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Create Ticket'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- CREATE TICKET FUNCTION ---
  Future<void> _createTicket(
    String title,
    String description,
    String priority,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('tickets').add({
        'title': title,
        'description': description,
        'priority': priority,
        'status': 'Open',
        'customerId': user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'employeeComment': '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating ticket: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
