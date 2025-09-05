import 'package:cloud_firestore/cloud_firestore.dart';
import 'ticket.dart';

class TicketRepo {
  final _col = FirebaseFirestore.instance.collection('tickets');

  Stream<List<Ticket>> watchAll() => _col
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((q) => q.docs.map((d) => Ticket.fromMap(d.id, d.data())).toList());

  Stream<List<Ticket>> watchForCustomer(String customerId) => _col
      .where('customerId', isEqualTo: customerId)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((q) => q.docs.map((d) => Ticket.fromMap(d.id, d.data())).toList());
}
