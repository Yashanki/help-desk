import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/stat_card.dart';
import '../auth/auth_controller.dart';
import '../tickets/ticket_repo.dart';
import '../tickets/ticket.dart';

class EmployeeDashboardPage extends ConsumerWidget {
  const EmployeeDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserStreamProvider).valueOrNull;
    final tickets =
        ref.watch(StreamProvider((_) => TicketRepo().watchAll())).valueOrNull ??
        const <Ticket>[];

    final open = tickets.where((t) => t.status == TicketStatus.open).length;
    final waiting = tickets
        .where((t) => t.status == TicketStatus.waitingOnCustomer)
        .length;
    final resolved = tickets
        .where((t) => t.status == TicketStatus.resolved)
        .length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Welcome ${appUser?.displayName.isNotEmpty == true ? appUser!.displayName : 'Agent'}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              FilledButton.tonal(
                onPressed: () => ref.read(authControllerProvider).signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (ctx, c) {
              final cross = c.maxWidth > 1200
                  ? 4
                  : c.maxWidth > 800
                  ? 3
                  : 2;
              return GridView.count(
                crossAxisCount: cross,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  StatCard(title: 'Open', value: '$open'),
                  StatCard(title: 'Waiting', value: '$waiting'),
                  StatCard(title: 'Resolved', value: '$resolved'),
                  StatCard(title: 'Total', value: '${tickets.length}'),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Recent Tickets',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(child: _TicketsTable(tickets: tickets)),
        ],
      ),
    );
  }
}

class _TicketsTable extends StatelessWidget {
  final List<Ticket> tickets;
  const _TicketsTable({required this.tickets});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Title')),
          DataColumn(label: Text('Priority')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Updated')),
        ],
        rows: tickets
            .map(
              (t) => DataRow(
                cells: [
                  DataCell(Text(t.title)),
                  DataCell(Text(priorityToString(t.priority))),
                  DataCell(Text(statusToString(t.status))),
                  DataCell(
                    Text(t.updatedAt.toLocal().toString().split('.').first),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
