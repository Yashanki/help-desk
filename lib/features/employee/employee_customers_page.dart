import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_controller.dart';
import '../users/user_repo.dart';
import '../users/app_user.dart';
import '../tickets/ticket_repo.dart';
import '../tickets/ticket.dart';

class EmployeeCustomersPage extends ConsumerStatefulWidget {
  const EmployeeCustomersPage({super.key});

  @override
  ConsumerState<EmployeeCustomersPage> createState() =>
      _EmployeeCustomersPageState();
}

class _EmployeeCustomersPageState extends ConsumerState<EmployeeCustomersPage> {
  AppUser? selectedCustomer;

  @override
  Widget build(BuildContext context) {
    final customers =
        ref
            .watch(StreamProvider((_) => UserRepo().watchAllCustomers()))
            .valueOrNull ??
        <AppUser>[];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedCustomer == null
                    ? 'Customers'
                    : 'Customer: ${selectedCustomer!.displayName.isNotEmpty ? selectedCustomer!.displayName : selectedCustomer!.email}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Row(
                children: [
                  if (selectedCustomer != null)
                    TextButton.icon(
                      onPressed: () => setState(() => selectedCustomer = null),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Customers'),
                    ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: () => ref.read(authControllerProvider).signOut(),
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: selectedCustomer == null
                ? _CustomerList(
                    customers: customers,
                    onCustomerSelected: (customer) =>
                        setState(() => selectedCustomer = customer),
                  )
                : _CustomerTicketsView(customer: selectedCustomer!),
          ),
        ],
      ),
    );
  }
}

class _CustomerList extends StatelessWidget {
  final List<AppUser> customers;
  final Function(AppUser) onCustomerSelected;

  const _CustomerList({
    required this.customers,
    required this.onCustomerSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (customers.isEmpty) {
      return const Center(
        child: Text(
          'No customers found',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Customer List',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      customer.displayName.isNotEmpty
                          ? customer.displayName[0].toUpperCase()
                          : customer.email[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    customer.displayName.isNotEmpty
                        ? customer.displayName
                        : 'No Name',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(customer.email),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => onCustomerSelected(customer),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerTicketsView extends ConsumerWidget {
  final AppUser customer;

  const _CustomerTicketsView({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tickets =
        ref
            .watch(
              StreamProvider(
                (_) => TicketRepo().watchForCustomer(customer.uid),
              ),
            )
            .valueOrNull ??
        <Ticket>[];

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    customer.displayName.isNotEmpty
                        ? customer.displayName[0].toUpperCase()
                        : customer.email[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.displayName.isNotEmpty
                            ? customer.displayName
                            : 'No Name',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        customer.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Tickets (${tickets.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: tickets.isEmpty
                ? const Center(
                    child: Text(
                      'No tickets found for this customer',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  )
                : SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Title')),
                        DataColumn(label: Text('Priority')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Created')),
                        DataColumn(label: Text('Updated')),
                      ],
                      rows: tickets
                          .map(
                            (ticket) => DataRow(
                              cells: [
                                DataCell(
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 200,
                                    ),
                                    child: Text(
                                      ticket.title,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(ticket.priority),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      priorityToString(ticket.priority),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(ticket.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      statusToString(ticket.status),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    ticket.createdAt.toLocal().toString().split(
                                      ' ',
                                    )[0],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    ticket.updatedAt.toLocal().toString().split(
                                      ' ',
                                    )[0],
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TicketPriority priority) {
    switch (priority) {
      case TicketPriority.low:
        return Colors.green;
      case TicketPriority.medium:
        return Colors.orange;
      case TicketPriority.high:
        return Colors.red;
      case TicketPriority.urgent:
        return Colors.purple;
    }
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return Colors.blue;
      case TicketStatus.inProgress:
        return Colors.orange;
      case TicketStatus.waitingOnCustomer:
        return Colors.yellow.shade700;
      case TicketStatus.resolved:
        return Colors.green;
      case TicketStatus.closed:
        return Colors.grey;
    }
  }
}
