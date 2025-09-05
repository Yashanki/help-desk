import 'package:cloud_firestore/cloud_firestore.dart';

enum TicketStatus { open, inProgress, waitingOnCustomer, resolved, closed }

enum TicketPriority { low, medium, high, urgent }

TicketStatus statusFromString(String s) {
  switch (s) {
    case 'Open':
      return TicketStatus.open;
    case 'In-Progress':
      return TicketStatus.inProgress;
    case 'Waiting on Customer':
      return TicketStatus.waitingOnCustomer;
    case 'Resolved':
      return TicketStatus.resolved;
    case 'Closed':
      return TicketStatus.closed;
    default:
      return TicketStatus.open;
  }
}

String statusToString(TicketStatus s) => const {
  TicketStatus.open: 'Open',
  TicketStatus.inProgress: 'In-Progress',
  TicketStatus.waitingOnCustomer: 'Waiting on Customer',
  TicketStatus.resolved: 'Resolved',
  TicketStatus.closed: 'Closed',
}[s]!;

TicketPriority priorityFromString(String s) {
  switch (s) {
    case 'Low':
      return TicketPriority.low;
    case 'Medium':
      return TicketPriority.medium;
    case 'High':
      return TicketPriority.high;
    case 'Urgent':
      return TicketPriority.urgent;
    default:
      return TicketPriority.medium;
  }
}

String priorityToString(TicketPriority p) => const {
  TicketPriority.low: 'Low',
  TicketPriority.medium: 'Medium',
  TicketPriority.high: 'High',
  TicketPriority.urgent: 'Urgent',
}[p]!;

class Ticket {
  final String id;
  final String title;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final String customerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.customerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ticket.fromMap(String id, Map<String, dynamic> d) {
    DateTime _ts(v) => v is Timestamp ? v.toDate() : DateTime.now();
    return Ticket(
      id: id,
      title: (d['title'] ?? '').toString(),
      description: (d['description'] ?? '').toString(),
      status: statusFromString((d['status'] ?? 'Open').toString()),
      priority: priorityFromString((d['priority'] ?? 'Medium').toString()),
      customerId: (d['customerId'] ?? '').toString(),
      createdAt: _ts(d['createdAt']),
      updatedAt: _ts(d['updatedAt']),
    );
  }
}
