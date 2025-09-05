import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_user.dart';

class UserRepo {
  final _col = FirebaseFirestore.instance.collection('users');

  Stream<AppUser?> watchUser(String uid) => _col
      .doc(uid)
      .snapshots()
      .map((s) => s.exists ? AppUser.fromMap(s.id, s.data()!) : null);

  Stream<List<AppUser>> watchAllCustomers() => _col
      .where('role', isEqualTo: 'customer')
      .snapshots()
      .map((q) => q.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList());
}
